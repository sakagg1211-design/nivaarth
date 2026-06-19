import '../models/dashboard_summary.dart';
import '../services/dashboard_engine.dart';

class DashboardRepository {
  final DashboardEngine _engine = DashboardEngine();

  Future<DashboardSummary> getDashboard() async {
    return _engine.buildDashboard();
  }
}