import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/shared/presentation/widgets/common_widgets.dart';

class SplashOnboardingScreen extends StatelessWidget {
  const SplashOnboardingScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  SizedBox(height: 60),
                  Icon(Icons.account_balance_wallet, size: 80, color: AppTheme.primaryGreen),
                  SizedBox(height: 24),
                  Text(
                    'Finio',
                    style: TextStyle(
                      fontSize: 48,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.textPrimary,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Controla tus finanzas con inteligencia',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 16),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              Column(
                children: [
                  PrimaryButton(
                    text: 'Crear Cuenta',
                    onPressed: () => context.push('/signup'),
                  ),
                  SizedBox(height: 12),
                  SecondaryButton(
                    text: 'Ya tengo cuenta',
                    onPressed: () => context.push('/login'),
                  ),
                  SizedBox(height: 24),
                  Text(
                    'Al continuar, aceptas nuestros Términos de servicio y Política de privacidad',
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}
