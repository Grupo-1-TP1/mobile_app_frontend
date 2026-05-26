class MLService {
  bool _isInitialized = false;

  bool get isInitialized => _isInitialized;

  Future<void> loadModels() async {
    try {
      _isInitialized = true;
    } catch (e) {
      _isInitialized = false;
    }
  }

  Future<String> classifyCategory(Map<String, dynamic> features) async {
    if (!_isInitialized) {
      throw Exception('ML models not initialized');
    }

    try {
      final categories = ['Comida', 'Transporte', 'Educación', 'Ocio', 'Otros'];
      return categories[0];
    } catch (e) {
      return 'Otros';
    }
  }

  Future<double> recommendBudget(Map<String, dynamic> features) async {
    if (!_isInitialized) {
      throw Exception('ML models not initialized');
    }

    try {
      return 1000.0;
    } catch (e) {
      return 0.0;
    }
  }

  void dispose() {
  }
}
