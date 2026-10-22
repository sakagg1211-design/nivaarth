import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/stock_score.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../providers/stock_provider.dart';
import '../../../repositories/portfolio_repository.dart';
import '../../../repositories/price_repository.dart';
import '../../../services/backend_service.dart';

/// Modal bottom sheet dialog for adding a stock holding with live autocomplete search
class AddHoldingSheet extends ConsumerStatefulWidget {
  final String? initialInstrument;
  final String? initialCompanyName;
  final double? initialPrice;

  const AddHoldingSheet({
    super.key,
    this.initialInstrument,
    this.initialCompanyName,
    this.initialPrice,
  });

  @override
  ConsumerState<AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<AddHoldingSheet> {
  final _instrumentController = TextEditingController();
  final _companyController = TextEditingController();
  final _qtyController = TextEditingController();
  final _avgPriceController = TextEditingController();
  final _qtyFocusNode = FocusNode();

  String? _selectedYahooSymbol;
  double? _liveLtp;
  bool _fetchingLtp = false;

  List<StockScore> _suggestions = [];
  bool _isSearching = false;
  Timer? _debounceTimer;

  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.initialInstrument != null && widget.initialInstrument!.isNotEmpty) {
      final sym = SymbolUtils.normalize(widget.initialInstrument!);
      _instrumentController.text = sym;
      _companyController.text = widget.initialCompanyName?.isNotEmpty == true
          ? widget.initialCompanyName!
          : SymbolUtils.getDisplayName(sym);
      _selectedYahooSymbol = SymbolUtils.getYahooSymbol(sym);
      if (widget.initialPrice != null && widget.initialPrice! > 0) {
        _avgPriceController.text = widget.initialPrice!.toStringAsFixed(2);
        _liveLtp = widget.initialPrice;
      }
    }
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    _instrumentController.dispose();
    _companyController.dispose();
    _qtyController.dispose();
    _avgPriceController.dispose();
    _qtyFocusNode.dispose();
    super.dispose();
  }

  void _onSearchChanged(String text) {
    _debounceTimer?.cancel();
    final q = text.trim();
    if (q.length < 2) {
      if (_suggestions.isNotEmpty) {
        setState(() => _suggestions = []);
      }
      return;
    }

    _debounceTimer = Timer(const Duration(milliseconds: 220), () async {
      setState(() => _isSearching = true);
      try {
        final results = await ref.read(stockRepositoryProvider).searchStocks(q);
        if (mounted) {
          setState(() {
            _suggestions = results.take(6).toList();
            _isSearching = false;
          });
        }
      } catch (_) {
        if (mounted) {
          setState(() => _isSearching = false);
        }
      }
    });
  }

  Future<void> _selectStock(StockScore stock) async {
    final cleanSym = SymbolUtils.normalize(stock.instrument);
    final yfSym = SymbolUtils.getYahooSymbol(stock.instrument);

    setState(() {
      _instrumentController.text = cleanSym;
      _companyController.text = stock.companyName;
      _selectedYahooSymbol = yfSym;
      _suggestions = [];
      _fetchingLtp = true;
    });

    // Fetch live market price if available in PriceRepository
    try {
      final prices = await PriceRepository().getPrices();
      final match = prices.firstWhere(
        (p) =>
            p.instrument.trim().toUpperCase() == cleanSym ||
            p.instrument.trim().toUpperCase() == yfSym,
        orElse: () => prices.first,
      );

      if (match.instrument.trim().toUpperCase() == cleanSym ||
          match.instrument.trim().toUpperCase() == yfSym) {
        if (match.currentPrice > 0) {
          setState(() {
            _liveLtp = match.currentPrice;
            if (_avgPriceController.text.isEmpty) {
              _avgPriceController.text = match.currentPrice.toStringAsFixed(2);
            }
          });
        }
      }
    } catch (_) {}

    setState(() => _fetchingLtp = false);

    // Shift focus to Quantity
    _qtyFocusNode.requestFocus();
  }

  Future<void> _handleSubmit() async {
    final instrument = _instrumentController.text.trim().toUpperCase();
    final company = _companyController.text.trim();
    final qty = int.tryParse(_qtyController.text.trim());
    final avgPrice = double.tryParse(_avgPriceController.text.trim());

    if (instrument.isEmpty) {
      setState(() => _errorMessage = 'Please search and select a stock symbol.');
      return;
    }

    if (qty == null || qty <= 0) {
      setState(() => _errorMessage = 'Please enter a valid quantity greater than 0.');
      return;
    }

    if (avgPrice == null || avgPrice <= 0) {
      setState(() => _errorMessage = 'Please enter a valid average buy price.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final yfSymbol = _selectedYahooSymbol ?? SymbolUtils.getYahooSymbol(instrument);
      final repository = PortfolioRepository();

      await repository.addHolding(
        instrument: instrument,
        companyName: company.isEmpty ? instrument : company,
        qty: qty,
        avgPrice: avgPrice,
      );

      // Trigger instant single-stock onboarding in backend (Price, Tech, Fund, Score)
      BackendService().onboardStock(
        instrument: instrument,
        yahooSymbol: yfSymbol,
      ).catchError((_) {});

      // Refresh providers
      ref.invalidate(portfolioProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(dashboardProvider);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('$instrument added to portfolio successfully!'),
          backgroundColor: const Color(0xFF0C9F6E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to add holding: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;

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
                    Icons.add_chart_rounded,
                    color: Colors.black,
                    size: 20,
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                const Expanded(
                  child: Text(
                    'Add Stock Holding',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.sm),
            const Text(
              'Search any NSE/BSE stock to auto-fill details and start live AI tracking.',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Live Autocomplete Search Field
            TextField(
              controller: _instrumentController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
              decoration: _inputDecoration(
                'Search Stock Symbol (e.g. RELIANCE, TITAN, INFY)',
                Icons.search_rounded,
                suffix: _isSearching
                    ? const SizedBox(
                        height: 16,
                        width: 16,
                        child: CircularProgressIndicator(strokeWidth: 2, color: Color(0xFFE5A93C)),
                      )
                    : null,
              ),
              onChanged: _onSearchChanged,
            ),

            // Suggestions Dropdown
            if (_suggestions.isNotEmpty) ...[
              const SizedBox(height: 6),
              Container(
                constraints: const BoxConstraints(maxHeight: 220),
                decoration: BoxDecoration(
                  color: const Color(0xFF1E2024),
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: const Color(0xFF282A30)),
                  boxShadow: const [
                    BoxShadow(
                      color: Colors.black45,
                      blurRadius: 10,
                      offset: Offset(0, 4),
                    ),
                  ],
                ),
                child: ListView.separated(
                  shrinkWrap: true,
                  padding: const EdgeInsets.symmetric(vertical: 4),
                  itemCount: _suggestions.length,
                  separatorBuilder: (context, index) => const Divider(height: 1, color: Color(0xFF282A30)),
                  itemBuilder: (context, index) {
                    final item = _suggestions[index];
                    final cleanSym = SymbolUtils.normalize(item.instrument);
                    return ListTile(
                      dense: true,
                      leading: Container(
                        height: 28,
                        width: 28,
                        decoration: BoxDecoration(
                          color: const Color(0x33E5A93C),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: Center(
                          child: Text(
                            cleanSym.isNotEmpty ? cleanSym[0] : 'S',
                            style: const TextStyle(color: Color(0xFFE5A93C), fontWeight: FontWeight.w800, fontSize: 13),
                          ),
                        ),
                      ),
                      title: Text(
                        cleanSym,
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w800, fontSize: 13.5),
                      ),
                      subtitle: Text(
                        item.companyName,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(color: Color(0xFF8E929B), fontSize: 11.5),
                      ),
                      trailing: item.overallScore > 0
                          ? Container(
                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                              decoration: BoxDecoration(
                                color: const Color(0x1F00E676),
                                borderRadius: BorderRadius.circular(4),
                              ),
                              child: Text(
                                '${item.overallScore} ${item.recommendation}',
                                style: const TextStyle(color: Color(0xFF00E676), fontSize: 10, fontWeight: FontWeight.w700),
                              ),
                            )
                          : null,
                      onTap: () => _selectStock(item),
                    );
                  },
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            // Company Name Field
            TextField(
              controller: _companyController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Company Name', Icons.business_rounded),
            ),

            // Live LTP Badge
            if (_fetchingLtp) ...[
              const SizedBox(height: 8),
              const Row(
                children: [
                  SizedBox(width: 12, height: 12, child: CircularProgressIndicator(strokeWidth: 1.5, color: Color(0xFFE5A93C))),
                  SizedBox(width: 8),
                  Text('Fetching live price...', style: TextStyle(color: Color(0xFF8E929B), fontSize: 11.5)),
                ],
              ),
            ] else if (_liveLtp != null && _liveLtp! > 0) ...[
              const SizedBox(height: 8),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                decoration: BoxDecoration(
                  color: const Color(0x1FE5A93C),
                  borderRadius: BorderRadius.circular(8),
                  border: Border.all(color: const Color(0x33E5A93C)),
                ),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.show_chart_rounded, size: 15, color: Color(0xFFE5A93C)),
                    const SizedBox(width: 6),
                    Text(
                      'Live Market LTP: ${Formatters.currency(_liveLtp!)}',
                      style: const TextStyle(color: Color(0xFFE5A93C), fontSize: 11.5, fontWeight: FontWeight.w700),
                    ),
                    const SizedBox(width: 8),
                    InkWell(
                      onTap: () {
                        setState(() {
                          _avgPriceController.text = _liveLtp!.toStringAsFixed(2);
                        });
                      },
                      child: const Text(
                        '[Use as Buy Price]',
                        style: TextStyle(color: Colors.white, fontSize: 11, fontWeight: FontWeight.w800, decoration: TextDecoration.underline),
                      ),
                    ),
                  ],
                ),
              ),
            ],

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                // Qty
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    focusNode: _qtyFocusNode,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Quantity', Icons.pin_outlined),
                    onChanged: (_) {
                      if (_errorMessage != null) setState(() => _errorMessage = null);
                    },
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                // Avg Price
                Expanded(
                  child: TextField(
                    controller: _avgPriceController,
                    keyboardType: const TextInputType.numberWithOptions(decimal: true),
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Avg Buy Price (₹)', Icons.currency_rupee_rounded),
                    onChanged: (_) {
                      if (_errorMessage != null) setState(() => _errorMessage = null);
                    },
                  ),
                ),
              ],
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

            const SizedBox(height: AppSpacing.xl),

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
                onPressed: _loading ? null : _handleSubmit,
                child: _loading
                    ? const SizedBox(
                        height: 20,
                        width: 20,
                        child: CircularProgressIndicator(
                          strokeWidth: 2,
                          color: Colors.black,
                        ),
                      )
                    : const Text(
                        'Add to Portfolio',
                        style: TextStyle(
                          fontSize: 15,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon, {Widget? suffix}) {
    return InputDecoration(
      labelText: label,
      labelStyle: const TextStyle(color: Color(0xFF8E929B), fontSize: 13),
      prefixIcon: Icon(icon, color: const Color(0xFF8E929B), size: 18),
      suffixIcon: suffix != null ? Padding(padding: const EdgeInsets.all(12), child: suffix) : null,
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
