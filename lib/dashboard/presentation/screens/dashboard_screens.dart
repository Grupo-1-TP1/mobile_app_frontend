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

class BudgetsScreen extends StatelessWidget {
  const BudgetsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text('Presupuestos', style: TextStyle(color: AppTheme.textPrimary)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ...['Comida', 'Transporte', 'Educación'].map((category) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(color: AppTheme.cardBg, borderRadius: BorderRadius.circular(12)),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(category, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                          Text('S/ 600 / S/ 1000', style: TextStyle(color: AppTheme.textSecondary, fontSize: 12)),
                        ],
                      ),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.6,
                          minHeight: 8,
                          backgroundColor: Color.fromARGB(50, 61, 130, 246),
                          valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}

class SavingsGoalsScreen extends StatelessWidget {
  const SavingsGoalsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: Text('Metas de Ahorro', style: TextStyle(color: AppTheme.textPrimary)),
        elevation: 0,
      ),
      body: SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            ...['Viaje a Cusco', 'Laptop Nueva', 'Curso UX'].map((goal) {
              return Padding(
                padding: EdgeInsets.only(bottom: 16),
                child: Container(
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.primaryGreen, width: 1),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Icon(Icons.flag, color: AppTheme.primaryGreen),
                          Text(goal, style: TextStyle(color: AppTheme.textPrimary, fontWeight: FontWeight.bold)),
                          Icon(Icons.more_vert, color: AppTheme.textSecondary),
                        ],
                      ),
                      SizedBox(height: 12),
                      Text('S/ 500 / S/ 1000', style: TextStyle(color: AppTheme.primaryGreen, fontWeight: FontWeight.bold)),
                      SizedBox(height: 8),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: 0.5,
                          minHeight: 8,
                          backgroundColor: Color.fromARGB(50, 0, 208, 132),
                          valueColor: AlwaysStoppedAnimation(AppTheme.primaryGreen),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }).toList(),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: AppTheme.primaryGreen,
        onPressed: () {},
        child: Icon(Icons.add, color: Colors.black),
      ),
    );
  }
}
