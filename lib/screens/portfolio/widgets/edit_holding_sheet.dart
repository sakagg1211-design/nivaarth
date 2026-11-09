import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/holding_math.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/live_portfolio.dart';
import '../../../models/trade.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/privacy_provider.dart';
import '../../../repositories/trade_repository.dart';
import 'trade_widgets.dart';
import '../../../core/l10n/l10n_ext.dart';

/// "Trade jodo" sheet for a held stock: add a buy or sell, see the trades behind the holding,
/// remove a trade or the whole stock. Qty and average are never typed in directly; the database
/// rebuilds them from the trades (migration 16).
class EditHoldingSheet extends ConsumerStatefulWidget {
  final LivePortfolio stock;

  const EditHoldingSheet({
    super.key,
    required this.stock,
  });

  @override
  ConsumerState<EditHoldingSheet> createState() => _EditHoldingSheetState();
}

class _EditHoldingSheetState extends ConsumerState<EditHoldingSheet> {
  final _qtyController = TextEditingController();
  final _priceController = TextEditingController();
  final _repository = TradeRepository();

  TradeSide _side = TradeSide.buy;
  DateTime _tradeDate = DateTime.now();
  late Future<List<Trade>> _tradesFuture;

  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.stock.currentPrice > 0) {
      _priceController.text = widget.stock.currentPrice.toStringAsFixed(2);
    }
    _tradesFuture = _repository.getTrades(widget.stock.portfolio.instrument);
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  String get _instrument => widget.stock.portfolio.instrument;

  HoldingSummary get _current => HoldingSummary(
        qty: widget.stock.portfolio.qty.toDouble(),
        totalInvested: widget.stock.portfolio.totalInvested,
        avgPrice: widget.stock.portfolio.avgPrice,
        realizedPl: widget.stock.portfolio.realizedPl,
      );

  void _refreshProviders() {
    ref.invalidate(portfolioProvider);
    ref.invalidate(livePortfolioProvider);
    ref.invalidate(dashboardProvider);
  }

  Future<void> _closeWith(String message, Color color) async {
    _refreshProviders();
    if (!mounted) return;
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: color),
    );
  }

  Future<void> _handleAddTrade() async {
    final qty = int.tryParse(_qtyController.text.trim());
    final price = double.tryParse(_priceController.text.trim());

    if (qty == null || qty <= 0) {
      setState(() => _errorMessage = context.t.tradeQtyPositive);
      return;
    }
    if (price == null || price <= 0) {
      setState(() => _errorMessage = context.t.tradePricePositive);
      return;
    }
    if (_side == TradeSide.sell && qty > widget.stock.portfolio.qty) {
      setState(() => _errorMessage =
          context.t.tradeNotEnough(widget.stock.portfolio.qty, qty));
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    // What this sell does to the holding, for the popup after it is saved (same math as the database)
    final p = widget.stock.portfolio;
    final before = HoldingSummary(
      qty: p.qty.toDouble(),
      totalInvested: p.totalInvested,
      avgPrice: p.avgPrice,
      realizedPl: p.realizedPl,
    );
    final after = _side == TradeSide.sell
        ? HoldingMath.apply(before, TradeSide.sell, qty.toDouble(), price)
        : null;

    final t = context.t;
    try {
      await _repository.addTrade(
        instrument: _instrument,
        side: _side,
        qty: qty,
        price: price,
        tradeDate: _tradeDate,
      );
      if (after != null && mounted) {
        await showSellResult(
          context,
          instrument: _instrument,
          qty: qty,
          price: price,
          before: before,
          after: after,
          hide: ref.read(privacyModeProvider),
        );
      }
      await _closeWith(
        _side == TradeSide.buy
            ? t.addMerged(_instrument, qty)
            : t.tradeSellSaved(_instrument, qty),
        const Color(0xFF0C9F6E),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = TradeRepository.message(e, context.t);
        _loading = false;
      });
    }
  }

  Future<bool> _confirm(String title, String body, String action) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF1E2024),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: const BorderSide(color: Color(0xFF282A30)),
        ),
        title: Row(
          children: [
            const Icon(Icons.delete_forever_rounded, color: Color(0xFFFF5252), size: 24),
            const SizedBox(width: 8),
            Expanded(
              child: Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
              ),
            ),
          ],
        ),
        content: Text(body, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 14)),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(context.t.commonCancel, style: TextStyle(color: Color(0xFF8E929B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(action, style: const TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );
    return confirmed == true;
  }

  Future<void> _handleDeleteTrade(Trade trade) async {
    final ok = await _confirm(
      trade.isOpening ? context.t.tradeRemoveOpening : context.t.tradeRemoveThis,
      trade.isOpening
          // The OPENING trade is the whole holding from before Trade jodo; removing it
          // drops those shares, which is rarely what the user means.
          ? context.t.tradeRemoveOpeningBody(_plainQty(trade.qty), Formatters.currency(trade.price))
          : '${trade.side == TradeSide.buy ? 'BUY' : 'SELL'} ${_plainQty(trade.qty)} @ '
              '${Formatters.currency(trade.price)} (${DateFormat('d MMM yyyy').format(trade.tradeDate)}). ${context.t.tradeRebuilt}',
      trade.isOpening ? context.t.tradeYesRemove : context.t.tradeRemove,
    );
    if (!ok) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    if (!mounted) return;
    final t = context.t;
    try {
      await _repository.deleteTrade(trade.id);
      await _closeWith(t.tradeRemoved(_instrument), const Color(0xFFFF5252));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = TradeRepository.message(e, context.t);
        _loading = false;
      });
    }
  }

  Future<void> _handleDeleteStock() async {
    final ok = await _confirm(
      context.t.holdingRemoveTitle(_instrument),
      context.t.holdingRemoveBodyFinal(_instrument),
      context.t.commonDelete,
    );
    if (!ok) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });
    if (!mounted) return;
    final t = context.t;
    try {
      await _repository.deleteHolding(_instrument);
      await _closeWith(t.holdingRemovedFull(_instrument), const Color(0xFFFF5252));
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = TradeRepository.message(e, context.t);
        _loading = false;
      });
    }
  }

  static String _plainQty(double v) =>
      v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final portfolio = widget.stock.portfolio;
    final displayName = SymbolUtils.getDisplayName(
      portfolio.instrument,
      dbCompanyName: portfolio.companyName,
    );
    final livePrice = widget.stock.currentPrice;

    return Container(
      padding: EdgeInsets.fromLTRB(
        AppSpacing.xl,
        AppSpacing.lg,
        AppSpacing.xl,
        AppSpacing.xl + bottomInset,
      ),
      decoration: const BoxDecoration(
        color: Color(0xFF16171B),
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(AppRadius.sheet),
        ),
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                height: 4,
                width: 36,
                decoration: BoxDecoration(
                  color: const Color(0xFF282A30),
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
              ),
            ),
            const SizedBox(height: AppSpacing.lg),

            // Header Row
            Row(
              children: [
                Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0xFFE5A93C),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.swap_vert_rounded,
                    color: Colors.black,
                    size: 22,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        context.t.tradeAddFor(portfolio.instrument),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                      Text(
                        displayName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(
                          color: Color(0xFF8E929B),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  tooltip: context.t.holdingDelete,
                  onPressed: _loading ? null : _handleDeleteStock,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF5252),
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Current holding
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2024),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF282A30)),
              ),
              child: Column(
                children: [
                  _infoRow(context.t.editHolding, '${portfolio.qty} @ ${Formatters.currency(portfolio.avgPrice)}'),
                  const SizedBox(height: 6),
                  _infoRow(context.t.editTotalInvested, Formatters.currency(portfolio.totalInvested)),
                  if (portfolio.realizedPl != 0) ...[
                    const SizedBox(height: 6),
                    _infoRow(
                      context.t.editRealized,
                      Formatters.currency(portfolio.realizedPl, signed: true),
                      color: portfolio.realizedPl >= 0
                          ? const Color(0xFF00E676)
                          : const Color(0xFFFF5252),
                    ),
                  ],
                  if (livePrice > 0) ...[
                    const SizedBox(height: 6),
                    _infoRow(context.t.editLtp, Formatters.currency(livePrice)),
                  ],
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Buy / Sell
            Row(
              children: [
                Expanded(child: _sideButton(TradeSide.buy, 'BUY', const Color(0xFF00E676))),
                const SizedBox(width: AppSpacing.md),
                Expanded(child: _sideButton(TradeSide.sell, 'SELL', const Color(0xFFFF5252))),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(context.t.commonQuantity, Icons.pin_outlined),
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  child: TextField(
                    controller: _priceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration(
                      _side == TradeSide.buy ? context.t.commonBuyPrice : context.t.commonSellPrice,
                      Icons.currency_rupee_rounded,
                    ),
                    onChanged: (_) => setState(() => _errorMessage = null),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),
            TradeDateField(
              date: _tradeDate,
              onChanged: (d) => setState(() => _tradeDate = d),
            ),

            const SizedBox(height: AppSpacing.md),
            TradePreview(
              start: _current,
              side: _side,
              qty: int.tryParse(_qtyController.text.trim()),
              price: double.tryParse(_priceController.text.trim()),
            ),

            if (_errorMessage != null) ...[
              const SizedBox(height: AppSpacing.md),
              Row(
                children: [
                  const Icon(Icons.error_outline_rounded, size: 16, color: Color(0xFFFF5252)),
                  const SizedBox(width: 6),
                  Expanded(
                    child: Text(
                      _errorMessage!,
                      style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12),
                    ),
                  ),
                ],
              ),
            ],

            const SizedBox(height: AppSpacing.lg),

            SizedBox(
              width: double.infinity,
              height: 48,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFE5A93C),
                  foregroundColor: Colors.black,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                onPressed: _loading ? null : _handleAddTrade,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                      )
                    : Text(context.t.tradeAdd, style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
              ),
            ),

            const SizedBox(height: AppSpacing.xl),

            // Trade history
            Text(
              context.t.tradesHeading,
              style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800),
            ),
            const SizedBox(height: AppSpacing.sm),
            FutureBuilder<List<Trade>>(
              future: _tradesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState != ConnectionState.done) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 12),
                    child: Center(
                      child: SizedBox(
                        height: 18,
                        width: 18,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE5A93C)),
                      ),
                    ),
                  );
                }
                if (snapshot.hasError) {
                  return Text(
                    context.t.tradesLoadError(TradeRepository.message(snapshot.error!, context.t)),
                    style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12),
                  );
                }
                final trades = snapshot.data ?? const <Trade>[];
                if (trades.isEmpty) {
                  return Text(
                    context.t.tradesNoneYet,
                    style: TextStyle(color: Color(0xFF8E929B), fontSize: 12),
                  );
                }
                return Column(
                  children: [
                    for (final t in trades.reversed) _tradeRow(t),
                  ],
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _tradeRow(Trade t) {
    final isBuy = t.side == TradeSide.buy;
    final tone = isBuy ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    return Container(
      margin: const EdgeInsets.only(bottom: 6),
      padding: const EdgeInsets.fromLTRB(12, 8, 4, 8),
      decoration: BoxDecoration(
        color: const Color(0xFF121316),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: const Color(0xFF23252B)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
            decoration: BoxDecoration(
              color: tone.withValues(alpha: 0.12),
              borderRadius: BorderRadius.circular(4),
            ),
            child: Text(
              t.source == 'CORP_ACT' ? 'BONUS' : (isBuy ? 'BUY' : 'SELL'),
              style: TextStyle(color: tone, fontSize: 11, fontWeight: FontWeight.w800),
            ),
          ),
          const SizedBox(width: 10),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${_plainQty(t.qty)} @ ${Formatters.currency(t.price)}',
                  style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
                ),
                Text(
                  t.isOpening
                      ? '${DateFormat('d MMM yyyy').format(t.tradeDate)} · Shuruaati holding'
                      : DateFormat('d MMM yyyy').format(t.tradeDate),
                  style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12),
                ),
              ],
            ),
          ),
          IconButton(
            tooltip: context.t.tradeRemoveTip,
            onPressed: _loading ? null : () => _handleDeleteTrade(t),
            icon: const Icon(Icons.close_rounded, color: Color(0xFF8E929B), size: 18),
          ),
        ],
      ),
    );
  }

  Widget _sideButton(TradeSide side, String label, Color color) {
    final selected = _side == side;
    return OutlinedButton(
      style: OutlinedButton.styleFrom(
        backgroundColor: selected ? color.withValues(alpha: 0.14) : Colors.transparent,
        foregroundColor: selected ? color : const Color(0xFF8E929B),
        side: BorderSide(color: selected ? color : const Color(0xFF282A30)),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        padding: const EdgeInsets.symmetric(vertical: 12),
      ),
      onPressed: _loading
          ? null
          : () => setState(() {
                _side = side;
                _errorMessage = null;
              }),
      child: Text(label, style: const TextStyle(fontWeight: FontWeight.w800)),
    );
  }

  Widget _infoRow(String label, String value, {Color? color}) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12, fontWeight: FontWeight.w600)),
        Text(
          value,
          style: TextStyle(color: color ?? Colors.white, fontSize: 13, fontWeight: FontWeight.w800),
        ),
      ],
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8E929B), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF8E929B), size: 18),
      filled: true,
      fillColor: const Color(0xFF1E2024),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF282A30)),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFF282A30)),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: const BorderSide(color: Color(0xFFE5A93C), width: 1.2),
      ),
    );
  }
}


