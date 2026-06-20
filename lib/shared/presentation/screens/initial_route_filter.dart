import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:mobile_app_frontend/shared/infrastructure/push_notifications_service.dart'; // Importante para las alertas
import 'package:http/http.dart'
    as http; // Usado para pasar el cliente a la sincronización

class InitialRouteFilter extends StatefulWidget {
  const InitialRouteFilter({Key? key}) : super(key: key);

  @override
  State<InitialRouteFilter> createState() => _InitialRouteFilterState();
}

class _InitialRouteFilterState extends State<InitialRouteFilter> {
  @override
  void initState() {
    super.initState();
    _evaluateNavigation();
  }

  Future<void> _evaluateNavigation() async {
    try {
      final user = await AuthDI.userRepository.getCurrentUser();

      if (user == null) {
        if (mounted) context.go('/onboarding');
        return;
      }

      final httpClient = http.Client();
      const baseUrl = 'https://finio-api.azurewebsites.net';

      await PushNotificationsService.instance.loadUserNotifications(
        user.id,
        httpClient,
        baseUrl,
      );

      final profile = await AuthDI.userRepository.getProfileByUserId(user.id);

      if (profile.useBiometrics) {
        if (mounted) context.go('/auth-checkpoint');
      } else {
        if (mounted) context.go('/home');
      }
    } catch (e) {
      if (mounted) context.go('/onboarding');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: const Center(
        child: CircularProgressIndicator(color: AppTheme.primaryGreen),
      ),
    );
  }
}
