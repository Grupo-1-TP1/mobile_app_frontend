import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
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

  // --- MÉTODOS DE ACTUALIZACIÓN ---

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
    if (_currentUser == null || percentage < 0 || percentage > 100) return;

    setState(() => _loading = true);
    try {
      final currentProfile = await AuthDI.userRepository.getProfileByUserId(
        _currentUser!.id,
      );

      // Creamos la instancia directamente para evitar el error de copyWith
      final updatedProfile = Profile(
        id: currentProfile.id,
        userId: currentProfile.userId,
        name: currentProfile.name,
        savingPercentage: percentage,
        allowMlAnalysis: currentProfile.allowMlAnalysis,
        allowPushNotifications: currentProfile.allowPushNotifications,
        useBiometrics: currentProfile.useBiometrics,
      );

      await AuthDI.userRepository.updateProfile(updatedProfile);

      setState(() {
        _savingPercentage = percentage;
        _loading = false;
      });
      _showSnackBar('Meta de ahorro actualizada');
    } catch (e) {
      setState(() => _loading = false);
      _showSnackBar('Error al cambiar meta de ahorro: $e');
    }
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(
      context,
    ).showSnackBar(SnackBar(content: Text(message)));
  }

  // --- DIÁLOGOS DE EDICIÓN ---

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
          ),
        ),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            // Tarjeta de Identidad del Alumno
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: AppTheme.cardBg,
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      color: AppTheme.accentBlue,
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      size: 40,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(
                        width: 32,
                      ), // Ajuste de centrado por el botón
                      Text(
                        _name,
                        style: const TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: AppTheme.textPrimary,
                        ),
                      ),
                      IconButton(
                        icon: const Icon(
                          Icons.edit_note,
                          color: AppTheme.primaryGreen,
                          size: 22,
                        ),
                        onPressed: _showEditNameDialog,
                      ),
                    ],
                  ),
                  Text(
                    _currentUser!.username,
                    style: const TextStyle(
                      color: AppTheme.textSecondary,
                      fontSize: 13,
                    ),
                  ),
                  const SizedBox(height: 20),
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
            const SizedBox(height: 24),

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
              onChanged: (val) => _updatePermissions(useBio: val),
            ),
            const SizedBox(height: 32),

            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () async {
                  await AuthDI.userRepository.logOut();
                  if (!mounted) return;
                  context.go('/login');
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primaryRed,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: const Text(
                  'Cerrar sesión',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
              ),
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
            Icon(icon, color: AppTheme.primaryGreen, size: 18),
            const SizedBox(width: 6),
            Text(
              value,
              style: const TextStyle(
                color: AppTheme.textPrimary,
                fontWeight: FontWeight.bold,
                fontSize: 15,
              ),
            ),
          ],
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12),
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
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.cardBg,
          borderRadius: BorderRadius.circular(12),
        ),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.05),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Icon(icon, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: AppTheme.textPrimary,
                      fontWeight: FontWeight.w500,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 2),
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
