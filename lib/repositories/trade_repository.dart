import 'package:intl/intl.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../core/utils/symbol_utils.dart';
import '../models/trade.dart';
import 'portfolio_repository.dart';

/// Buys and sells (public."Trades", migration 16). Every write goes through an RPC that saves
/// the trade and rebuilds the stock's Portfolio row in one transaction, so the two never drift.
class TradeRepository {
  final SupabaseClient client = Supabase.instance.client;

  static final _day = DateFormat('yyyy-MM-dd');

  /// The database raises plain Hinglish messages (P0001), e.g. "Itne shares nahi hain…";
  /// show those as they are.
  static String message(Object error) {
    if (error is PostgrestException) return error.message;
    return error.toString().replaceFirst('Exception: ', '');
  }

  String _requireUser() {
    final user = client.auth.currentUser;
    if (user == null) {
      throw Exception('Login zaroori hai.');
    }
    return user.id;
  }

  /// All trades of one stock, oldest first.
  Future<List<Trade>> getTrades(String instrument) async {
    final userId = _requireUser();
    final rows = await client
        .from('Trades')
        .select()
        .eq('user_id', userId)
        .eq('Instrument', instrument.trim().toUpperCase())
        .order('trade_date')
        .order('created_at');
    return rows.map<Trade>((json) => Trade.fromJson(json)).toList();
  }

  /// Every trade of the user, all stocks, newest first. Paged: Supabase returns at most
  /// 1,000 rows per request.
  Future<List<Trade>> getAllTrades() async {
    final userId = _requireUser();
    const page = 1000;
    final all = <Trade>[];
    for (var start = 0;; start += page) {
      final rows = await client
          .from('Trades')
          .select()
          .eq('user_id', userId)
          .order('trade_date', ascending: false)
          .order('created_at', ascending: false)
          .order('id')
          .range(start, start + page - 1);
      all.addAll(rows.map<Trade>((json) => Trade.fromJson(json)));
      if (rows.length < page) return all;
    }
  }

  /// A buy into a new or held stock (held: weighted average), or a sell from a held one.
  Future<void> addTrade({
    required String instrument,
    required TradeSide side,
    required int qty,
    required double price,
    DateTime? tradeDate,
    String? companyName,
    String? note,
  }) async {
    _requireUser();
    final sym = instrument.trim().toUpperCase();
    if (side == TradeSide.buy) {
      await PortfolioRepository().checkListed(sym);
    }
    await client.rpc('add_trade', params: {
      'p_instrument': sym,
      'p_side': side == TradeSide.sell ? 'SELL' : 'BUY',
      'p_qty': qty,
      'p_price': price,
      'p_trade_date': _day.format(tradeDate ?? DateTime.now()),
      'p_note': note,
      'p_company_name': companyName,
      'p_yahoo_symbol': SymbolUtils.getYahooSymbol(sym),
    });
  }

  /// Removing the last trade of a stock removes the holding too.
  Future<void> deleteTrade(String tradeId) async {
    _requireUser();
    await client.rpc('delete_trade', params: {'p_id': tradeId});
  }

  /// "Delete Stock": the holding and all of its trades.
  Future<void> deleteHolding(String instrument) async {
    _requireUser();
    await client.rpc('delete_holding', params: {'p_instrument': instrument.trim().toUpperCase()});
  }
}
