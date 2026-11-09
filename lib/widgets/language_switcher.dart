import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/l10n/l10n_ext.dart';
import '../core/theme/app_colors.dart';
import '../core/theme/app_typography.dart';
import '../providers/locale_provider.dart';

class LanguageSwitcher extends ConsumerWidget {
  const LanguageSwitcher({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final current = ref.watch(localeProvider);

    Widget choice(String label, Locale locale) {
      final selected = current == locale;
      return InkWell(
        onTap: () => ref.read(localeProvider.notifier).set(locale),
        borderRadius: BorderRadius.circular(8),
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: 48, minWidth: 48),
          child: Center(
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: selected ? AppColors.surfaceSecondary : Colors.transparent,
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: selected ? AppColors.accent : AppColors.line),
              ),
              child: Text(label,
                  style: AppTypography.caption.copyWith(
                    color: selected ? Colors.white : Colors.white70,
                    fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                  )),
            ),
          ),
        ),
      );
    }

    return Row(
      children: [
        Expanded(child: Text(context.t.menuLanguage, style: AppTypography.title.copyWith(color: Colors.white, fontSize: 15))),
        choice('English', englishLocale),
        const SizedBox(width: 8),
        choice('Hinglish', hinglishLocale),
      ],
    );
  }
}
