import 'package:flutter_riverpod/flutter_riverpod.dart';

/// Global privacy mode provider.
/// When true, financial values (current value, invested amount, P&L) are masked with bullets.
final privacyModeProvider = StateProvider<bool>((ref) => false);
