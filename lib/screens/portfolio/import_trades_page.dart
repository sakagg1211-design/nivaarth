import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/import/zerodha_tradebook.dart';
import '../../core/utils/formatters.dart';
import '../../providers/dashboard_provider.dart';
import '../../providers/live_portfolio_provider.dart';
import '../../providers/portfolio_provider.dart';
import '../../providers/privacy_provider.dart';
import '../../services/tradebook_importer.dart';
import '../../core/l10n/l10n_ext.dart';

/// Zerodha Console tradebook CSV -> preview -> import. Nothing is written until "Import karo".
class ImportTradesPage extends ConsumerStatefulWidget {
  const ImportTradesPage({super.key});

  @override
  ConsumerState<ImportTradesPage> createState() => _ImportTradesPageState();
}

class _ImportTradesPageState extends ConsumerState<ImportTradesPage> {
  final _importer = TradebookImporter();
  ImportPlan? _plan;
  String? _fileName;
  String? _error;
  bool _busy = false;
  String? _progress;
  ImportResult? _result;

  Future<void> _pick() async {
    setState(() {
      _error = null;
      _result = null;
    });
    final picked = await FilePicker.pickFiles(
      type: FileType.custom,
      allowedExtensions: const ['csv', 'xlsx'],
    );
    if (picked.isEmpty) return;
    final file = picked.first;
    setState(() {
      _busy = true;
      _fileName = file.name;
      _plan = null;
    });
    try {
      // readAsBytes works on Android and on web (where there is no file path)
      final plan = await _importer.prepareFile(file.name, await file.readAsBytes());
      if (!mounted) return;
      setState(() => _plan = plan);
    } catch (e) {
      if (!mounted) return;
      setState(() => _error = e is FormatException ? (e.message == ZerodhaTradebook.notTradebook ? context.t.importNotZerodha : e.message) : e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run() async {
    final plan = _plan;
    if (plan == null) return;
    setState(() {
      _busy = true;
      _progress = context.t.importStarting;
    });
    final result = await _importer.run(plan, context.t, onProgress: (d, t) {
      if (mounted) setState(() => _progress = '$d / $t stocks');
    });
    ref.invalidate(portfolioProvider);
    ref.invalidate(livePortfolioProvider);
    ref.invalidate(dashboardProvider);
    if (!mounted) return;
    setState(() {
      _busy = false;
      _progress = null;
      _result = result;
      _plan = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    final hide = ref.watch(privacyModeProvider);
    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF0C0D10),
        foregroundColor: Colors.white,
        elevation: 0,
        title: Text(context.t.importTitle, style: TextStyle(fontWeight: FontWeight.w800)),
      ),
      body: SafeArea(
        child: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 760),
            child: ListView(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 24),
              children: [
                _card(
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(context.t.importHeading,
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      Text(
                        context.t.importSteps,
                        style: TextStyle(color: Color(0xFF8E929B), fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _busy ? null : _pick,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(_fileName == null ? context.t.importPickFile : context.t.importPickOther),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFE5A93C),
                          foregroundColor: Colors.black,
                        ),
                      ),
                      if (_fileName != null) ...[
                        const SizedBox(height: 8),
                        Text(_fileName!, style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
                      ],
                    ],
                  ),
                ),
                if (_busy) ...[
                  const SizedBox(height: 16),
                  const Center(child: CircularProgressIndicator(color: Color(0xFFE5A93C))),
                  if (_progress != null)
                    Padding(
                      padding: const EdgeInsets.only(top: 8),
                      child: Text(_progress!, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
                    ),
                ],
                if (_error != null) ...[
                  const SizedBox(height: 12),
                  _note(_error!, const Color(0xFFFF5252)),
                ],
                if (_result != null) ..._resultView(_result!),
                if (_plan != null && !_busy) ..._preview(_plan!, hide),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _resultView(ImportResult r) => [
        const SizedBox(height: 12),
        _note(
          context.t.importDone(r.imported, r.doneStocks.length) +
          (r.failedStocks.isEmpty ? '' : context.t.importFailed(r.failedStocks.length)),
          r.failedStocks.isEmpty ? const Color(0xFF00E676) : const Color(0xFFFFB74D),
        ),
        for (final e in r.failedStocks.entries)
          Padding(
            padding: const EdgeInsets.only(top: 6),
            child: Text('${e.key}: ${e.value}', style: const TextStyle(color: Color(0xFFFFB74D), fontSize: 12)),
          ),
      ];

  List<Widget> _preview(ImportPlan plan, bool hide) {
    final writable = TradebookImporter.writable(plan);
    final writeCount = writable.fold<int>(0, (n, s) => n + s.newTrades.length);
    String money(double v) => hide ? '••••' : Formatters.currency(v);
    String q(double v) => v == v.roundToDouble() ? v.toStringAsFixed(0) : v.toString();
    return [
      const SizedBox(height: 12),
      _card(Text(
        context.t.importSummary(plan.stocks.length, plan.newTradeCount) +
        (plan.duplicateCount > 0 ? context.t.importDuplicates(plan.duplicateCount) : '') +
        (plan.skipped.isNotEmpty ? context.t.importSkipped(plan.skipped.length) : ''),
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
      )),
      if (plan.unlisted.isNotEmpty) ...[
        const SizedBox(height: 8),
        _note(
            context.t.importUnlisted(plan.unlisted.map((s) => s.symbol).join(', ')) +
            context.t.importRenamed,
            const Color(0xFFFFB74D)),
      ],
      const SizedBox(height: 8),
      _note(context.t.importBonusNote,
          const Color(0xFF8E929B)),
      for (final s in plan.stocks.where((s) => s.listed && s.newTrades.isNotEmpty)) ...[
        const SizedBox(height: 10),
        _stockCard(s, money, q),
      ],
      const SizedBox(height: 16),
      ElevatedButton(
        onPressed: writeCount == 0 ? null : _run,
        style: ElevatedButton.styleFrom(
          backgroundColor: const Color(0xFF0C9F6E),
          foregroundColor: Colors.white,
          padding: const EdgeInsets.symmetric(vertical: 14),
        ),
        child: Text(writeCount == 0 ? context.t.importNothingNew : context.t.importConfirm(writeCount, writable.length)),
      ),
    ];
  }

  Widget _stockCard(StockImport s, String Function(double) money, String Function(double) q) {
    final err = s.errorFor(s.mode);
    final res = s.resultFor(s.mode);
    final cur = s.current;
    return _card(
      Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(s.symbol, style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
              ),
              Text(context.t.importStockLine(s.newTrades.length, s.duplicates > 0 ? ' (+${s.duplicates} skip)' : ''),
                  style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            cur == null ? context.t.importNotHeld : context.t.importHeldNow(q(cur.qty)),
            style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12),
          ),
          if (s.hasOpening) ...[
            const SizedBox(height: 8),
            SegmentedButton<ImportMode>(
              segments: [
                ButtonSegment(value: ImportMode.replaceOpening, label: Text(context.t.importFromBook)),
                ButtonSegment(value: ImportMode.addOnTop, label: Text(context.t.importOnlyNew)),
              ],
              selected: {s.mode},
              onSelectionChanged: (v) => setState(() => s.mode = v.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(height: 4),
            Text(
              s.mode == ImportMode.replaceOpening
                  ? context.t.importFromBookNote
                  : context.t.importOnlyNewNote,
              style: const TextStyle(color: Color(0xFF858A94), fontSize: 11),
            ),
          ],
          if (s.manualTrades > 0) ...[
            const SizedBox(height: 6),
            Text(
              context.t.importManualWarn(s.manualTrades),
              style: const TextStyle(color: Color(0xFFFFB74D), fontSize: 11),
            ),
          ],
          const SizedBox(height: 8),
          if (err != null)
            Text(context.t.importError(err), style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12))
          else if (res != null)
            Text(
              res.isClosed
                  ? context.t.importResultClosed(money(res.realizedPl))
                  : context.t.importResultOpen(q(res.qty), money(res.avgPrice), money(res.totalInvested)),
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF16171B),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: child,
      );

  Widget _note(String text, Color color) => Text(text, style: TextStyle(color: color, fontSize: 12));
}
