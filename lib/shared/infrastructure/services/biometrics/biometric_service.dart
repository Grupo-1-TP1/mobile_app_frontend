import 'package:flutter/services.dart';
import 'package:local_auth/local_auth.dart';
import 'package:local_auth_android/local_auth_android.dart';

class BiometricService {
  final LocalAuthentication _auth = LocalAuthentication();

  Future<bool> canUseBiometrics() async {
    try {
      final isSupported = await _auth.isDeviceSupported();
      final canCheck = await _auth.canCheckBiometrics;
      return isSupported && canCheck;
    } on PlatformException catch (_) {
      return false;
    }
  }

  /// Autenticación compatible con la versión 3.x.x en Android
  Future<bool> authenticate({
    required String reason,
    required bool onlyBiometrics,
  }) async {
    try {
      return await _auth.authenticate(
        localizedReason: reason,
        // CONFIGURACIÓN 3.X: Reemplaza a 'stickyAuth'
        persistAcrossBackgrounding: true,
        // CONFIGURACIÓN 3.X: true obliga Huella, false permite PIN de respaldo
        biometricOnly: onlyBiometrics,
        authMessages: const <AuthMessages>[
          AndroidAuthMessages(
            signInTitle: 'Seguridad de Finio',
            cancelButton: 'Cancelar',
          ),
        ],
      );
    } on PlatformException catch (e) {
      print('Error en autenticación local: $e');
      return false;
    }
  }
}
