import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../models/dashboard_summary.dart';
import '../repositories/dashboard_repository.dart';

final dashboardRepositoryProvider =
    Provider<DashboardRepository>((ref) {
  return DashboardRepository();
});

final dashboardProvider =
    FutureProvider<DashboardSummary>((ref) async {
  final repository =
      ref.read(dashboardRepositoryProvider);

  return repository.getDashboard();
});