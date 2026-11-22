import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/theme_mode_provider.dart';

/// Dark / Light / Phone, in the profile menu under the language switch (same look).
class ThemeSwitcher extends ConsumerWidget {
  const ThemeSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(themeModeProvider);
    final t = context.t;

    Widget choice(String label, AppThemeChoice value) {
      final selected = current == value;
      return InkWell(
        onTap: () => ref.read(themeModeProvider.notifier).set(value),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.surfaceSecondary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? AppColors.accent : AppColors.line),
              ),
              child: Text(label,
                  style: AppTypography.caption.copyWith(
                    color: selected ? AppColors.ink : AppColors.textSecondary,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: Text(t.themeLabel, style: AppTypography.title.copyWith(color: AppColors.ink, fontSize: 15))),
        choice(t.themeDark, AppThemeChoice.dark),
        const SizedBox(width: 6),
        choice(t.themeLight, AppThemeChoice.light),
        const SizedBox(width: 6),
        choice(t.themePhone, AppThemeChoice.phone),
      ],
    );
  }
}
