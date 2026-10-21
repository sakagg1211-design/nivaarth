import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/utils/formatters.dart';
import '../../../providers/market_indices_provider.dart';
import '../index_detail_page.dart';

class MarketIndicesBar extends ConsumerWidget {
  const MarketIndicesBar({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final indicesAsync = ref.watch(marketIndicesProvider);

    return indicesAsync.when(
      loading: () => _buildShimmer(),
      error: (error, stack) => _buildFallback(),
      data: (indices) {
        return Row(
          children: [
            Expanded(
              child: _IndexPill(
                symbol: '^NSEI',
                name: indices.nifty.name,
                value: indices.nifty.value,
                pointChange: indices.nifty.pointChange,
                changePercent: indices.nifty.changePercent,
                dayHigh: indices.nifty.dayHigh,
                dayLow: indices.nifty.dayLow,
                isLive: indices.nifty.isLive,
              ),
            ),
            const SizedBox(width: 10),
            Expanded(
              child: _IndexPill(
                symbol: '^BSESN',
                name: indices.sensex.name,
                value: indices.sensex.value,
                pointChange: indices.sensex.pointChange,
                changePercent: indices.sensex.changePercent,
                dayHigh: indices.sensex.dayHigh,
                dayLow: indices.sensex.dayLow,
                isLive: indices.sensex.isLive,
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildShimmer() {
    return const Row(
      children: [
        Expanded(
          child: _IndexPill(
            symbol: '^NSEI',
            name: 'NIFTY 50',
            value: 22520.45,
            pointChange: 288.65,
            changePercent: 1.30,
            dayHigh: 22580.75,
            dayLow: 22294.75,
            isLive: false,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _IndexPill(
            symbol: '^BSESN',
            name: 'SENSEX',
            value: 72472.33,
            pointChange: 879.09,
            changePercent: 1.23,
            dayHigh: 72669.20,
            dayLow: 71739.49,
            isLive: false,
          ),
        ),
      ],
    );
  }

  Widget _buildFallback() {
    return const Row(
      children: [
        Expanded(
          child: _IndexPill(
            symbol: '^NSEI',
            name: 'NIFTY 50',
            value: 22520.45,
            pointChange: 288.65,
            changePercent: 1.30,
            dayHigh: 22580.75,
            dayLow: 22294.75,
            isLive: false,
          ),
        ),
        SizedBox(width: 10),
        Expanded(
          child: _IndexPill(
            symbol: '^BSESN',
            name: 'SENSEX',
            value: 72472.33,
            pointChange: 879.09,
            changePercent: 1.23,
            dayHigh: 72669.20,
            dayLow: 71739.49,
            isLive: false,
          ),
        ),
      ],
    );
  }
}

class _IndexPill extends StatelessWidget {
  final String symbol;
  final String name;
  final double value;
  final double pointChange;
  final double changePercent;
  final double dayHigh;
  final double dayLow;
  final bool isLive;

  const _IndexPill({
    required this.symbol,
    required this.name,
    required this.value,
    required this.pointChange,
    required this.changePercent,
    required this.dayHigh,
    required this.dayLow,
    required this.isLive,
  });

  @override
  Widget build(BuildContext context) {
    final isUp = pointChange >= 0;
    final tone = isUp ? const Color(0xFF00E676) : const Color(0xFFFF5252);
    final toneBg = isUp ? const Color(0x1F00E676) : const Color(0x26FF5252);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        borderRadius: BorderRadius.circular(14),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => IndexDetailPage(
                symbol: symbol,
                name: name,
              ),
            ),
          );
        },
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: const Color(0xFF16171B),
            borderRadius: BorderRadius.circular(14),
            border: Border.all(color: const Color(0xFF282A30)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              // Row 1: Index Name + Live Indicator + Arrow Hint
              Row(
                children: [
                  Text(
                    name,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w800,
                      color: Color(0xFF8E929B),
                      letterSpacing: 0.5,
                    ),
                  ),
                  if (isLive) ...[
                    const SizedBox(width: 5),
                    Container(
                      width: 5,
                      height: 5,
                      decoration: const BoxDecoration(
                        color: Color(0xFF00E676),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ],
                  const Spacer(),
                  const Icon(
                    Icons.arrow_forward_ios_rounded,
                    size: 9.5,
                    color: Color(0xFF636773),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Row 2: Big Index Value + Return Badge BESIDE IT!
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Text(
                    Formatters.number(value.round()),
                    style: const TextStyle(
                      fontSize: 16.5,
                      fontWeight: FontWeight.w900,
                      color: Colors.white,
                      letterSpacing: -0.3,
                    ),
                  ),
                  const SizedBox(width: 6),
                  Flexible(
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 2),
                        decoration: BoxDecoration(
                          color: toneBg,
                          borderRadius: BorderRadius.circular(5),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(
                              isUp ? Icons.arrow_drop_up_rounded : Icons.arrow_drop_down_rounded,
                              size: 14,
                              color: tone,
                            ),
                            Text(
                              '${isUp ? '+' : '-'}${pointChange.abs().toStringAsFixed(1)} (${changePercent.abs().toStringAsFixed(2)}%)',
                              style: TextStyle(
                                fontSize: 9.5,
                                fontWeight: FontWeight.w800,
                                color: tone,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 6),

              // Row 3: Day High (H) & Day Low (L) Range
              Row(
                children: [
                  Text(
                    'H: ${Formatters.number(dayHigh.round())}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFF00E676),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Text(
                    'L: ${Formatters.number(dayLow.round())}',
                    style: const TextStyle(
                      fontSize: 10,
                      fontWeight: FontWeight.w600,
                      color: Color(0xFFFF5252),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
