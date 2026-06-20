import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/routes/router.dart';
import 'package:mobile_app_frontend/shared/infrastructure/push_notifications_service.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/classifier/ml_service_io.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/storage_service.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'firebase_options.dart';

final mlService = MLService();
final storageService = StorageService();

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await storageService.init();
  await mlService.loadModels();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  await PushNotificationsService.instance.initialize();
  runApp(const MyApp());
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
