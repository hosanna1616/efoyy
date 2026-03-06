import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:efoy/providers/language_provider.dart';

class LanguageToggle extends ConsumerWidget {
  const LanguageToggle({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final currentLocale = ref.watch(languageProvider);
    final isAmharic = currentLocale.languageCode == 'am';

    return IconButton(
      icon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            isAmharic ? 'አማ' : 'ENG',
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
          const SizedBox(width: 4),
          Icon(
            isAmharic ? Icons.language : Icons.translate,
            size: 20,
          ),
        ],
      ),
      tooltip: isAmharic ? 'Switch to English' : 'ወደ አማርኛ ቀይር',
      onPressed: () {
        ref.read(languageProvider.notifier).toggleLanguage();
      },
    );
  }
}




