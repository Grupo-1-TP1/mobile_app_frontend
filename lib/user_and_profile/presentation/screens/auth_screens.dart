import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/shared/presentation/widgets/common_widgets.dart';

class SignUpScreen extends StatefulWidget {
  const SignUpScreen({Key? key}) : super(key: key);

  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool acceptedTerms = false;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(backgroundColor: AppTheme.darkBg, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Text(
                  'Crear Cuenta',
                  style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary),
                ),
                SizedBox(height: 24),
                CustomTextField(label: 'Nombre', hint: 'Tu nombre completo', controller: nameController),
                SizedBox(height: 16),
                CustomTextField(label: 'Correo Electrónico', hint: 'tu@email.com', controller: emailController, keyboardType: TextInputType.emailAddress),
                SizedBox(height: 16),
                CustomTextField(label: 'Contraseña', hint: '••••••••', controller: passwordController, obscureText: true),
                SizedBox(height: 16),
                Row(
                  children: [
                    Checkbox(
                      value: acceptedTerms,
                      onChanged: (v) => setState(() => acceptedTerms = v ?? false),
                      fillColor: MaterialStateProperty.all(AppTheme.primaryGreen),
                    ),
                    Expanded(
                      child: Text(
                        'He leído y acepto los Términos de servicio y Política de privacidad',
                        style: TextStyle(color: AppTheme.textSecondary, fontSize: 12),
                      ),
                    ),
                  ],
                ),
                SizedBox(height: 24),
                PrimaryButton(
                  text: 'Crear mi Cuenta',
                  onPressed: () => context.pushReplacementNamed('home'),
                ),
                SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text('¿Ya tienes cuenta? ', style: TextStyle(color: AppTheme.textSecondary)),
                    GestureDetector(
                      onTap: () => context.pushReplacementNamed('login'),
                      child: Text('Inicia sesión', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    nameController.dispose();
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(backgroundColor: AppTheme.darkBg, elevation: 0),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    SizedBox(height: 60),
                    Icon(Icons.account_balance_wallet, size: 60, color: AppTheme.primaryGreen),
                    SizedBox(height: 24),
                    Text('Bienvenido', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                    Text('Ingresa a tu cuenta', style: TextStyle(color: AppTheme.textSecondary)),
                    SizedBox(height: 40),
                    CustomTextField(
                      label: 'Correo Electrónico',
                      hint: 'tu@email.com',
                      controller: emailController,
                      keyboardType: TextInputType.emailAddress,
                    ),
                    SizedBox(height: 16),
                    CustomTextField(
                      label: 'Contraseña',
                      hint: '••••••••',
                      controller: passwordController,
                      obscureText: true,
                    ),
                    SizedBox(height: 8),
                    Align(
                      alignment: Alignment.centerRight,
                      child: GestureDetector(
                        onTap: () => context.push('/password-recovery'),
                        child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: AppTheme.primaryGreen, fontSize: 12)),
                      ),
                    ),
                    SizedBox(height: 24),
                    PrimaryButton(text: 'Iniciar sesión', onPressed: () => context.pushReplacementNamed('home')),
                  ],
                ),
                Column(
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text('¿No tienes cuenta? ', style: TextStyle(color: AppTheme.textSecondary)),
                        GestureDetector(
                          onTap: () => context.pushReplacementNamed('signup'),
                          child: Text('Regístrate', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    emailController.dispose();
    passwordController.dispose();
    super.dispose();
  }
}
