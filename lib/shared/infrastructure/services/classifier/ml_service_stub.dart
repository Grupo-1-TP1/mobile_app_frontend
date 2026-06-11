import 'dart:convert';

import 'package:flutter/services.dart' show rootBundle;

class MLService {
  bool _isInitialized = false;
  List<int> _labelIds = [];

  bool get isInitialized => _isInitialized;

  Future<void> loadModels() async {
    try {
      final labelsRaw =
          await rootBundle.loadString('assets/ml_models/labels.json');
      final parsedLabels = json.decode(labelsRaw) as List<dynamic>;
      _labelIds = parsedLabels.map((value) => (value as num).toInt()).toList();
      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
    }
  }

  Future<int> classifyCategory(String text) async {
    if (!_isInitialized) {
      return _labelIds.isNotEmpty ? _labelIds.first : -1;
    }

    return _labelIds.isNotEmpty ? _labelIds.first : -1;
  }

  Future<double> recommendBudget(Map<String, dynamic> features) async {
    return 0.0;
  }

  void dispose() {}
}

final MLService mlService = MLService();