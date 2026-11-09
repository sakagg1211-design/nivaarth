import '../models/dashboard_summary.dart';
import '../services/dashboard_engine.dart';
import '../l10n/app_localizations.dart';

class DashboardRepository {
  final DashboardEngine _engine = DashboardEngine();

  Future<DashboardSummary> getDashboard(AppLocalizations t) async {
    return _engine.buildDashboard(t);
  }
}