import 'package:flutter/material.dart';

class PasswordRecoveryScreen extends StatefulWidget {
  const PasswordRecoveryScreen({super.key});

  @override
  State<PasswordRecoveryScreen> createState() => _PasswordRecoveryScreenState();
}

class _PasswordRecoveryScreenState extends State<PasswordRecoveryScreen> {
  final formKey = GlobalKey<FormState>();

  // Controllers
  final TextEditingController _emailController = TextEditingController();

  // Theme colors
  static const Color _bg = Color(0xFF071826);
  static const Color _fieldBg = Color(0xFF0E2630);
  static const Color _cardBg = Color(0xFF102936);
  static const Color _accent = Color(0xFF2EE3A2);
  static const Color _infoBg = Color(0xFF0F3A4D);
  static const Color _infoText = Color(0xFF4AEADA);

  @override
  void dispose() {
    _emailController.dispose();
    super.dispose();
  }

  InputDecoration _decoration({required String hint}) {
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
          'Volver',
          style: TextStyle(color: Colors.white70, fontWeight: FontWeight.w500),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 22.0),
        child: SingleChildScrollView(
          child: Form(
            key: formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: 8),

                // Título
                const Text(
                  'Recuperar\ncontraseña',
                  style: TextStyle(
                    fontSize: 32,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                    height: 1.3,
                  ),
                ),

                const SizedBox(height: 12),

                // Subtítulo
                const Text(
                  'Te enviaremos un enlace a tu correo',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.white54,
                  ),
                ),

                const SizedBox(height: 22),

                // Label Correo electrónico
                const Text(
                  'Correo electrónico',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 13,
                    fontWeight: FontWeight.w500,
                  ),
                ),

                const SizedBox(height: 10),

                // Campo de correo
                TextFormField(
                  controller: _emailController,
                  keyboardType: TextInputType.emailAddress,
                  decoration: _decoration(hint: 'correo@ejemplo.com'),
                  style: const TextStyle(color: Colors.white),
                  validator: (v) {
                    if (v == null || v.isEmpty) return 'Correo obligatorio';
                    final re = RegExp(r'^[^@]+@[^@]+\.[^@]+');
                    if (!re.hasMatch(v)) return 'Correo inválido';
                    return null;
                  },
                ),

                const SizedBox(height: 20),

                // Botón Enviar enlace
                SizedBox(
                  height: 54,
                  child: ElevatedButton(
                    onPressed: () {
                      if (formKey.currentState!.validate()) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Enlace enviado a ${_emailController.text}',
                            ),
                          ),
                        );
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
                      'Enviar enlace',
                      style: TextStyle(color: Colors.black),
                    ),
                  ),
                ),

                const SizedBox(height: 16),

                // Card informativa
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: _infoBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: _infoText, width: 1),
                  ),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Icon(
                        Icons.info_outline,
                        color: _infoText,
                        size: 20,
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Text(
                          'Revisa también tu carpeta de spam. El enlace expira en 30 minutos.',
                          style: TextStyle(
                            color: _infoText,
                            fontSize: 13,
                            height: 1.5,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 40),
              ],
            ),
          ),
        ),
      ),
    );
  }
}