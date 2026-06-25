import 'dart:typed_data';
import 'package:flutter/foundation.dart'; // Requerido para la función 'compute'
import 'package:flutter/services.dart' show rootBundle;
import 'package:onnxruntime/onnxruntime.dart';

/// Clase contenedora para transferir de manera segura los parámetros al Isolate secundario
class _BudgetIsolateInput {
  final double monthlyIncome;
  final Map<String, double> previousLimits;
  final Map<String, double> currentExpenses;
  final ByteData modelBytes;

  _BudgetIsolateInput({
    required this.monthlyIncome,
    required this.previousLimits,
    required this.currentExpenses,
    required this.modelBytes,
  });
}

class BudgetRecommendationService {
  bool _isInitialized = false;
  bool get isInitialized => _isInitialized;

  // El orden estricto de las columnas que espera la matriz de entrada de tu regresor
  final List<String> _categories = [
    "alimentacion",
    "transporte",
    "estudios",
    "entretenimiento",
    "servicios",
    "transferencias",
    "vivienda",
    "otros",
  ];

  /// Precarga los bytes del modelo en memoria para agilizar las llamadas posteriores
  Future<void> loadModel() async {
    try {
      OrtEnv.instance.init();
      // Solo validamos que el asset exista y responda correctamente
      await rootBundle.load('assets/ml_models/recommendation_model.onnx');
      _isInitialized = true;
      print(
        "🎯 [ONNX] Binario de recomendación verificado y listo para Isolates.",
      );
    } catch (e) {
      _isInitialized = false;
      print("❌ Error cargando especificaciones de ONNX: $e");
      rethrow;
    }
  }

  /// Genera recomendaciones presupuestales delegando el cómputo pesado
  /// a un hilo secundario de hardware para evitar congelar la UI.
  Future<Map<String, double>> recommendAllBudgets({
    required double monthlyIncome,
    required Map<String, double> previousLimits,
    required Map<String, double> currentExpenses,
  }) async {
    if (!_isInitialized) {
      throw Exception('Budget recommendation model not initialized');
    }

    // Cargar los bytes frescos del archivo para pasarlos de forma aislada al hilo
    final modelData = await rootBundle.load(
      'assets/ml_models/recommendation_model.onnx',
    );

    final isolateInput = _BudgetIsolateInput(
      monthlyIncome: monthlyIncome,
      previousLimits: previousLimits,
      currentExpenses: currentExpenses,
      modelBytes: modelData,
    );

    // 'compute' genera el hilo (Isolate), procesa y destruye el hilo de forma transparente
    return await compute(_executeInferenceInIsolate, isolateInput);
  }

  /// ESTA FUNCIÓN SE EJECUTA EN UN ISOLATE SECUNDARIO (HILO INDEPENDIENTE)
  /// Al no tocar el Main Isolate, la interfaz gráfica sigue respondiendo a 60 FPS estables.
  static Map<String, double> _executeInferenceInIsolate(
    _BudgetIsolateInput data,
  ) {
    // Inicializar el entorno nativo de ONNX dentro del nuevo contexto de hilo
    OrtEnv.instance.init();
    final sessionOptions = OrtSessionOptions();

    final Uint8List modelBytes = data.modelBytes.buffer.asUint8List();
    final session = OrtSession.fromBuffer(modelBytes, sessionOptions);

    final List<String> categoriesOrder = [
      "alimentacion",
      "transporte",
      "estudios",
      "entretenimiento",
      "servicios",
      "transferencias",
      "vivienda",
      "otros",
    ];

    // 1. Construir el vector estructurado de 17 características (Features de entrada)
    final List<double> featureList = [data.monthlyIncome];

    for (final category in categoriesOrder) {
      final double prevLimit = data.previousLimits[category] ?? 0.0;
      final double currExpense = data.currentExpenses[category] ?? 0.0;
      featureList.add(prevLimit);
      featureList.add(currExpense);
    }

    // 2. Conversión a Float32List y creación del Tensor multidimensional [1, 17]
    final Float32List inputData = Float32List.fromList(featureList);
    final inputTensor = OrtValueTensor.createTensorWithDataList(inputData, [
      1,
      17,
    ]);
    final runOptions = OrtRunOptions();

    // 3. Ejecutar inferencia síncrona dentro del Isolate protegido
    final outputs = session.run(runOptions, {'float_input': inputTensor});

    // 4. Liberación inmediata de punteros de memoria C++ para evitar memory leaks en el móvil
    inputTensor.release();
    runOptions.release();

    final firstOutput = outputs.first;
    final dynamic rawData = firstOutput?.value;

    for (final output in outputs) {
      output?.release();
    }

    // Cerrar la sesión del Isolate antes de retornar los datos limpios
    session.release();
    sessionOptions.release();
    OrtEnv.instance.release();

    final Map<String, double> recommendations = {};

    // 5. Mapeo y procesamiento de la matriz MultiOutput devuelta
    if (rawData is List && rawData.isNotEmpty) {
      final List<dynamic> batchResult = rawData.first as List<dynamic>;

      if (batchResult.length == categoriesOrder.length) {
        for (int i = 0; i < categoriesOrder.length; i++) {
          double predictedValue = (batchResult[i] as num).toDouble();

          // Filtro para limpiar ruidos marginales negativos del Random Forest
          if (predictedValue < 0) predictedValue = 0.0;

          // Redondeo estricto a 2 decimales para consistencia visual en la UI
          recommendations[categoriesOrder[i]] = double.parse(
            predictedValue.toStringAsFixed(2),
          );
        }
      } else {
        throw Exception('ONNX output shape does not match the 8 categories.');
      }
    } else {
      throw Exception(
        'Unexpected response structure from the ONNX engine inside Isolate.',
      );
    }

    return recommendations;
  }

  void dispose() {
    _isInitialized = false;
  }
}

final BudgetRecommendationService budgetRecommendationService =
    BudgetRecommendationService();
