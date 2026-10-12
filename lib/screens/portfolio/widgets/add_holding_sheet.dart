import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/portfolio_provider.dart';
import '../../../repositories/portfolio_repository.dart';
import '../../../services/backend_service.dart';

/// Modal bottom sheet dialog for manually adding a stock holding
class AddHoldingSheet extends ConsumerStatefulWidget {
  const AddHoldingSheet({super.key});

  @override
  ConsumerState<AddHoldingSheet> createState() => _AddHoldingSheetState();
}

class _AddHoldingSheetState extends ConsumerState<AddHoldingSheet> {
  final _instrumentController = TextEditingController();
  final _companyController = TextEditingController();
  final _qtyController = TextEditingController();
  final _avgPriceController = TextEditingController();

  bool _loading = false;
  String? _errorMessage;

  @override
  void dispose() {
    _instrumentController.dispose();
    _companyController.dispose();
    _qtyController.dispose();
    _avgPriceController.dispose();
    super.dispose();
  }

  Future<void> _handleSubmit() async {
    final instrument = _instrumentController.text.trim().toUpperCase();
    final company = _companyController.text.trim();
    final qty = int.tryParse(_qtyController.text.trim());
    final avgPrice = double.tryParse(_avgPriceController.text.trim());

    if (instrument.isEmpty) {
      setState(() => _errorMessage = 'Please enter stock symbol (e.g. RELIANCE, TCS).');
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
      final repository = PortfolioRepository();
      await repository.addHolding(
        instrument: instrument,
        companyName: company.isEmpty ? instrument : company,
        qty: qty,
        avgPrice: avgPrice,
      );

      // Trigger automation in background asynchronously without blocking UI
      BackendService().startAutomation().catchError((_) {});

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
              'Enter your position details to begin live price & AI intelligence tracking.',
              style: TextStyle(
                color: Color(0xFF8E929B),
                fontSize: 13,
              ),
            ),

            const SizedBox(height: AppSpacing.lg),

            // Symbol
            TextField(
              controller: _instrumentController,
              textCapitalization: TextCapitalization.characters,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Stock Symbol (e.g. INFY, TATAMOTORS)', Icons.tag_rounded),
              onChanged: (_) {
                if (_errorMessage != null) setState(() => _errorMessage = null);
              },
            ),

            const SizedBox(height: AppSpacing.md),

            // Company Name
            TextField(
              controller: _companyController,
              textCapitalization: TextCapitalization.words,
              style: const TextStyle(color: Colors.white),
              decoration: _inputDecoration('Company Name (Optional)', Icons.business_rounded),
            ),

            const SizedBox(height: AppSpacing.md),

            Row(
              children: [
                // Qty
                Expanded(
                  child: TextField(
                    controller: _qtyController,
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
