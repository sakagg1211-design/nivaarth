import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_radius.dart';
import '../../../core/theme/app_spacing.dart';
import '../../../core/theme/app_typography.dart';
import '../../../providers/alerts_provider.dart';
import '../../../providers/dashboard_provider.dart';
import '../../../providers/live_portfolio_provider.dart';
import '../../../providers/watchlist_provider.dart';
import '../../../services/auth_service.dart';
import '../../login/welcome_screen.dart';
import '../../notifications/notifications_page.dart';
import '../../../widgets/legal_disclaimer_sheet.dart';

class DashboardHeader extends ConsumerWidget {
  const DashboardHeader({super.key});

  String _getUserDisplayName() {
    final user = Supabase.instance.client.auth.currentUser;
    if (user != null) {
      final metaName = user.userMetadata?['name'] ?? user.userMetadata?['full_name'];
      if (metaName != null && metaName.toString().trim().isNotEmpty) {
        return metaName.toString().trim();
      }
      if (user.email != null && user.email!.contains('@')) {
        final emailPrefix = user.email!.split('@').first;
        return emailPrefix[0].toUpperCase() + emailPrefix.substring(1);
      }
    }
    return 'Investor';
  }

  void _showUserMenu(BuildContext context, WidgetRef ref) {
    final user = Supabase.instance.client.auth.currentUser;
    final email = user?.email ?? 'user@nivaarth.ai';

    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (modalContext) {
        return Material(
          color: AppColors.surface,
          borderRadius: const BorderRadius.vertical(
            top: Radius.circular(AppRadius.sheet),
          ),
          clipBehavior: Clip.antiAlias,
          child: Padding(
            padding: const EdgeInsets.fromLTRB(
              AppSpacing.xl,
              AppSpacing.lg,
              AppSpacing.xl,
              AppSpacing.xxl,
            ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Bottom sheet drag handle
              Center(
                child: Container(
                  height: 4,
                  width: 36,
                  decoration: BoxDecoration(
                    color: AppColors.lineStrong,
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                ),
              ),
              const SizedBox(height: AppSpacing.lg),

              // User Info Card
              Row(
                children: [
                  Container(
                    height: 46,
                    width: 46,
                    decoration: BoxDecoration(
                      color: AppColors.ink,
                      borderRadius: BorderRadius.circular(AppRadius.lg),
                    ),
                    child: Center(
                      child: Text(
                        _getUserDisplayName().substring(0, 1).toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: AppSpacing.md),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _getUserDisplayName(),
                          style: AppTypography.title,
                        ),
                        const SizedBox(height: 2),
                        Text(
                          email,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTypography.caption,
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 4,
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.surfaceSecondary,
                      borderRadius: BorderRadius.circular(AppRadius.pill),
                      border: Border.all(color: AppColors.line),
                    ),
                    child: Text(
                      'Beta',
                      style: AppTypography.caption.copyWith(
                        color: AppColors.accent,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: AppSpacing.xl),
              // Feedback & Issue Report Action
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0x1F3B82F6),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.chat_bubble_outline_rounded,
                    color: Color(0xFF3B82F6),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Share Feedback / Report Bug',
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'Direct channel to the engineering team',
                  style: AppTypography.caption,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white38,
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  _showFeedbackDialog(context);
                },
              ),

              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.line),
              const SizedBox(height: AppSpacing.sm),

              // Regulatory & Legal Disclaimers Action
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: const Color(0x1FE5A93C),
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.gavel_rounded,
                    color: Color(0xFFE5A93C),
                    size: 20,
                  ),
                ),
                title: Text(
                  'Compliance & Legal Disclaimers',
                  style: AppTypography.title.copyWith(
                    color: Colors.white,
                    fontSize: 15,
                  ),
                ),
                subtitle: const Text(
                  'SEBI non-advisory notice & platform terms',
                  style: AppTypography.caption,
                ),
                trailing: const Icon(
                  Icons.arrow_forward_ios_rounded,
                  size: 14,
                  color: Colors.white38,
                ),
                onTap: () {
                  Navigator.pop(modalContext);
                  LegalDisclaimerSheet.show(context);
                },
              ),

              const SizedBox(height: AppSpacing.sm),
              const Divider(color: AppColors.line),
              const SizedBox(height: AppSpacing.sm),

              // Logout Action
              ListTile(
                contentPadding: EdgeInsets.zero,
                leading: Container(
                  height: 38,
                  width: 38,
                  decoration: BoxDecoration(
                    color: AppColors.dangerSoft,
                    borderRadius: BorderRadius.circular(AppRadius.md),
                  ),
                  child: const Icon(
                    Icons.logout_rounded,
                    color: AppColors.danger,
                    size: 20,
                  ),
                ),
                title: Text(
                  'Log out',
                  style: AppTypography.title.copyWith(
                    color: AppColors.danger,
                    fontSize: 16,
                  ),
                ),
                subtitle: const Text(
                  'Sign out and return to welcome screen',
                  style: AppTypography.caption,
                ),
                onTap: () async {
                  Navigator.pop(modalContext);
                  await _handleLogout(context, ref);
                },
              ),

              const SizedBox(height: AppSpacing.lg),
              Center(
                // Read from pubspec.yaml at runtime so it never goes stale
                child: FutureBuilder<PackageInfo>(
                  future: PackageInfo.fromPlatform(),
                  builder: (context, snap) {
                    final info = snap.data;
                    return Text(
                      info == null
                          ? 'Nivaarth Friends Beta'
                          : 'Nivaarth Friends Beta v${info.version} (Build ${info.buildNumber})',
                      style: const TextStyle(
                        color: Color(0xFF757A85),
                        fontSize: 11,
                        fontWeight: FontWeight.w600,
                      ),
                    );
                  },
                ),
              ),
            ],
          ),
        ),
      );
    },
  );
  }

  void _showFeedbackDialog(BuildContext context) {
    final feedbackCtrl = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          backgroundColor: const Color(0xFF16171B),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
          title: const Row(
            children: [
              Icon(Icons.feedback_outlined, color: Color(0xFFE5A93C), size: 22),
              SizedBox(width: 10),
              Text('Friends Beta Feedback', style: TextStyle(color: Colors.white, fontSize: 17, fontWeight: FontWeight.w700)),
            ],
          ),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const Text(
                'Found a bug or have a suggestion? Let us know directly:',
                style: TextStyle(color: Color(0xFFD1D5DB), fontSize: 13),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: feedbackCtrl,
                maxLines: 4,
                style: const TextStyle(color: Colors.white, fontSize: 13),
                decoration: InputDecoration(
                  hintText: 'Describe the issue or idea...',
                  hintStyle: const TextStyle(color: Color(0xFF757A85)),
                  filled: true,
                  fillColor: const Color(0xFF111215),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFF282A30)),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: const BorderSide(color: Color(0xFFE5A93C)),
                  ),
                ),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(ctx),
              child: const Text('Cancel', style: TextStyle(color: Colors.white54)),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFFE5A93C),
                foregroundColor: Colors.black,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
              ),
              onPressed: () {
                Navigator.pop(ctx);
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(
                    content: Text('Thank you! Your feedback has been noted for the next release.'),
                    backgroundColor: Color(0xFF16171B),
                  ),
                );
              },
              child: const Text('Submit', style: TextStyle(fontWeight: FontWeight.w700)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleLogout(BuildContext context, WidgetRef ref) async {
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (dialogContext) => AlertDialog(
        backgroundColor: AppColors.surface,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.card),
        ),
        title: const Text('Log out of Nivaarth?'),
        content: const Text(
          'You will need to sign in again to view your private portfolio cockpit.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(dialogContext, false),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.danger,
              foregroundColor: Colors.white,
            ),
            onPressed: () => Navigator.pop(dialogContext, true),
            child: const Text('Log out'),
          ),
        ],
      ),
    );

    if (confirmed == true && context.mounted) {
      final authService = AuthService();
      await authService.signOut();

      // Clear in-memory Riverpod user state to prevent session cross-contamination
      ref.invalidate(dashboardProvider);
      ref.invalidate(livePortfolioProvider);
      ref.invalidate(watchlistProvider);
      ref.invalidate(alertsProvider);

      if (!context.mounted) return;

      Navigator.pushAndRemoveUntil(
        context,
        MaterialPageRoute(
          builder: (_) => const WelcomeScreen(),
        ),
        (route) => false,
      );
    }
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final hour = DateTime.now().hour;
    final displayName = _getUserDisplayName();
    final alertsAsync = ref.watch(alertsProvider);
    final unreadCount = alertsAsync.value?.where((a) => !a.isRead).length ?? 0;

    String greeting;
    if (hour < 12) {
      greeting = 'Good morning,';
    } else if (hour < 17) {
      greeting = 'Good afternoon,';
    } else {
      greeting = 'Good evening,';
    }

    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: 42,
          width: 42,
          margin: const EdgeInsets.only(right: 12),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFE5A93C).withValues(alpha: 0.20),
                blurRadius: 10,
                offset: const Offset(0, 3),
              ),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Image.asset(
              'assets/images/logo.jpg',
              fit: BoxFit.cover,
            ),
          ),
        ),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                greeting,
                style: const TextStyle(
                  color: Color(0xFF9E9E9E),
                  fontSize: 14,
                  fontWeight: FontWeight.w400,
                  letterSpacing: -0.2,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                displayName,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.w800,
                  letterSpacing: -0.5,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 12),
        // Action 1: Info / Profile Menu
        _HeaderIconButton(
          icon: Icons.info_outline_rounded,
          tooltip: 'Profile & Details',
          onTap: () => _showUserMenu(context, ref),
        ),
        const SizedBox(width: 8),
        // Action 2: Notifications
        _HeaderIconButton(
          icon: unreadCount > 0
              ? Icons.notifications_active_rounded
              : Icons.notifications_none_rounded,
          tooltip: 'Notifications',
          hasBadge: unreadCount > 0,
          badgeCount: unreadCount,
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (_) => const NotificationsPage()),
            );
          },
        ),
        const SizedBox(width: 8),
        // Action 3: Logout
        _HeaderIconButton(
          icon: Icons.logout_rounded,
          tooltip: 'Log out',
          onTap: () => _handleLogout(context, ref),
        ),
      ],
    );
  }
}

