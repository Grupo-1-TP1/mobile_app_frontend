import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_app_frontend/shared/infrastructure/services/biometrics/biometric_service.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/profile.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  bool _loading = true;
  User? _currentUser;
  int _savingPercentage = 0;
  String _name = '';
  bool _allowMlAnalysis = true;
  bool _allowPushNotifications = true;
  bool _useBiometrics = true;

  @override
  void initState() {
    super.initState();
    _loadSessionAndProfile();
  }

  Future<void> _loadSessionAndProfile() async {
    try {
      final user = await AuthDI.userRepository.getCurrentUser();

      if (user == null) {
        if (!mounted) return;
        context.go('/login');
        return;
      }

      final Profile profile = await AuthDI.userRepository.getProfileByUserId(
        user.id,
      );

      if (!mounted) return;

      setState(() {
        _currentUser = user;
        _name = profile.name;
        _savingPercentage = profile.savingPercentage;
        _allowMlAnalysis = profile.allowMlAnalysis;
        _allowPushNotifications = profile.allowPushNotifications;
        _useBiometrics = profile.useBiometrics;
        _loading = false;
      });
    } catch (e) {
      if (!mounted) return;
      setState(() => _loading = false);
      _showSnackBar('Error al conectar con el servidor: $e');
    }
  }

  // --- MÉTODOS DE ACCIÓN ---

  Future<void> _updateName(String newName) async {
    if (newName.trim().isEmpty || _currentUser == null) return;

    setState(() => _loading = true);
    try {
      await AuthDI.userRepository.updateProfileName(_currentUser!.id, newName);

      setState(() {
        _name = newName;
        _loading = false;
      });
      _showSnackBar('Nombre actualizado con éxito');
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Error al actualizar nombre: $e');
    }
  }

  Future<void> _updatePermissions({
    bool? allowMl,
    bool? allowPush,
    bool? useBio,
  }) async {
    if (_currentUser == null) return;

    final nextMl = allowMl ?? _allowMlAnalysis;
    final nextPush = allowPush ?? _allowPushNotifications;
    final nextBio = useBio ?? _useBiometrics;

    try {
      await AuthDI.userRepository.updateProfilePermissions(
        _currentUser!.id,
        allowMlAnalysis: nextMl,
        allowPushNotifications: nextPush,
        useBiometrics: nextBio,
      );

      setState(() {
        _allowMlAnalysis = nextMl;
        _allowPushNotifications = nextPush;
        _useBiometrics = nextBio;
      });
    } catch (e) {
      _showSnackBar('Error al guardar permisos: $e');
    }
  }

  Future<void> _updateSavingPercentage(int percentage) async {
    if (_currentUser == null) return;

    setState(() => _loading = true);
    try {
      await AuthDI.userRepository.updateProfileSavingPercentage(
        _currentUser!.id,
        percentage,
      );

      setState(() {
        _savingPercentage = percentage;
        _loading = false;
      });
      _showSnackBar('Meta de ahorro actualizada');
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Error al actualizar meta de ahorro: $e');
    }
  }

  Future<void> _handleDeleteAccount() async {
    if (_currentUser == null) return;

    setState(() => _loading = true);
    try {
      // Ajusta este método según dónde esté implementada tu lógica en la arquitectura distribuida
      await AuthDI.userRepository.deleteAccount(_currentUser!.id);

      if (!mounted) return;
      context.go('/login');
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Error al eliminar la cuenta: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- DIÁLOGOS ---

  void _showEditNameDialog() {
    final controller = TextEditingController(text: _name);
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Modificar nombre',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: "Ingresa tu nombre",
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryGreen),
            ),
            focusedBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.accentBlue),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _updateName(controller.text);
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showEditSavingPercentageDialog() {
    final controller = TextEditingController(
      text: _savingPercentage.toString(),
    );
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          'Meta de Ahorro (%)',
          style: TextStyle(color: AppTheme.textPrimary),
        ),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          style: const TextStyle(color: AppTheme.textPrimary),
          decoration: const InputDecoration(
            hintText: "Ej. 20",
            hintStyle: TextStyle(color: Colors.white30),
            enabledBorder: UnderlineInputBorder(
              borderSide: BorderSide(color: AppTheme.primaryGreen),
            ),
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              final val = int.tryParse(controller.text);
              if (val != null && val >= 0 && val <= 100) {
                Navigator.pop(context);
                _updateSavingPercentage(val);
              } else {
                _showSnackBar('Ingresa un porcentaje válido (0 - 100)');
              }
            },
            child: const Text(
              'Guardar',
              style: TextStyle(color: AppTheme.primaryGreen),
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteConfirmationDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppTheme.cardBg,
        title: const Text(
          '¿Eliminar cuenta?',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
          ),
        ),
        content: const Text(
          'Esta acción es irreversible y borrará de manera definitiva todos tus perfiles, registros financieros asociados y credenciales de acceso.',
          style: TextStyle(color: AppTheme.textSecondary, fontSize: 14),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text(
              'Cancelar',
              style: TextStyle(color: AppTheme.textSecondary),
            ),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              _handleDeleteAccount();
            },
            child: const Text(
              'Eliminar definitivamente',
              style: TextStyle(
                color: AppTheme.primaryRed,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    if (_loading || _currentUser == null) {
      return Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: const Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text(
          'Mi Perfil',
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
        elevation: 0,
        centerTitle: false,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          children: [
            // Tarjeta de Identidad (Comprimida)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(14),
              ),
              child: Column(
                children: [
                  Container(
                    width: 60,
                    height: 60,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 32,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(width: 24),
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_note,
                          color: AppTheme.primaryGreen,
                          size: 20,
                        ),
                        onPressed: _showEditNameDialog,
                        padding: EdgeInsets.zero,
                        constraints: const BoxConstraints(),
                      ),
                    ],
                  ),
                  Text(
                    _currentUser!.username,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 12,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      GestureDetector(
                        onTap: _showEditSavingPercentageDialog,
                        behavior: HitTestBehavior.opaque,
                        child: _ProfileStat(
                          'Meta Ahorro',
                          '$_savingPercentage%',
                          Icons.savings_outlined,
                        ),
                      ),
                      const _ProfileStat(
                        'Cuenta',
                        'Activa',
                        Icons.verified_user_outlined,
                      ),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 14),

            // Interruptores de configuración
            _SettingSwitchItem(
              title: 'Análisis automatizado',
              subtitle: 'Clasificación de consumos en segundo plano',
              icon: Icons.psychology_outlined,
              value: _allowMlAnalysis,
              onChanged: (val) => _updatePermissions(allowMl: val),
            ),
            _SettingSwitchItem(
              title: 'Notificaciones Push',
              subtitle: 'Alertas inmediatas de presupuestos',
              icon: Icons.notifications_none_rounded,
              value: _allowPushNotifications,
              onChanged: (val) => _updatePermissions(allowPush: val),
            ),
            _SettingSwitchItem(
              title: 'Seguridad Biométrica',
              subtitle: 'Acceso rápido con huella o rostro',
              icon: Icons.fingerprint_rounded,
              value: _useBiometrics,
              onChanged: (val) async {
                final biometricService =
                    BiometricService();
                final canCheck = await biometricService.canUseBiometrics();

                if (!canCheck && val == true) {
                  _showSnackBar(
                    'Tu dispositivo no cuenta con biometría o PIN de bloqueo configurado en el sistema.',
                  );
                  return;
                }
                _updatePermissions(useBio: val);
              },
            ),
            const SizedBox(height: 16),

            // Fila de acciones inferiores compacta
            Row(
              children: [
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: OutlinedButton(
                      onPressed: () async {
                        await AuthDI.userRepository.logOut();
                        if (!mounted) return;
                        context.go('/login');
                      },
                      style: OutlinedButton.styleFrom(
                        side: const BorderSide(color: AppTheme.primaryRed),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      child: const Text(
                        'Cerrar sesión',
                        style: TextStyle(
                          color: AppTheme.primaryRed,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: SizedBox(
                    height: 44,
                    child: ElevatedButton(
                      onPressed: _showDeleteConfirmationDialog,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppTheme.primaryRed,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        elevation: 0,
                      ),
                      child: const Text(
                        'Eliminar cuenta',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 14,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}

class _ProfileStat extends StatelessWidget {
  final String label;
  final String value;
  final IconData icon;

  const _ProfileStat(this.label, this.value, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen, size: 16),
            const SizedBox(width: 4),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 14,
              ),
            ),
          ],
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11),
        ),
      ],
    );
  }
}

class _SettingSwitchItem extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final bool value;
  final ValueChanged<bool> onChanged;

  const _SettingSwitchItem({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.value,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(10),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(6),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.04),
                borderRadius: BorderRadius.circular(6),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen, size: 20),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 14,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 11,
                    ),
                  ),
                ],
              ),
            ),
            Switch.adaptive(
              value: value,
              activeColor: AppTheme.primaryGreen,
              onChanged: onChanged,
            ),
          ],
        ),
      ),
    );
  }
}
