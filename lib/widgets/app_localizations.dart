import 'package:flutter/material.dart';

class AppLocalizations {
  static const Map<String, Map<String, String>> _localizedStrings = {
    'en': {
      'dashboard': 'Dashboard',
      'selectLanguage': 'Select Language',
      'captureImage': 'Capture Image',
      'locationCaptured': 'Location captured successfully',
      'enterDescription': 'Enter description',
      'submitReport': 'SUBMIT REPORT',
    },
    'es': {
      'dashboard': 'Tablero',
      'selectLanguage': 'Seleccionar idioma',
      'captureImage': 'Capturar imagen',
      'locationCaptured': 'Ubicación capturada correctamente',
      'enterDescription': 'Ingresar descripción',
      'submitReport': 'ENVIAR INFORME',
    },
    'fr': {
      'dashboard': 'Tableau de bord',
      'selectLanguage': 'Choisir la langue',
      'captureImage': 'Capturer l\'image',
      'locationCaptured': 'Emplacement capturé avec succès',
      'enterDescription': 'Entrer la description',
      'submitReport': 'SOUMETTRE LE RAPPORT',
    },
    // You can add more languages here
  };

  static String? translate(BuildContext context, String key) {
    final locale = Localizations.localeOf(context).languageCode;
    return _localizedStrings[locale]?[key];
  }
}
