import 'package:flutter/material.dart';

class LanguageSelector extends StatelessWidget {
  final String currentLanguage;
  final Function(String) onLanguageChanged;

  const LanguageSelector({
    super.key,
    required this.currentLanguage,
    required this.onLanguageChanged,
  });

  @override
  Widget build(BuildContext context) {
    return DropdownButton<String>(
      value: currentLanguage,
      icon: const Icon(Icons.translate, color: Colors.white, size: 20),
      underline: Container(),
      dropdownColor: const Color(0xFFFF7F50),
      style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
      items: <String>['Mandarin', 'English'].map((String value) {
        return DropdownMenuItem<String>(
          value: value,
          child: Text(value),
        );
      }).toList(),
      onChanged: (newValue) {
        if (newValue != null) {
          onLanguageChanged(newValue);
        }
      },
    );
  }
}