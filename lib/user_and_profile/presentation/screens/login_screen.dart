import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/user_and_profile/presentation/screens/register_screen.dart';
import 'package:mobile_app_frontend/shared/infrastructure/push_notifications_service.dart'; // Importante para las alertas
import 'package:http/http.dart'
    as http; // Usado para pasar el cliente a la sincronización

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  // View state
  bool _isPasswordVisible = false;
  bool _loading = false;
  final _userRepo = AuthDI.userRepository;

  // Theme colors
  static const Color _bg = Color(0xFF071826);
  static const Color _fieldBg = Color(0xFF0E2630);
  static const Color _cardBg = Color(0xFF102936);
  static const Color _accent = Color(0xFF2EE3A2);

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  InputDecoration _decoration({required String hint, Widget? suffix}) {
    return InputDecoration(
      hintText: hint,
      hintStyle: const TextStyle(color: Colors.white38),
      filled: true,
      fillColor: _fieldBg,
      contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 16),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide.none,
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(28),
        borderSide: BorderSide(color: _accent, width: 2),
      ),
      suffixIcon: suffix,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Bienvenido',
                    textAlign: TextAlign.left,
                    style: TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  const Text(
                    'Ingresa a tu cuenta',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),
                  const SizedBox(height: 32),
                  TextFormField(
                    controller: _emailController,
                    keyboardType: TextInputType.emailAddress,
                    decoration: _decoration(hint: 'Correo electrónico'),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) {
                      if (v == null || v.isEmpty) return 'Correo obligatorio';
                      final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                      if (!re.hasMatch(v)) return 'Correo inválido';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),
                  TextFormField(
                    controller: _passwordController,
                    obscureText: !_isPasswordVisible,
                    decoration: _decoration(
                      hint: 'Contraseña',
                      suffix: IconButton(
                        icon: Icon(
                          _isPasswordVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(
                          () => _isPasswordVisible = !_isPasswordVisible,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Contraseña obligatoria';
                      return null;
                    },
                  ),
                  const SizedBox(height: 12),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        context.go('/password-recovery');
                      },
                      style: TextButton.styleFrom(
                        padding: const EdgeInsets.symmetric(horizontal: 0),
                      ),
                      child: const Text(
                        '¿Olvidaste tu contraseña?',
                        style: TextStyle(
                          color: _accent,
                          fontSize: 13,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: _loading
                          ? null
                          : () async {
                              if (!formKey.currentState!.validate()) return;

                              setState(() => _loading = true);
                              try {
                                final username = _emailController.text.trim();
                                final password = _passwordController.text
                                    .trim();

                                await _userRepo.logIn(
                                  username: username,
                                  password: password,
                                );

                                if (!context.mounted) return;

                                final user = await _userRepo.getCurrentUser();
                                if (user != null) {
                                  await PushNotificationsService.instance
                                      .subscribeToUserTopic(user.id);

                                  final httpClient = http.Client();
                                  const baseUrl =
                                      'https://finio-api.azurewebsites.net';

                                  await PushNotificationsService.instance
                                      .loadUserNotifications(
                                        user.id,
                                        httpClient,
                                        baseUrl,
                                      );

                                  final profile = await _userRepo
                                      .getProfileByUserId(user.id);
                                  if (profile.useBiometrics) {
                                    if (mounted) context.go('/auth-checkpoint');
                                    return;
                                  }
                                }

                                if (mounted) context.go('/home');
                              } catch (e) {
                                if (mounted) {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    SnackBar(
                                      content: Text(
                                        'Error al iniciar sesión: $e',
                                      ),
                                    ),
                                  );
                                }
                              } finally {
                                if (mounted) setState(() => _loading = false);
                              }
                            },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: _accent,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(30),
                        ),
                        textStyle: const TextStyle(fontWeight: FontWeight.w600),
                      ),
                      child: const Text(
                        'Iniciar sesión',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70),
                        children: [
                          const TextSpan(text: '¿No tienes cuenta? '),
                          TextSpan(
                            text: 'Regístrate',
                            style: const TextStyle(color: _accent),
                            recognizer: TapGestureRecognizer()
                              ..onTap = () => Navigator.of(context).push(
                                MaterialPageRoute(
                                  builder: (_) => const RegisterScreen(),
                                ),
                              ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 32),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      GestureDetector(
                        onTap: () async {
                          final user = await _userRepo.getCurrentUser();
                          if (user != null) {
                            final profile = await _userRepo.getProfileByUserId(
                              user.id,
                            );
                            if (profile.useBiometrics) {
                              if (mounted) context.go('/auth-checkpoint');
                              return;
                            }
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La biometría no está activa o configurada en tu perfil.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _accent, width: 1.5),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: _accent,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'PIN',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      GestureDetector(
                        onTap: () async {
                          final user = await _userRepo.getCurrentUser();
                          if (user != null) {
                            final profile = await _userRepo.getProfileByUserId(
                              user.id,
                            );
                            if (profile.useBiometrics) {
                              if (mounted) context.go('/auth-checkpoint');
                              return;
                            }
                          }
                          if (mounted) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text(
                                  'La biometría no está activa o configurada en tu perfil.',
                                ),
                              ),
                            );
                          }
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _accent, width: 1.5),
                          ),
                          child: const Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: _accent,
                                size: 32,
                              ),
                              SizedBox(height: 8),
                              Text(
                                'Huella',
                                style: TextStyle(
                                  color: Colors.white70,
                                  fontSize: 12,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 40),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
