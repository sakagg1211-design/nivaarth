import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';
import '../l10n/app_localizations.dart';
import 'locale_provider.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final repository =
      ref.read(dashboardRepositoryProvider);

  return repository.getDashboard(lookupAppLocalizations(ref.watch(localeProvider)));
});