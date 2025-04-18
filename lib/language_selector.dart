import 'package:flutter/material.dart';
import '../main.dart';

class LanguageSelector extends StatelessWidget {
  const LanguageSelector({super.key});

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.topRight,
      child: DropdownButton<Locale>(
        value: Localizations.localeOf(context),
        onChanged: (Locale? locale) {
          if (locale != null) {
            MyApp.setLocale(context, locale);
          }
        },
        items: const [
          DropdownMenuItem(
            value: Locale('en'),
            child: Text('English'),
          ),
          DropdownMenuItem(
            value: Locale('fr'),
            child: Text('Français'),
          ),
          DropdownMenuItem(
            value: Locale('ar'),
            child: Text('العربية'),
          ),
        ],
      ),
    );
  }
}
