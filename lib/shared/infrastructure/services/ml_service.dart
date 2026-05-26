import 'package:flutter/services.dart';
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _categoryClassifier;
  Interpreter? _budgetRecommender;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModels() async {
    try {
      _categoryClassifier = await Interpreter.fromAsset('assets/ml_models/category_classifier.tflite');
      _budgetRecommender = await Interpreter.fromAsset('assets/ml_models/budget_recommender.tflite');
      _isInitialized = true;
    } catch (e) {
      print('Error loading ML models: $e');
      _isInitialized = false;
    }
  }

  Future<String> classifyCategory(Map<String, dynamic> features) async {
    if (!_isInitialized || _categoryClassifier == null) {
      throw Exception('ML models not initialized');
    }

    try {
      var input = _prepareInput(features);
      var output = List<dynamic>(1);
      _categoryClassifier!.run(input, output);
      return _parseClassificationOutput(output);
    } catch (e) {
      print('Error in category classification: $e');
      return 'Otros';
    }
  }

  Future<double> recommendBudget(Map<String, dynamic> features) async {
    if (!_isInitialized || _budgetRecommender == null) {
      throw Exception('ML models not initialized');
    }

    try {
      var input = _prepareInput(features);
      var output = List<dynamic>(1);
      _budgetRecommender!.run(input, output);
      return _parsePredictionOutput(output);
    } catch (e) {
      print('Error in budget recommendation: $e');
      return 0.0;
    }
  }

  dynamic _prepareInput(Map<String, dynamic> features) {
    return [List<dynamic>.from(features.values)];
  }

  String _parseClassificationOutput(List<dynamic> output) {
    final categories = ['Comida', 'Transporte', 'Educación', 'Ocio', 'Otros'];
    if (output.isNotEmpty && output[0] is List) {
      final scores = List<double>.from(output[0]);
      int maxIndex = scores.indexWhere((e) => e == scores.reduce((a, b) => a > b ? a : b));
      return categories[maxIndex.clamp(0, categories.length - 1)];
    }
    return 'Otros';
  }

  double _parsePredictionOutput(List<dynamic> output) {
    if (output.isNotEmpty && output[0] is List) {
      final predictions = List<double>.from(output[0]);
      return predictions.isNotEmpty ? predictions.first : 0.0;
    }
    return 0.0;
  }

  void dispose() {
    _categoryClassifier?.close();
    _budgetRecommender?.close();
  }
}
