import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/biometrics/biometric_service.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class VerificationCheckpointScreen extends StatefulWidget {
  const VerificationCheckpointScreen({Key? key}) : super(key: key);

  @override
  State<VerificationCheckpointScreen> createState() =>
      _VerificationCheckpointScreenState();
}

class _VerificationCheckpointScreenState
    extends State<VerificationCheckpointScreen> {
  final BiometricService _biometricService = BiometricService();
  bool _isAuthenticating = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _executeVerification();
    });
  }

  Future<void> _executeVerification() async {
    if (_isAuthenticating) return;

    setState(() {
      _isAuthenticating = true;
      _errorMessage = '';
    });

    try {
      // 1. Conseguimos el usuario actual de la sesión local
      final user = await AuthDI.userRepository.getCurrentUser();

      if (user == null) {
        if (mounted) context.go('/login');
        return;
      }

      // 2. Traer las preferencias del Perfil
      final profile = await AuthDI.userRepository.getProfileByUserId(user.id);

      // Control defensivo: si la entidad viene nula o useBiometrics es null, evitamos el crash
      if (profile == null || profile.useBiometrics == false) {
        if (mounted) context.go('/home');
        return;
      }

      // 3. Verificar disponibilidad de hardware
      final canCheck = await _biometricService.canUseBiometrics();
      if (!canCheck) {
        setState(() {
          _errorMessage =
              'La autenticación local no está disponible en este dispositivo.';
          _isAuthenticating = false;
        });
        return;
      }

      // 4. Lanzar la validación nativa (Huella o PIN)
      final success = await _biometricService.authenticate(
        reason: 'Confirma tu identidad para ingresar a Finio',
        onlyBiometrics: false,
      );

      if (success && mounted) {
        context.go('/home');
      } else {
        setState(() {
          _errorMessage = 'Autenticación fallida o cancelada.';
        });
      }
    } catch (e, stackTrace) {
      // IMPRESIÓN DETALLADA DEL ERROR EN CONSOLA
      debugPrint('====================================');
      debugPrint('❌ ERROR EN BIOMETRIC CHECKPOINT: $e');
      debugPrint('STACK TRACE:\n$stackTrace');
      debugPrint('====================================');

      setState(() {
        _errorMessage = 'Ocurrió un error inesperado al validar el perfil.';
      });
    } finally {
      if (mounted) setState(() => _isAuthenticating = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF081427),
      body: SafeArea(
        child: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.lock_outline_rounded,
                  size: 64,
                  color: Color(0xFF34D399),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Verificación de Seguridad',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 22,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 12),
                const Text(
                  'Tu cuenta requiere validación para proteger tus finanzas.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Colors.grey, fontSize: 14),
                ),
                const SizedBox(height: 32),
                if (_isAuthenticating)
                  const CircularProgressIndicator(color: Color(0xFF34D399))
                else ...[
                  if (_errorMessage.isNotEmpty) ...[
                    Text(
                      _errorMessage,
                      textAlign: TextAlign.center,
                      style: const TextStyle(
                        color: Colors.redAccent,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 20),
                  ],
                  ElevatedButton.icon(
                    onPressed: _executeVerification,
                    icon: const Icon(Icons.fingerprint),
                    label: const Text('Desbloquear'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF0F3B3D),
                      foregroundColor: const Color(0xFF34D399),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 24,
                        vertical: 12,
                      ),
                    ),
                  ),
                  TextButton(
                    onPressed: () => context.go('/login'),
                    child: const Text(
                      'Volver al Login',
                      style: TextStyle(color: Colors.grey),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}
