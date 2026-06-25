import 'dart:convert';
import 'dart:math' as math;
import 'dart:typed_data';
import 'package:flutter/services.dart' show rootBundle;
import 'package:diacritic/diacritic.dart';
import 'package:flutter_litert/flutter_litert.dart'; // <- IMPORTACIÓN CAMBIADA

class ClassificationResult {
  final int categoryId;
  final double confidence;

  ClassificationResult({required this.categoryId, required this.confidence});
}

class ExpenseClassifierService {
  Interpreter? _interpreter; // Utiliza el Intérprete oficial de LiteRT
  Map<String, int> _vocabulary = {};
  List<double> _idfWeights = [];
  int _maxFeatures = 3000;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  final Map<int, int> _outputIndexToDatabaseId = {
    0: 1, // Alimentacion
    1: 2, // Transporte
    2: 3, // Estudios
    3: 4, // Entretenimiento
    4: 5, // Servicios
    5: 6, // Transferencias
    6: 7, // Vivienda
    7: 8, // Otros
  };

  Future<void> loadModel() async {
    try {
      // 1. Cargar el modelo usando la API oficial y estable de Google LiteRT
      _interpreter = await Interpreter.fromAsset(
        'assets/ml_models/classifier_model.tflite',
      );

      // 2. Cargar Vocabulario TF-IDF
      final String jsonString = await rootBundle.loadString(
        'assets/ml_models/tfidf_vocab.json',
      );
      final Map<String, dynamic> vocabData = json.decode(jsonString);

      _vocabulary = Map<String, int>.from(vocabData['vocabulary']);
      _idfWeights = List<double>.from(vocabData['idf_weights']);
      _maxFeatures = vocabData['max_features'] as int;

      _isInitialized = true;
      print(
        "🤖 [TESIS] ExpenseClassifierService cargado exitosamente con Google LiteRT.",
      );
    } catch (e) {
      _isInitialized = false;
      print("❌ Error initializing Expense Classifier Model: $e");
      rethrow;
    }
  }

  Future<ClassificationResult> classifyExpense(String description) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('Classifier model not initialized');
    }

    final Float32List inputVector = _transformTextToTfIdf(description);

    // LiteRT maneja listas nativas multidimensionales de forma robusta
    final input = [inputVector];
    final output = [List<double>.filled(8, 0.0)];

    // Inferencia directa en el hardware
    _interpreter!.run(input, output);

    final List<double> probabilities = output.first;

    int bestIndex = 0;
    double maxConfidence = -1.0;

    for (int i = 0; i < probabilities.length; i++) {
      if (probabilities[i] > maxConfidence) {
        maxConfidence = probabilities[i];
        bestIndex = i;
      }
    }

    if (maxConfidence < 0.25) {
      return ClassificationResult(categoryId: 8, confidence: maxConfidence);
    }

    final int finalCategoryId = _outputIndexToDatabaseId[bestIndex] ?? 8;
    return ClassificationResult(
      categoryId: finalCategoryId,
      confidence: maxConfidence,
    );
  }

  Float32List _transformTextToTfIdf(String text) {
    final Float32List vector = Float32List(_maxFeatures);
    if (text.isEmpty) return vector;

    final String cleanText = removeDiacritics(text.toLowerCase().trim());
    final List<String> unigrams = cleanText.split(RegExp(r'\s+'));

    final List<String> tokens = List<String>.from(unigrams);
    for (int i = 0; i < unigrams.length - 1; i++) {
      tokens.add("${unigrams[i]} ${unigrams[i + 1]}");
    }

    final Map<String, int> termCounts = {};
    for (final token in tokens) {
      if (_vocabulary.containsKey(token)) {
        termCounts[token] = (termCounts[token] ?? 0) + 1;
      }
    }

    termCounts.forEach((token, count) {
      final int? featureIdx = _vocabulary[token];
      if (featureIdx != null && featureIdx < _maxFeatures) {
        final double sublinearTf = 1.0 + math.log(count);
        final double idf = _idfWeights[featureIdx];
        vector[featureIdx] = sublinearTf * idf;
      }
    });

    double normSum = 0.0;
    for (int i = 0; i < _maxFeatures; i++) {
      normSum += vector[i] * vector[i];
    }

    if (normSum > 0) {
      final double l2Norm = math.sqrt(normSum);
      for (int i = 0; i < _maxFeatures; i++) {
        vector[i] = vector[i] / l2Norm;
      }
    }

    return vector;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

final ExpenseClassifierService expenseClassifierService =
    ExpenseClassifierService();
