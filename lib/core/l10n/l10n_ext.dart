import 'package:flutter/widgets.dart';

import '../../l10n/app_localizations.dart';

extension L10n on BuildContext {
  AppLocalizations get t => AppLocalizations.of(this)!;
}
