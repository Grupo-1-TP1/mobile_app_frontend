import 'package:flutter/material.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final formKey = GlobalKey<FormState>();

  // Controllers (orden claro y agrupado)
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmController = TextEditingController();

  // View state
  bool _isPasswordVisible = false;
  bool _isConfirmVisible = false;
  bool _acceptedTerms = false;
  bool _subscribeNews = false;

  // Placeholder: dejo la referencia al servicio (no implementar aquí)
  //final userService = UserService();

  // Theme colors (basados en la imagen)
  static const Color _bg = Color(0xFF071826);
  static const Color _fieldBg = Color(0xFF0E2630);
  static const Color _cardBg = Color(0xFF102936);
  static const Color _accent = Color(0xFF2EE3A2);

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
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
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Crear cuenta',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22),
        child: Center(
          child: SingleChildScrollView(
            child: Form(
              key: formKey,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const SizedBox(height: 8),

                  // Nombre completo
                  TextFormField(
                    controller: _nameController,
                    decoration: _decoration(hint: 'Nombre completo'),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) {
                      if (v == null || v.trim().isEmpty)
                        return 'Nombre obligatorio';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Correo
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
                  const SizedBox(height: 14),

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
                      if (v.length < 6) return 'Mínimo 6 caracteres';
                      return null;
                    },
                  ),
                  const SizedBox(height: 14),

                  // Confirmar contraseña
                  TextFormField(
                    controller: _confirmController,
                    obscureText: !_isConfirmVisible,
                    decoration: _decoration(
                      hint: 'Confirmar contraseña',
                      suffix: IconButton(
                        icon: Icon(
                          _isConfirmVisible
                              ? Icons.visibility
                              : Icons.visibility_off,
                          color: Colors.white70,
                        ),
                        onPressed: () => setState(
                          () => _isConfirmVisible = !_isConfirmVisible,
                        ),
                      ),
                    ),
                    style: const TextStyle(color: Colors.white),
                    validator: (v) {
                      if (v == null || v.isEmpty)
                        return 'Confirma la contraseña';
                      if (v != _passwordController.text) return 'No coinciden';
                      return null;
                    },
                  ),
                  const SizedBox(height: 18),

                  // Tarjeta de términos
                  Container(
                    padding: const EdgeInsets.all(14),
                    decoration: BoxDecoration(
                      color: _cardBg,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Checkbox(
                              value: _acceptedTerms,
                              activeColor: _accent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                              onChanged: (v) =>
                                  setState(() => _acceptedTerms = v ?? false),
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: RichText(
                                text: TextSpan(
                                  style: const TextStyle(color: Colors.white70),
                                  children: [
                                    const TextSpan(
                                      text: 'He leído y acepto los ',
                                    ),
                                    TextSpan(
                                      text: 'Términos de servicio',
                                      style: TextStyle(color: _accent),
                                    ),
                                    const TextSpan(text: ' y la '),
                                    TextSpan(
                                      text: 'Política de privacidad',
                                      style: TextStyle(color: _accent),
                                    ),
                                    const TextSpan(text: ' de Finio'),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 8),
                        Row(
                          children: [
                            Checkbox(
                              value: _subscribeNews,
                              onChanged: (v) =>
                                  setState(() => _subscribeNews = v ?? false),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(6),
                              ),
                            ),
                            const SizedBox(width: 8),
                            const Expanded(
                              child: Text(
                                'Acepto recibir comunicaciones sobre novedades de Finio (opcional)',
                                style: TextStyle(color: Colors.white54),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),

                  // Botón CTA
                  SizedBox(
                    height: 54,
                    child: ElevatedButton(
                      onPressed: () async {
                        if (!(_acceptedTerms)) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Debes aceptar los términos'),
                            ),
                          );
                          return;
                        }
                        if (formKey.currentState!.validate()) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text(
                                'Formulario válido (servicio deshabilitado).',
                              ),
                            ),
                          );
                          // Llamadas al servicio: solo placeholders aquí (no implementar funciones)
                          /*
                          try {
                            final registerResponse = await userService.registerUser(
                              _nameController.text,
                              _emailController.text,
                              _passwordController.text,
                            );
                            if (registerResponse == 200 || registerResponse == 201) {
                              await userService.loginUser(_emailController.text, _passwordController.text);
                              // Navegación de ejemplo (ajusta rutas reales)
                              Navigator.pushReplacementNamed(context, '/home');
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('Error al registrar')),
                              );
                            }
                          } catch (e) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text('Error: $e')),
                            );
                          }
                          */
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
                        'Crear mi cuenta',
                        style: TextStyle(color: Colors.black),
                      ),
                    ),
                  ),

                  const SizedBox(height: 16),

                  // Texto legal
                  const Center(
                    child: Text(
                      'Tus datos están protegidos bajo la Ley N.º 29733 de Protección de Datos Personales del Perú',
                      textAlign: TextAlign.center,
                      style: TextStyle(color: Colors.white38, fontSize: 12),
                    ),
                  ),

                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
