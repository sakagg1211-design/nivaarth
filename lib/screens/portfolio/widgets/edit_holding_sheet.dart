import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/utils/formatters.dart';
import '../../../core/utils/symbol_utils.dart';
import '../../../models/live_portfolio.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../repositories/portfolio_repository.dart';

/// Modal bottom sheet dialog for modifying or deleting an existing holding
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
  late final TextEditingController _qtyController;
  late final TextEditingController _avgPriceController;

  bool _loading = false;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _qtyController = TextEditingController(text: widget.stock.portfolio.qty.toString());
    _avgPriceController = TextEditingController(text: widget.stock.portfolio.avgPrice.toStringAsFixed(2));
  }

  @override
  void dispose() {
    _qtyController.dispose();
    _avgPriceController.dispose();
    super.dispose();
  }

  int get _parsedQty => int.tryParse(_qtyController.text.trim()) ?? 0;
  double get _parsedAvgPrice => double.tryParse(_avgPriceController.text.trim()) ?? 0.0;
  double get _livePrice => widget.stock.currentPrice > 0 ? widget.stock.currentPrice : _parsedAvgPrice;

  double get _newInvested => _parsedQty * _parsedAvgPrice;
  double get _newCurrentVal => _parsedQty * _livePrice;
  double get _newNetPL => _newCurrentVal - _newInvested;
  double get _newReturnPct => _newInvested > 0 ? (_newNetPL / _newInvested) * 100.0 : 0.0;

  Future<void> _handleSave() async {
    final qty = _parsedQty;
    final avgPrice = _parsedAvgPrice;

    if (qty <= 0) {
      setState(() => _errorMessage = 'Quantity must be greater than 0.');
      return;
    }

    if (avgPrice <= 0) {
      setState(() => _errorMessage = 'Average buy price must be greater than 0.');
      return;
    }

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final repository = PortfolioRepository();
      await repository.updateHolding(
        id: widget.stock.portfolio.id,
        qty: qty,
        avgPrice: avgPrice,
        currentPrice: _livePrice,
      );

      // Refresh providers
      ref.invalidate(portfolioProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(dashboardProvider);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.stock.portfolio.instrument} updated successfully!'),
          backgroundColor: const Color(0xFF0C9F6E),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to update holding: $e';
        _loading = false;
      });
    }
  }

  Future<void> _handleDelete() async {
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
            Text(
              'Remove ${widget.stock.portfolio.instrument}?',
              style: const TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700),
            ),
          ],
        ),
        content: Text(
          'Are you sure you want to delete ${widget.stock.portfolio.instrument} from your portfolio? This action cannot be undone.',
          style: const TextStyle(color: Color(0xFF8E929B), fontSize: 13.5),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: const Text('Cancel', style: TextStyle(color: Color(0xFF8E929B))),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFFFF5252),
              foregroundColor: Colors.white,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
            ),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Delete', style: TextStyle(fontWeight: FontWeight.w700)),
          ),
        ],
      ),
    );

    if (confirmed != true) return;

    setState(() {
      _loading = true;
      _errorMessage = null;
    });

    try {
      final repository = PortfolioRepository();
      await repository.deleteHolding(widget.stock.portfolio.id);

      // Refresh providers
      ref.invalidate(portfolioProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(dashboardProvider);

      if (!mounted) return;
      Navigator.pop(context);

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('${widget.stock.portfolio.instrument} removed from portfolio.'),
          backgroundColor: const Color(0xFFFF5252),
        ),
      );
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _errorMessage = 'Failed to delete holding: $e';
        _loading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final bottomInset = MediaQuery.of(context).viewInsets.bottom;
    final displayName = SymbolUtils.getDisplayName(
      widget.stock.portfolio.instrument,
      dbCompanyName: widget.stock.portfolio.companyName,
    );
    final isProfit = _newNetPL >= 0;
    final toneColor = isProfit ? const Color(0xFF00E676) : const Color(0xFFFF5252);

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
                    Icons.edit_note_rounded,
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
                        'Edit ${widget.stock.portfolio.instrument}',
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
                  tooltip: 'Delete Holding',
                  onPressed: _loading ? null : _handleDelete,
                  icon: const Icon(
                    Icons.delete_outline_rounded,
                    color: Color(0xFFFF5252),
                    size: 22,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Live Price Pill
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              decoration: BoxDecoration(
                color: const Color(0xFF1E2024),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: const Color(0xFF282A30)),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text(
                    'Current Market Price (LTP)',
                    style: TextStyle(color: Color(0xFF8E929B), fontSize: 12, fontWeight: FontWeight.w600),
                  ),
                  Text(
                    Formatters.currency(_livePrice),
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 13,
                      fontWeight: FontWeight.w800,
                    ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Inputs
            Row(
              children: [
                // Qty
                Expanded(
                  child: TextField(
                    controller: _qtyController,
                    keyboardType: TextInputType.number,
                    style: const TextStyle(color: Colors.white),
                    decoration: _inputDecoration('Quantity', Icons.pin_outlined),
                    onChanged: (_) => setState(() {}),
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
                    onChanged: (_) => setState(() {}),
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppSpacing.md),

            // Live Calculated Preview
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: const Color(0xFF121316),
                borderRadius: BorderRadius.circular(12),
                border: Border.all(color: const Color(0xFF23252B)),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Invested', style: TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
                      Text(Formatters.currency(_newInvested), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Current Value', style: TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
                      Text(Formatters.currency(_newCurrentVal), style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700)),
                    ],
                  ),
                  const Divider(height: 14, color: Color(0xFF23252B)),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Estimated P&L', style: TextStyle(color: Color(0xFF8E929B), fontSize: 12, fontWeight: FontWeight.w600)),
                      Text(
                        '${Formatters.currency(_newNetPL, signed: true)} (${Formatters.percent(_newReturnPct, signed: true)})',
                        style: TextStyle(color: toneColor, fontSize: 13, fontWeight: FontWeight.w800),
                      ),
                    ],
                  ),
                ],
              ),
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

            // Buttons
            Row(
              children: [
                Expanded(
                  child: OutlinedButton(
                    style: OutlinedButton.styleFrom(
                      foregroundColor: const Color(0xFFFF5252),
                      side: const BorderSide(color: Color(0x66FF5252)),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: _loading ? null : _handleDelete,
                    child: const Text('Delete Stock', style: TextStyle(fontWeight: FontWeight.w700)),
                  ),
                ),
                const SizedBox(width: AppSpacing.md),
                Expanded(
                  flex: 2,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFFE5A93C),
                      foregroundColor: Colors.black,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12),
                      ),
                      padding: const EdgeInsets.symmetric(vertical: 13),
                    ),
                    onPressed: _loading ? null : _handleSave,
                    child: _loading
                        ? const SizedBox(
                            height: 20,
                            width: 20,
                            child: CircularProgressIndicator(strokeWidth: 2, color: Colors.black),
                          )
                        : const Text('Save Changes', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w800)),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
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
