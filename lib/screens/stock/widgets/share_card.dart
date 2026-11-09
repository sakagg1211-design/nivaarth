import 'dart:typed_data';
import 'dart:ui' as ui;

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:share_plus/share_plus.dart';

import '../../../core/utils/allocation_math.dart';
import '../../../core/utils/stock_insights.dart';
import '../../../models/stock_score.dart';
import 'stock_radar_card.dart';

const _surface = Color(0xFF16171B);
const _muted = Color(0xFF8E929B);
const _gold = Color(0xFFE5A93C);
const _disclaimer = 'Sirf jaankari ke liye. Ye investment advice nahi hai.';

Widget _brand() => const Text('NIVAARTH',
    style: TextStyle(color: _gold, fontSize: 12, fontWeight: FontWeight.w800, letterSpacing: 2));

Widget _footer() => const Text(_disclaimer, style: TextStyle(color: _muted, fontSize: 10));

/// Preview of a card with a Share button. The image is made as soon as the preview is on screen:
/// browsers only allow sharing right after a tap, so the button must not wait for rendering.
Future<void> showShareCard(BuildContext context, {required Widget card, required String fileName}) {
  return showDialog<void>(
    context: context,
    builder: (_) => _ShareDialog(card: card, fileName: fileName),
  );
}

class _ShareDialog extends StatefulWidget {
  final Widget card;
  final String fileName;
  const _ShareDialog({required this.card, required this.fileName});

  @override
  State<_ShareDialog> createState() => _ShareDialogState();
}

class _ShareDialogState extends State<_ShareDialog> {
  final _boundary = GlobalKey();
  Uint8List? _png;
  String? _status; // shown here because a snackbar would sit behind this dialog

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _capture());
  }

  Future<void> _capture() async {
    await Future<void>.delayed(const Duration(milliseconds: 80));
    final box = _boundary.currentContext?.findRenderObject();
    if (box is! RenderRepaintBoundary) return;
    final image = await box.toImage(pixelRatio: 3);
    final data = await image.toByteData(format: ui.ImageByteFormat.png);
    image.dispose();
    if (mounted && data != null) setState(() => _png = data.buffer.asUint8List());
  }

  Future<void> _share() async {
    final bytes = _png;
    if (bytes == null) return;
    final file = XFile.fromData(bytes, mimeType: 'image/png', name: widget.fileName);
    try {
      await SharePlus.instance.share(ShareParams(files: [file], fileNameOverrides: [widget.fileName]));
      return;
    } catch (_) {}
    // Desktop browsers often have no share sheet: hand over the image as a download instead
    try {
      if (!kIsWeb) throw UnsupportedError('no share sheet');
      await file.saveTo(widget.fileName);
      if (mounted) setState(() => _status = 'Image download ho gayi.');
    } catch (_) {
      if (mounted) setState(() => _status = 'Share nahi ho paaya. Dobara try karo.');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(16),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            FittedBox(
              fit: BoxFit.scaleDown,
              child: RepaintBoundary(key: _boundary, child: SizedBox(width: 340, child: widget.card)),
            ),
            const SizedBox(height: 12),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                TextButton(
                  style: TextButton.styleFrom(foregroundColor: Colors.white),
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Band karo'),
                ),
                const SizedBox(width: 8),
                FilledButton.icon(
                  style: FilledButton.styleFrom(backgroundColor: _gold, foregroundColor: Colors.black),
                  onPressed: _png == null ? null : _share,
                  icon: const Icon(Icons.ios_share_rounded, size: 18),
                  label: const Text('Share'),
                ),
              ],
            ),
            if (_status != null) ...[
              const SizedBox(height: 8),
              Text(_status!, style: const TextStyle(color: Colors.white, fontSize: 12.5)),
            ],
          ],
        ),
      ),
    );
  }
}

Widget _shell(List<Widget> children) => Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(color: _surface, borderRadius: BorderRadius.circular(20)),
      child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisSize: MainAxisSize.min, children: children),
    );

