import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:go_router/go_router.dart';

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
                  // Título
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

                  // Subtítulo
                  const Text(
                    'Ingresa a tu cuenta',
                    textAlign: TextAlign.left,
                    style: TextStyle(fontSize: 14, color: Colors.white54),
                  ),

                  const SizedBox(height: 32),

                  // Correo electrónico
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

                  // Contraseña
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

                  // Link ¿Olvidaste tu contraseña?
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () {
                        // Implementar lógica de recuperación
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

                  // Botón Iniciar sesión
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
                                context.go('/home');
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

                  // Link Registrarse
                  Center(
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(color: Colors.white70),
                        children: [
                          const TextSpan(text: '¿No tienes cuenta? '),
                          TextSpan(
                            text: 'Regístrate',
                            style: const TextStyle(color: _accent),
                            // Aquí puedes añadir: recognizer: TapGestureRecognizer()..onTap = () => Navigator.push(...)
                          ),
                        ],
                      ),
                    ),
                  ),

                  const SizedBox(height: 32),

                  // Botones de acceso rápido
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // PIN
                      GestureDetector(
                        onTap: () {
                          // Implementar lógica PIN
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _accent, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.lock_outline,
                                color: _accent,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
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

                      // Biométrico
                      GestureDetector(
                        onTap: () {
                          // Implementar lógica biométrica
                        },
                        child: Container(
                          padding: const EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: _cardBg,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: _accent, width: 1.5),
                          ),
                          child: Column(
                            children: [
                              Icon(
                                Icons.person_outline,
                                color: _accent,
                                size: 32,
                              ),
                              const SizedBox(height: 8),
                              const Text(
                                'Biométrico',
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