class _HeaderIconButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback onTap;
  final bool hasBadge;
  final int badgeCount;

  const _HeaderIconButton({
    required this.icon,
    required this.tooltip,
    required this.onTap,
    this.hasBadge = false,
    this.badgeCount = 0,
  });

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: tooltip,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(20),
        child: Stack(
          clipBehavior: Clip.none,
          children: [
            Container(
              width: 38,
              height: 38,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: const Color(0xFF1E2024),
                border: Border.all(
                  color: hasBadge ? const Color(0xFFE5A93C).withValues(alpha: 0.6) : const Color(0xFF2C2F36),
                  width: 1,
                ),
              ),
              child: Icon(
                icon,
                size: 19,
                color: hasBadge ? const Color(0xFFE5A93C) : const Color(0xFFC7CDD6),
              ),
            ),
            if (hasBadge)
              Positioned(
                top: -2,
                right: -2,
                child: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1.5),
                  decoration: BoxDecoration(
                    color: const Color(0xFFFF5252),
                    shape: badgeCount > 9 ? BoxShape.rectangle : BoxShape.circle,
                    borderRadius: badgeCount > 9 ? BorderRadius.circular(10) : null,
                    border: Border.all(color: const Color(0xFF111215), width: 1.5),
                  ),
                  constraints: const BoxConstraints(minWidth: 16, minHeight: 16),
                  child: Center(
                    child: Text(
                      badgeCount > 9 ? '9+' : '$badgeCount',
                      style: const TextStyle(
                        color: Colors.white,
                        fontSize: 9,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
