import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/routes/router.dart';
import 'package:mobile_app_frontend/shared/infrastructure/push_notifications_service.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/budget_recommendation/budget_recommendation_service_io.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/classifier/expense_classifier_service_io.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/storage_service.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'firebase_options.dart';

final classifierService = ExpenseClassifierService();
final budgetRecommendationService = BudgetRecommendationService();
final storageService = StorageService();

void main() async {
  // 1. Inicialización obligatoria de bindings nativos
  WidgetsFlutterBinding.ensureInitialized();
  
  // 2. Cargar servicios esenciales para el arranque de la app
  await storageService.init();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationsService.instance.initialize();
  
  // 3. Lanzar la interfaz de usuario inmediatamente (Carga instantánea)
  runApp(const MyApp());

  // 4. Inicializar los modelos de Machine Learning en segundo plano (No bloqueante)
  _initMachineLearningModels();
}

Future<void> _initMachineLearningModels() async {
  print("⏳ [ML Cloud/Edge] Inicializando modelos locales en segundo plano...");
  try {
    // Se ejecutan en paralelo para optimizar recursos de hilos básicos
    await Future.wait([
      classifierService.loadModel(),
      budgetRecommendationService.loadModel(),
    ]);
    print("🤖 [ML Cloud/Edge] Motores de inferencia locales listos para operar.");
  } catch (e) {
    print("❌ [ML Error] Fallo al inicializar los modelos en segundo plano: $e");
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      title: 'Finio',
      theme: AppTheme.darkTheme,
      routerConfig: AppRouter.router,
      debugShowCheckedModeBanner: false,
    );
  }
}