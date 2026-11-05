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
      setState(() => _error = e is FormatException ? e.message : e.toString().replaceFirst('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _busy = false);
    }
  }

  Future<void> _run() async {
    final plan = _plan;
    if (plan == null) return;
    setState(() {
      _busy = true;
      _progress = 'Shuru ho raha hai…';
    });
    final result = await _importer.run(plan, onProgress: (d, t) {
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
        title: const Text('Tradebook import', style: TextStyle(fontWeight: FontWeight.w800)),
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
                      const Text('Zerodha tradebook (CSV ya Excel)',
                          style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.w800)),
                      const SizedBox(height: 6),
                      const Text(
                        'Console → Reports → Tradebook → Segment: Equity → Download (CSV ya XLSX). '
                        'Pehle preview dikhega; "Import karo" dabane tak kuch save nahi hoga. '
                        'Ek hi file dobara daaloge to pehle wale trades dobara nahi judenge.',
                        style: TextStyle(color: Color(0xFF8E929B), fontSize: 12),
                      ),
                      const SizedBox(height: 12),
                      ElevatedButton.icon(
                        onPressed: _busy ? null : _pick,
                        icon: const Icon(Icons.upload_file_rounded),
                        label: Text(_fileName == null ? 'File chuno (CSV / XLSX)' : 'Doosri file chuno'),
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
          '${r.imported} trades import hue (${r.doneStocks.length} stocks).'
          '${r.failedStocks.isEmpty ? '' : ' ${r.failedStocks.length} stocks nahi hue, unka holding pehle jaisa hai:'}',
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
        '${plan.stocks.length} stocks · ${plan.newTradeCount} naye trades'
        '${plan.duplicateCount > 0 ? ' · ${plan.duplicateCount} pehle se imported (skip)' : ''}'
        '${plan.skipped.isNotEmpty ? ' · ${plan.skipped.length} rows skip (F&O / padhi nahi gayi)' : ''}',
        style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w700),
      )),
      if (plan.unlisted.isNotEmpty) ...[
        const SizedBox(height: 8),
        _note(
            'Ye symbols Nivaarth ki list me nahi mile, import nahi honge: ${plan.unlisted.map((s) => s.symbol).join(', ')}. '
            '(Naam badla ho, jaise demerger ke baad, to stock Add Holding se khud daalo.)',
            const Color(0xFFFFB74D)),
      ],
      const SizedBox(height: 8),
      _note('Bonus ya split tradebook me nahi hote. Aise stock ki quantity broker se alag dikhe to us stock ko check karo.',
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
        child: Text(writeCount == 0 ? 'Import ke liye kuch naya nahi' : 'Import karo ($writeCount trades, ${writable.length} stocks)'),
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
              Text('${s.newTrades.length} trades${s.duplicates > 0 ? ' (+${s.duplicates} skip)' : ''}',
                  style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12)),
            ],
          ),
          const SizedBox(height: 6),
          Text(
            cur == null ? 'Abhi portfolio me nahi' : 'Abhi: ${q(cur.qty)} shares',
            style: const TextStyle(color: Color(0xFF8E929B), fontSize: 12),
          ),
          if (s.hasOpening) ...[
            const SizedBox(height: 8),
            SegmentedButton<ImportMode>(
              segments: const [
                ButtonSegment(value: ImportMode.replaceOpening, label: Text('Tradebook se banao')),
                ButtonSegment(value: ImportMode.addOnTop, label: Text('Sirf naye jodo')),
              ],
              selected: {s.mode},
              onSelectionChanged: (v) => setState(() => s.mode = v.first),
              style: const ButtonStyle(visualDensity: VisualDensity.compact),
            ),
            const SizedBox(height: 4),
            Text(
              s.mode == ImportMode.replaceOpening
                  ? 'Purana opening holding hatega, holding sirf tradebook ke trades se banega.'
                  : 'Purana holding rahega, tradebook ke trades uske upar judenge (dhyan: purane buys do baar na judein).',
              style: const TextStyle(color: Color(0xFF6B6F78), fontSize: 11),
            ),
          ],
          if (s.manualTrades > 0) ...[
            const SizedBox(height: 6),
            Text(
              'Is stock ke ${s.manualTrades} trades aapne haath se bhi daale hain. Wahi trade tradebook me bhi '
              'ho to do baar judega — import ke baad Trade book me check karke dohraya trade hata do.',
              style: const TextStyle(color: Color(0xFFFFB74D), fontSize: 11),
            ),
          ],
          const SizedBox(height: 8),
          if (err != null)
            Text('Import nahi hoga: $err', style: const TextStyle(color: Color(0xFFFF5252), fontSize: 12))
          else if (res != null)
            Text(
              res.isClosed
                  ? 'Import ke baad: poora bika (Closed positions), realized ${money(res.realizedPl)}'
                  : 'Import ke baad: ${q(res.qty)} shares @ ${money(res.avgPrice)} · Invested ${money(res.totalInvested)}',
              style: const TextStyle(color: Colors.white, fontSize: 13, fontWeight: FontWeight.w600),
            ),
        ],
      ),
    );
  }

  Widget _card(Widget child) => Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: const Color(0xFF15171C),
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: Colors.white.withValues(alpha: .06)),
        ),
        child: child,
      );

  Widget _note(String text, Color color) => Text(text, style: TextStyle(color: color, fontSize: 12));
}
