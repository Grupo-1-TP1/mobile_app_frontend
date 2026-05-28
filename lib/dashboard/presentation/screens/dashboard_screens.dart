import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';

class DashboardReportScreen extends StatelessWidget {
  const DashboardReportScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text('Reporte mensual', style: TextStyle(color: AppTheme.textPrimary)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              padding: EdgeInsets.all(20),
              decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(16)),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('Total disponible', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                  SizedBox(height: 8),
                  Text('S/ 2,800', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
                  SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Text('Ingresos: S/ 1,559', style: TextStyle(color: AppTheme.primaryGreen)),
                      Text('Gastos: S/ -1,559', style: TextStyle(color: AppTheme.primaryRed)),
                      Text('+44%', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                    ],
                  ),
                ],
              ),
            ),
            SizedBox(height: 24),
            Text('Gastos por categoría', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppTheme.textPrimary)),
            SizedBox(height: 16),
            ...['Comida', 'Transporte', 'Educación', 'Ocio', 'Otros'].asMap().entries.map((e) {
              final colors = [Color(0xFF00D084), Color(0xFFFF6B6B), Color(0xFF3B82F6), Color(0xFFFFA500), Color(0xFF9D4EDD)];
              return Padding(
                padding: EdgeInsets.only(bottom: 12),
                child: Row(
                  children: [
                    Container(width: 12, height: 12, decoration: BoxDecoration(color: colors[e.key], shape: BoxShape.circle)),
                    SizedBox(width: 12),
                    Expanded(child: Text(e.value, style: TextStyle(color: AppTheme.textPrimary))),
                    Text('S/ ${((e.key + 1) * 200).toStringAsFixed(2)}', style: TextStyle(color: colors[e.key], fontWeight: FontWeight.bold)),
                  ],
                ),
              );
            }).toList(),
          ],
        ),
      ),
    );
  }
}
