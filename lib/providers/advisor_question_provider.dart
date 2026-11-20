import 'package:flutter_riverpod/flutter_riverpod.dart';

/// A question waiting to be sent when NV Advisor opens (for example from the Pulse "kyun" button).
final advisorQuestionProvider = StateProvider<String?>((ref) => null);