/// After a sell: its realized P&L (average cost), the shares left and their average, which a
/// sell does not change. A full exit says the stock moved to Closed positions.
Future<void> showSellResult(
  BuildContext context, {
  required String instrument,
  required int qty,
  required double price,
  required HoldingSummary before,
  required HoldingSummary after,
  required bool hide,
}) {
  final pl = after.realizedPl - before.realizedPl;
  final cost = before.avgPrice * qty;
  final pct = cost > 0 ? pl / cost * 100 : null;
  final tone = pl >= 0 ? const Color(0xFF00E676) : const Color(0xFFFF5252);
  String money(num v, {bool signed = false}) => hide ? '••••' : Formatters.currency(v, signed: signed);
  final left = after.qty == after.qty.roundToDouble() ? after.qty.toStringAsFixed(0) : after.qty.toString();
  return showDialog<void>(
    context: context,
    builder: (ctx) => AlertDialog(
      backgroundColor: const Color(0xFF1E2024),
      title: Text(context.t.sellDoneTitle(instrument, qty), style: const TextStyle(color: Colors.white, fontSize: 17)),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(context.t.sellRealized, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
          const SizedBox(height: 4),
          Text(
            '${money(pl, signed: true)}${pct != null && !hide ? '  (${Formatters.percent(pct, signed: true)})' : ''}',
            style: TextStyle(color: hide ? Colors.white70 : tone, fontSize: 20, fontWeight: FontWeight.w800),
          ),
          const SizedBox(height: 6),
          Text(context.t.sellDetail(qty, money(price), money(before.avgPrice)),
              style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
          const SizedBox(height: 14),
          Text(
            after.isClosed
                ? context.t.sellAllGone(instrument)
                : context.t.sellRemaining(left, money(after.avgPrice), money(after.totalInvested)),
            style: const TextStyle(color: Colors.white, fontSize: 13),
          ),
        ],
      ),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx), child: Text(context.t.commonOk)),
      ],
    ),
  );
}
