import 'dart:typed_data';

import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

class BudgetRecommendationService {
  OrtSession? _session;
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModel() async {
    try {
      OrtEnv.instance.init();

      final modelData = await rootBundle.load(
        'assets/ml_models/recommendation_model.onnx',
      );
      final Uint8List modelBytes = modelData.buffer.asUint8List();

      final sessionOptions = OrtSessionOptions();
      _session = OrtSession.fromBuffer(modelBytes, sessionOptions);

      _isInitialized = true;
    } catch (_) {
      _isInitialized = false;
      rethrow;
    }
  }

  Future<double> recommendBudget({
    required int categoryId,
    required double totalSpent,
    required int transactionCount,
    required double averageSpent,
  }) async {
    if (!_isInitialized || _session == null) {
      throw Exception('Budget recommendation model not initialized');
    }

    // 🎯 REGLA DE ADAPTACIÓN EN EMULACIÓN MÓVIL (Mapeo exacto del dataset de Tesis)
    // Nuestro Bosque ONNX fue entrenado con bloques simulados de 15 transacciones por mes.
    // Necesitamos escalar los valores para que el modelo entienda un "Mes Estándar".

    // 1. Calcular cuántos "meses virtuales" de uso tiene acumulados el usuario en esta categoría
    double virtualMonths = transactionCount / 15.0;
    if (virtualMonths < 1.0)
      virtualMonths = 1.0; // Evitar divisiones sesgadas para usuarios nuevos

    // 2. Escalar montos acumulados a su equivalente mensual ponderado para el Bosque
    double monthlySpentInput = totalSpent / virtualMonths;
    double monthlyCountInput = transactionCount / virtualMonths;

    // Asegurar consistencia del ticket promedio ponderado
    double monthlyAverageInput = monthlyCountInput > 0
        ? monthlySpentInput / monthlyCountInput
        : 0.0;

    // 3. Empaquetar el vector flotante en el formato exacto de Python [Cat, Total, Cantidad, Promedio]
    final input = Float32List.fromList([
      categoryId.toDouble(),
      monthlySpentInput,
      monthlyCountInput,
      monthlyAverageInput,
    ]);

    // Crear el tensor de entrada esperado [1, 4] por ONNX Runtime
    final inputTensor = OrtValueTensor.createTensorWithDataList(input, [1, 4]);
    final runOptions = OrtRunOptions();

    // Ejecutar inferencia On-Device mediante el puente FFI nativo
    final outputs = _session!.run(runOptions, {'float_input': inputTensor});

    inputTensor.release();
    runOptions.release();

    final firstOutput = outputs.first;
    final data = firstOutput?.value;

    for (final o in outputs) {
      o?.release();
    }

    double predictedValue = 0.0;

    if (data is List) {
      final first = data.first;
      if (first is List && first.isNotEmpty && first.first is num) {
        predictedValue = (first.first as num).toDouble();
      } else if (first is num) {
        predictedValue = first.toDouble();
      }
    } else if (data is num) {
      predictedValue = data.toDouble();
    } else {
      throw Exception('Unexpected ONNX output format');
    }

    // 🛡️ SEGURO INTEGRAL DE LA APLICACIÓN (Mitigación de anomalías numéricas de Tesis)
    // Si el usuario es totalmente nuevo y el modelo devuelve valores por defecto,
    // o ante cualquier fluctuación matemática, acotamos la predicción al rango real.
    double lowerBound = totalSpent * 0.60;
    double upperBound = totalSpent * 0.95;

    // Si la predicción cae fuera del sentido común financiero, aplicamos la regla determinista base (Ahorro del 15%)
    if (predictedValue <= 0 || predictedValue > totalSpent) {
      predictedValue = totalSpent * 0.85;
    }

    // Acotar el presupuesto dentro de las fronteras lógicas de la investigación
    if (predictedValue < lowerBound) predictedValue = lowerBound;
    if (predictedValue > upperBound) predictedValue = upperBound;

    return double.parse(predictedValue.toStringAsFixed(2));
  }

  void dispose() {
    _session?.release();
    _session = null;
    OrtEnv.instance.release();
    _isInitialized = false;
  }
}

final BudgetRecommendationService budgetRecommendationService =
    BudgetRecommendationService();