/// A stock's score card. Holds scores and ratios only: no quantity, price paid or rupee value.
class StockShareCard extends StatelessWidget {
  final String symbol;
  final String companyName;
  final StockScore score;
  final List<StockBadge> badges;
  const StockShareCard({
    super.key,
    required this.symbol,
    required this.companyName,
    required this.score,
    required this.badges,
  });

  Widget _pillar(String label, int? v) => Expanded(
        child: Column(
          children: [
            Text(v?.toString() ?? '—',
                style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
            Text(label, style: const TextStyle(color: _muted, fontSize: 11)),
          ],
        ),
      );

  @override
  Widget build(BuildContext context) {
    final axes = StockInsights.radarAxes(score.scoreBreakdown);
    final updated = score.lastUpdated;
    return _shell([
      _brand(),
      const SizedBox(height: 12),
      Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(symbol, style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.w800)),
                Text(companyName,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: _muted, fontSize: 12)),
              ],
            ),
          ),
          Text(score.overallScore?.toString() ?? '—',
              style: const TextStyle(color: Colors.white, fontSize: 38, fontWeight: FontWeight.w800)),
          const Padding(
            padding: EdgeInsets.only(top: 12, left: 2),
            child: Text('/100', style: TextStyle(color: _muted, fontSize: 12)),
          ),
        ],
      ),
      const SizedBox(height: 14),
      Row(children: [
        _pillar('Quality', score.pillarScore('quality')),
        _pillar('Valuation', score.pillarScore('valuation')),
        _pillar('Momentum', score.pillarScore('momentum')),
      ]),
      if (StockInsights.canDrawRadar(axes)) ...[
        const SizedBox(height: 14),
        SizedBox(height: 210, child: ScoreRadar(axes: axes)),
      ],
      if (badges.isNotEmpty) ...[
        const SizedBox(height: 12),
        BadgeWrap(badges: badges),
      ],
      const SizedBox(height: 14),
      if (updated != null)
        Text('Score ${DateFormat('d MMM yyyy').format(updated.toLocal())}',
            style: const TextStyle(color: _muted, fontSize: 10)),
      _footer(),
    ]);
  }
}

/// How a portfolio splits, in percentages only.
class AllocationShareCard extends StatelessWidget {
  final String title;
  final List<AllocationSlice> slices;
  final Map<String, Color> colors;
  const AllocationShareCard({super.key, required this.title, required this.slices, required this.colors});

  @override
  Widget build(BuildContext context) {
    return _shell([
      _brand(),
      const SizedBox(height: 10),
      Text(title, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.w800)),
      const SizedBox(height: 14),
      SizedBox(
        height: 170,
        child: PieChart(
          PieChartData(
            sectionsSpace: 2,
            centerSpaceRadius: 54,
            startDegreeOffset: -90,
            pieTouchData: PieTouchData(enabled: false),
            sections: [
              for (final s in slices)
                PieChartSectionData(
                  value: s.percent,
                  color: colors[s.label] ?? _muted,
                  radius: 24,
                  showTitle: false,
                ),
            ],
          ),
          duration: Duration.zero,
        ),
      ),
      const SizedBox(height: 12),
      for (final s in slices)
        Padding(
          padding: const EdgeInsets.symmetric(vertical: 3),
          child: Row(
            children: [
              Container(
                width: 10,
                height: 10,
                decoration: BoxDecoration(color: colors[s.label] ?? _muted, borderRadius: BorderRadius.circular(3)),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: Text(s.label,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(color: Colors.white70, fontSize: 12.5)),
              ),
              Text('${s.percent.toStringAsFixed(1)}%',
                  style: const TextStyle(color: Colors.white, fontSize: 12.5, fontWeight: FontWeight.w700)),
            ],
          ),
        ),
      const SizedBox(height: 12),
      _footer(),
    ]);
  }
}
