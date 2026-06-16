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

      final Profile profile = await AuthDI.userRepository.getProfileByUserId(user.id);
      
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
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al conectar con el servidor: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    // Si no ha cargado o falló la sesión, muestra el loader
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
        title: const Text('Mi Perfil', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
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
                borderRadius: BorderRadius.circular(16)
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(color: AppTheme.accentBlue, shape: BoxShape.circle),
                    child: const Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    _name, // Pintamos el nombre real obtenido localmente
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)
                  ),
                  Text(
                    _currentUser!.username, // Correo del usuario
                    style: TextStyle(color: AppTheme.textSecondary, fontSize: 13)
                  ),
                  const SizedBox(height: 20),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat('Meta Ahorro', '$_savingPercentage%', Icons.savings_outlined),
                      _ProfileStat('Cuenta', 'Activa', Icons.verified_user_outlined),
                    ],
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),

            _SettingSwitchItem(
              title: 'Análisis automatizado',
              subtitle: 'Clasificación de consumos en segundo plano con ML',
              icon: Icons.psychology_outlined,
              value: _allowMlAnalysis,
              onChanged: (val) => setState(() => _allowMlAnalysis = val),
            ),
            _SettingSwitchItem(
              title: 'Notificaciones Push',
              subtitle: 'Alertas inmediatas de presupuestos de la IA',
              icon: Icons.notifications_none_rounded,
              value: _allowPushNotifications,
              onChanged: (val) => setState(() => _allowPushNotifications = val),
            ),
            _SettingSwitchItem(
              title: 'Seguridad Biométrica',
              subtitle: 'Acceso rápido con huella o rostro',
              icon: Icons.fingerprint_rounded,
              value: _useBiometrics,
              onChanged: (val) => setState(() => _useBiometrics = val),
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
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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
            Text(value, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold, fontSize: 15)),
          ],
        ),
        const SizedBox(height: 4),
        Text(label, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
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
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(color: Colors.white.withOpacity(0.05), borderRadius: BorderRadius.circular(8)),
              child: Icon(icon, color: AppTheme.primaryGreen),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title, style: const TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w500, fontSize: 15)),
                  const SizedBox(height: 2),
                  Text(subtitle, style: const TextStyle(color: AppTheme.textSecondary, fontSize: 11)),
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