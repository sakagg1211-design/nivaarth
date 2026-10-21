import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/theme/app_radius.dart';
import '../../core/theme/app_spacing.dart';
import '../../models/user_alert.dart';
import '../../providers/alerts_provider.dart';

class NotificationsPage extends ConsumerStatefulWidget {
  const NotificationsPage({super.key});

  @override
  ConsumerState<NotificationsPage> createState() => _NotificationsPageState();
}

class _NotificationsPageState extends ConsumerState<NotificationsPage> {
  String _selectedFilter = 'All';

  @override
  Widget build(BuildContext context) {
    final alertsAsync = ref.watch(alertsProvider);

    return Scaffold(
      backgroundColor: const Color(0xFF0C0D10),
      appBar: AppBar(
        backgroundColor: const Color(0xFF111215),
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 20, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Alerts & Notifications',
              style: TextStyle(
                color: Colors.white,
                fontSize: 18,
                fontWeight: FontWeight.w700,
              ),
            ),
            Text(
              'Real-time NV Intelligence feeds',
              style: TextStyle(
                color: Colors.white.withValues(alpha: 0.5),
                fontSize: 12,
              ),
            ),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Mark all as read',
            icon: const Icon(Icons.done_all_rounded, color: Color(0xFFE5A93C), size: 22),
            onPressed: () {
              ref.read(alertsProvider.notifier).markAllAsRead();
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('All alerts marked as read.'),
                  duration: Duration(seconds: 1),
                ),
              );
            },
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh_rounded, color: Colors.white70, size: 22),
            onPressed: () {
              ref.read(alertsProvider.notifier).fetchAlerts();
            },
          ),
          const SizedBox(width: 8),
        ],
      ),
      body: Column(
        children: [
          // Filter Tabs
          _buildFilterBar(),

          // Alerts List
          Expanded(
            child: alertsAsync.when(
              loading: () => const Center(
                child: CircularProgressIndicator(
                  color: Color(0xFFE5A93C),
                  strokeWidth: 2,
                ),
              ),
              error: (err, _) => Center(
                child: Text(
                  'Failed to load notifications:\n$err',
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white54),
                ),
              ),
              data: (alerts) {
                final filtered = _filterAlerts(alerts);

                if (filtered.isEmpty) {
                  return _buildEmptyState();
                }

                return RefreshIndicator(
                  color: const Color(0xFFE5A93C),
                  backgroundColor: const Color(0xFF1A1C20),
                  onRefresh: () => ref.read(alertsProvider.notifier).fetchAlerts(),
                  child: ListView.separated(
                    padding: const EdgeInsets.all(AppSpacing.lg),
                    itemCount: filtered.length,
                    separatorBuilder: (context, index) => const SizedBox(height: AppSpacing.md),
                    itemBuilder: (context, index) {
                      final item = filtered[index];
                      return _buildAlertCard(item);
                    },
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['All', 'Risks', 'Scores', 'System'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg, vertical: AppSpacing.sm),
      decoration: const BoxDecoration(
        color: Color(0xFF111215),
        border: Border(
          bottom: BorderSide(color: Color(0xFF23252B), width: 1),
        ),
      ),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: filters.map((f) {
            final isSelected = _selectedFilter == f;
            return Padding(
              padding: const EdgeInsets.only(right: 8),
              child: ChoiceChip(
                label: Text(f),
                selected: isSelected,
                selectedColor: const Color(0xFFE5A93C),
                backgroundColor: const Color(0xFF1E2024),
                labelStyle: TextStyle(
                  color: isSelected ? Colors.black : Colors.white70,
                  fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
                  fontSize: 12,
                ),
                side: BorderSide(
                  color: isSelected ? const Color(0xFFE5A93C) : const Color(0xFF2C2F36),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.pill),
                ),
                onSelected: (selected) {
                  if (selected) {
                    setState(() => _selectedFilter = f);
                  }
                },
              ),
            );
          }).toList(),
        ),
      ),
    );
  }

  List<UserAlert> _filterAlerts(List<UserAlert> alerts) {
    if (_selectedFilter == 'Risks') {
      return alerts.where((a) => a.type == AlertType.portfolioRisk).toList();
    } else if (_selectedFilter == 'Scores') {
      return alerts.where((a) => a.type == AlertType.nvScore || a.type == AlertType.priceAlert).toList();
    } else if (_selectedFilter == 'System') {
      return alerts.where((a) => a.type == AlertType.system).toList();
    }
    return alerts;
  }

  Widget _buildAlertCard(UserAlert alert) {
    Color accentColor;
    IconData icon;

    switch (alert.severity) {
      case AlertSeverity.success:
        accentColor = const Color(0xFF00C853);
        icon = Icons.trending_up_rounded;
        break;
      case AlertSeverity.warning:
        accentColor = const Color(0xFFFFB300);
        icon = Icons.warning_amber_rounded;
        break;
      case AlertSeverity.danger:
        accentColor = const Color(0xFFFF5252);
        icon = Icons.error_outline_rounded;
        break;
      case AlertSeverity.info:
        accentColor = const Color(0xFF29B6F6);
        icon = Icons.info_outline_rounded;
        break;
    }

    return InkWell(
      onTap: () {
        ref.read(alertsProvider.notifier).markAsRead(alert.id);
      },
      borderRadius: BorderRadius.circular(14),
      child: Container(
        padding: const EdgeInsets.all(AppSpacing.md),
        decoration: BoxDecoration(
          color: alert.isRead ? const Color(0xFF15171B) : const Color(0xFF1C1E24),
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: alert.isRead
                ? const Color(0xFF26282E)
                : accentColor.withValues(alpha: 0.35),
            width: alert.isRead ? 1 : 1.5,
          ),
          boxShadow: alert.isRead
              ? []
              : [
                  BoxShadow(
                    color: accentColor.withValues(alpha: 0.08),
                    blurRadius: 10,
                    offset: const Offset(0, 3),
                  ),
                ],
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Icon container
            Container(
              height: 40,
              width: 40,
              margin: const EdgeInsets.only(right: 12),
              decoration: BoxDecoration(
                color: accentColor.withValues(alpha: 0.12),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(icon, color: accentColor, size: 22),
            ),

            // Content
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Text(
                          alert.title,
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: alert.isRead ? FontWeight.w600 : FontWeight.w700,
                          ),
                        ),
                      ),
                      if (!alert.isRead)
                        Container(
                          width: 8,
                          height: 8,
                          decoration: BoxDecoration(
                            color: accentColor,
                            shape: BoxShape.circle,
                          ),
                        ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text(
                    alert.message,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.72),
                      fontSize: 13,
                      height: 1.35,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    _formatTime(alert.createdAt),
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.38),
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  String _formatTime(DateTime dt) {
    final diff = DateTime.now().difference(dt);
    if (diff.inMinutes < 1) return 'Just now';
    if (diff.inMinutes < 60) return '${diff.inMinutes}m ago';
    if (diff.inHours < 24) return '${diff.inHours}h ago';
    return '${diff.inDays}d ago';
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Container(
            height: 72,
            width: 72,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: const Color(0xFF1E2024),
              border: Border.all(color: const Color(0xFF2C2F36)),
            ),
            child: const Icon(
              Icons.notifications_off_outlined,
              size: 32,
              color: Color(0xFF757A85),
            ),
          ),
          const SizedBox(height: AppSpacing.lg),
          const Text(
            'No Alerts in this Category',
            style: TextStyle(
              color: Colors.white,
              fontSize: 16,
              fontWeight: FontWeight.w600,
            ),
          ),
          const SizedBox(height: 4),
          const Text(
            'Your portfolio is stable and within risk limits.',
            style: TextStyle(color: Colors.white54, fontSize: 13),
          ),
        ],
      ),
    );
  }
}
