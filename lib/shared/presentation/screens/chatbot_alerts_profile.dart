import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/user_and_profile/domain/entities/user.dart';

class ProfileScreen extends StatelessWidget {
  final User? user;
  const ProfileScreen({Key? key, this.user}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(backgroundColor: AppTheme.darkBg, title: Text('Mi Perfil', style: TextStyle(color: AppTheme.textPrimary)), elevation: 0),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: BoxDecoration(color: AppTheme.accentBlue, shape: BoxShape.circle),
                    child: Icon(Icons.person, size: 40, color: Colors.white),
                  ),
                  SizedBox(height: 16),
                  Text('Ana García', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  Text('Seguridad (US37)', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  SizedBox(height: 16),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ProfileStat('Editar perfil', Icons.edit),
                      _ProfileStat('Datos de uso', Icons.analytics),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            _SettingItem('Seguridad (US37)', Icons.security_rounded, Icons.toggle_on),
            _SettingItem('Análisis de tableros (RAI)', Icons.analytics, Icons.toggle_on),
            _SettingItem('Datos y privacidad', Icons.privacy_tip, Icons.toggle_on),
            _SettingItem('Notificaciones', Icons.notifications, Icons.toggle_off),
            SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 52,
              child: ElevatedButton(
                onPressed: () {},
                style: ElevatedButton.styleFrom(backgroundColor: AppTheme.primaryRed),
                child: Text('Cerrar sesión', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
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
  final IconData icon;

  const _ProfileStat(this.label, this.icon);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 50,
          height: 50,
          decoration: BoxDecoration(color: Color.fromARGB(50, 61, 130, 246), borderRadius: BorderRadius.circular(8)),
          child: Icon(icon, color: AppTheme.accentBlue),
        ),
        SizedBox(height: 8),
        Text(label, style: TextStyle(color: AppTheme.textPrimary, fontSize: 12), textAlign: TextAlign.center),
      ],
    );
  }
}

class _SettingItem extends StatelessWidget {
  final String title;
  final IconData icon;
  final IconData trailingIcon;

  const _SettingItem(this.title, this.icon, this.trailingIcon);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: 12),
      child: Container(
        padding: EdgeInsets.all(16),
        decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
        child: Row(
          children: [
            Icon(icon, color: AppTheme.primaryGreen),
            SizedBox(width: 16),
            Expanded(child: Text(title, style: TextStyle(color: AppTheme.textPrimary))),
            Icon(trailingIcon, color: AppTheme.textSecondary),
          ],
        ),
      ),
    );
  }
}
