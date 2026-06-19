import 'dart:convert';
import 'package:diacritic/diacritic.dart';
import 'package:flutter/services.dart' show rootBundle;
import 'package:tflite_flutter/tflite_flutter.dart';

class MLService {
  Interpreter? _interpreter;
  Map<String, int> _wordIndex = {};
  List<int> _labelIds = [];
  

  int _inputLength = 12; 
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModels() async {
    try {
      _interpreter = await Interpreter.fromAsset(
        'assets/ml_models/classifier_model.tflite',
      );


      final inputShape = _interpreter!.getInputTensor(0).shape;
      if (inputShape.isNotEmpty) {

        _inputLength = inputShape.length >= 2 ? inputShape[1] : inputShape[0];
      }

      final wordIndexRaw = await rootBundle.loadString(
        'assets/ml_models/word_index.json',
      );
      final labelsRaw = await rootBundle.loadString(
        'assets/ml_models/labels.json',
      );

      final Map<String, dynamic> parsedWordIndex = Map<String, dynamic>.from(
        json.decode(wordIndexRaw) as Map,
      );
      _wordIndex = parsedWordIndex.map(
        (key, value) => MapEntry(key.toString(), (value as num).toInt()),
      );

      final parsedLabels = json.decode(labelsRaw) as List<dynamic>;
      _labelIds = parsedLabels.map((value) => (value as num).toInt()).toList();

      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
      // Imprime el error real en consola durante desarrollo para no ir a ciegas
      print("❌ Error cargando modelos de IA: $e"); 
      rethrow;
    }
  }

  List<int> _textToSequence(String text) {
    final normalized = removeDiacritics(text.toLowerCase());
    final tokens = RegExp(
      r"[a-z0-9]+",
    ).allMatches(normalized).map((match) => match.group(0)!).toList();

    // 🔥 CORRECCIÓN 2: Si la palabra no existe en el diccionario, se le asigna 1 (<OOV>)
    // El 0 se guarda única y exclusivamente para el espacio vacío (padding).
    final sequence = tokens.map((word) => _wordIndex[word] ?? 1).toList();

    // Recortar en caso de que el texto sea muy largo
    if (sequence.length > _inputLength) {
      return sequence.sublist(0, _inputLength);
    }

    // Rellenar con ceros (post-padding) para coincidir con la entrada de TensorFlow
    if (sequence.length < _inputLength) {
      final padded = List<int>.filled(_inputLength, 0);
      for (var i = 0; i < sequence.length; i++) {
        padded[i] = sequence[i];
      }
      return padded;
    }

    return sequence;
  }

  Object _buildInputBuffer(List<int> sequence) {
    final inputShape = _interpreter!.getInputTensor(0).shape;
    if (inputShape.length == 2) {
      // Retorna una lista anidada [[num1, num2...]] que representa la matriz [1, 12]
      return [sequence]; 
    }
    return sequence;
  }

  Object _buildOutputBuffer() {
    final outputShape = _interpreter!.getOutputTensor(0).shape;

    if (outputShape.length == 1) {
      return List<double>.filled(outputShape[0], 0.0);
    }

    final classes = _labelIds.isNotEmpty ? _labelIds.length : outputShape[1];
    return List.generate(1, (_) => List<double>.filled(classes, 0.0));
  }

  List<double> _extractScores(Object output) {
    if (output is List<double>) {
      return output;
    }

    final outer = output as List<dynamic>;
    if (outer.isEmpty) {
      return <double>[];
    }

    final first = outer.first;
    if (first is List<double>) {
      return first;
    }

    return (first as List<dynamic>)
        .map((value) => (value as num).toDouble())
        .toList();
  }

  Future<int> classifyCategory(String text) async {
    if (!_isInitialized || _interpreter == null) {
      throw Exception('ML models not initialized');
    }

    final sequence = _textToSequence(text);
    final input = _buildInputBuffer(sequence);
    final output = _buildOutputBuffer();

    _interpreter!.run(input, output);

    final scores = _extractScores(output);
    if (scores.isEmpty) {
      return _labelIds.isNotEmpty ? _labelIds.first : -1;
    }

    var bestIndex = 0;
    var maxConfidence = scores[0];

    for (var i = 1; i < scores.length; i++) {
      if (scores[i] > maxConfidence) {
        maxConfidence = scores[i];
        bestIndex = i;
      }
    }

    const double confidenceThreshold = 0.50;
    if (maxConfidence < confidenceThreshold) {
      return 8; 
    }

    // Retornar el ID de categoría directo del mapeo de etiquetas
    if (bestIndex >= 0 && bestIndex < _labelIds.length) {
      return _labelIds[bestIndex];
    }

    return _labelIds.isNotEmpty ? _labelIds.first : -1;
  }

  Future<double> recommendBudget(Map<String, dynamic> features) async {
    if (!_isInitialized) {
      throw Exception('ML models not initialized');
    }
    return 0.0;
  }

  void dispose() {
    _interpreter?.close();
    _interpreter = null;
    _isInitialized = false;
  }
}

final MLService mlService = MLService();