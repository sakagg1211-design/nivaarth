import 'package:flutter/widgets.dart';

/// Screen-width breakpoints shared by every screen.
///
/// Below [desktop] the app keeps its phone layout untouched (APK + iPhone web);
/// at or above it the shell switches to a sidebar and a centered content column.
class Breakpoints {
  Breakpoints._();

  static const double desktop = 1000;

  /// Widest the main content column grows on large monitors.
  static const double contentMaxWidth = 1200;

  static bool isDesktop(BuildContext context) =>
      MediaQuery.sizeOf(context).width >= desktop;
}
