import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../core/providers/locale_provider.dart';
import '../../generated/l10n.dart';

class LanguageToggleButton extends ConsumerWidget {
  final bool showText;
  final double iconSize;

  const LanguageToggleButton({
    super.key,
    this.showText = true,
    this.iconSize = 20,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final locale = ref.watch(localeProvider);
    final localeNotifier = ref.read(localeProvider.notifier);
    
    return InkWell(
      onTap: () => localeNotifier.toggleLanguage(),
      borderRadius: BorderRadius.circular(8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          border: Border.all(
            color: Theme.of(context).colorScheme.outline.withValues(alpha: 0.3),
          ),
          borderRadius: BorderRadius.circular(8),
        ),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              Icons.language,
              size: iconSize,
              color: Theme.of(context).colorScheme.primary,
            ),
            if (showText) ...[
              const SizedBox(width: 8),
              Text(
                locale.languageCode == 'ar' 
                    ? S.of(context).english 
                    : S.of(context).arabic,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                  color: Theme.of(context).colorScheme.primary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ],
        ),
      ),
    );
  }
}
