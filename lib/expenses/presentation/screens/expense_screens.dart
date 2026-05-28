import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/shared/presentation/widgets/common_widgets.dart';

class OldHomeScreen extends StatefulWidget {
  const OldHomeScreen({Key? key}) : super(key: key);

  @override
  State<OldHomeScreen> createState() => _OldHomeScreenState();
}

class _OldHomeScreenState extends State<OldHomeScreen> {
  int selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.cardBg,
        title: Text('Ana García', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
        elevation: 0,
        actions: [Icon(Icons.notifications, color: AppTheme.primaryGreen)],
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Saldo', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  SizedBox(height: 8),
                  Text('S/ 1,240.50', style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  SizedBox(height: 12),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      _InfoItem('Comida', 'S/ 450', AppTheme.primaryGreen),
                      _InfoItem('Transporte', 'S/ 180', AppTheme.primaryRed),
                      _InfoItem('Otros', 'S/ 380', AppTheme.accentBlue),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _ActionButton(Icons.add_circle, 'Registrar\nIngreso', Colors.green),
                _ActionButton(Icons.remove_circle, 'Registrar\nGasto', Colors.red),
                _ActionButton(Icons.history, 'Historial', Colors.blue),
              ],
            ),
            SizedBox(height: 24),
            Align(alignment: Alignment.centerLeft, child: Text('Últimas transacciones', style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold))),
            SizedBox(height: 12),
            ..._generateTransactions(),
          ],
        ),
      ),
    );
  }

  List<Widget> _generateTransactions() {
    return List.generate(
      5,
      (i) => Padding(
        padding: EdgeInsets.only(bottom: 12),
        child: Row(
          children: [
            Container(
              width: 48,
              height: 48,
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(8)),
              child: Icon([Icons.fastfood, Icons.directions_bus, Icons.school, Icons.sports_bar, Icons.shopping_bag][i], color: AppTheme.primaryGreen),
            ),
            SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(['Comida', 'Transporte', 'Educación', 'Ocio', 'Compras'][i], style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.w600)),
                  Text('Hace ${i + 1} días', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                ],
              ),
            ),
            Text('- S/ ${(i + 1) * 50}', style: TextStyle(color: AppTheme.primaryRed, fontWeight: FontWeight.bold)),
          ],
        ),
      ),
    );
  }
}

class _InfoItem extends StatelessWidget {
  final String label;
  final String amount;
  final Color color;

  const _InfoItem(this.label, this.amount, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Text(label, style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
        SizedBox(height: 4),
        Text(amount, style: TextStyle(color: color, fontWeight: FontWeight.bold)),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final Color color;

  const _ActionButton(this.icon, this.label, this.color);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          width: 60,
          height: 60,
          decoration: BoxDecoration(color: AppTheme.cardBg, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
          child: Icon(icon, color: color, size: 30),
        ),
        SizedBox(height: 8),
        Text(label, textAlign: TextAlign.center, style: TextStyle(color: AppTheme.textPrimary, fontSize: 11)),
      ],
    );
  }
}
