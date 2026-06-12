import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';

class DashboardReportScreen extends StatefulWidget {
  const DashboardReportScreen({Key? key}) : super(key: key);

  @override
  State<DashboardReportScreen> createState() => _DashboardReportScreenState();
}

class _DashboardReportScreenState extends State<DashboardReportScreen> {
  bool _loading = true;
  String _selectedMonthStr = 'Jun 2026'; // Mes por defecto alineado a tus datos
  int _selectedMonthInt = 6;
  int _selectedYearInt = 2026;

  // Contenedores de datos reales provenientes del REST API
  List<dynamic> _allTransactions = [];
  List<dynamic> _allBudgets = [];

  // Variables de negocio calculadas en tiempo real
  double _totalIngresos = 0.0;
  double _totalGastos = 0.0;
  int _porcentajeAhorro = 0;

  List<PieChartSectionData> _pieSections = [];
  List<Map<String, dynamic>> _categoryDataList = [];
  Map<String, List<double>> _evolutionData = {
    'Oct': [0, 0],
    'Ene': [0, 0],
    'Mar': [0, 0],
    'Jun': [0, 0],
  };

  // Diccionarios oficiales de tu Tesis (Ids del 1 al 6 de tu Azure DB)
  final Map<int, String> _categoryNames = {
    1: "Alimentación",
    2: "Transporte",
    3: "Estudios",
    4: "Entretenimiento",
    5: "Servicios",
    6: "Transferencias",
    7: "Vivienda",
    8: "Otros",
  };

  final Map<int, Color> _categoryColors = {
    1: AppTheme.primaryGreen,
    2: AppTheme.accentBlue,
    3: Colors.orangeAccent,
    4: Colors.amber,
    5: AppTheme.primaryRed,
    6: Colors.purpleAccent,
    7: Colors.tealAccent,
    8: Colors.grey,
  };

  @override
  void initState() {
    super.initState();
    _loadBackendData();
  }

  Future<void> _loadBackendData() async {
    try {
      final user = await AuthDI.userRepository.getCurrentUser();
      if (user == null) return;

      // Consumimos tus dos endpoints HTTP en paralelo
      final txs = await ExpensesDI.transactionService.getTransactionsByUserId(
        user.id,
      );
      final budgets = await ExpensesDI.budgetService.getBudgetsByUserId(
        user.id,
      );

      _allTransactions = txs;
      _allBudgets = budgets;

      _calculateReportMetrics();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error al conectar: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _calculateReportMetrics() {
    double ingresosMes = 0.0;
    double gastosMes = 0.0;
    final Map<int, double> gastosPorCat = {};

    // 1. Procesar la lista de Objetos 'Transaction' reales de tu dominio
    for (final tx in _allTransactions) {
      // 🔥 CORRECCIÓN: Accedemos directamente a las propiedades del objeto con el punto (.)
      // Ya no usamos tx['transactionDate'] ni tx['type']
      final date = tx.transactionDate;
      final isExpense = tx.type.toLowerCase() == 'expense';
      final isIncome = tx.type.toLowerCase() == 'income';
      final amount = tx.amount.toDouble();

      // Filtrar los datos para el mes seleccionado en el Dropdown de tu tesis
      if (date.month == _selectedMonthInt && date.year == _selectedYearInt) {
        if (isIncome) ingresosMes += amount;
        if (isExpense) {
          gastosMes += amount;
          final catId = tx.categoryId;
          gastosPorCat[catId] = (gastosPorCat[catId] ?? 0.0) + amount;
        }
      }
    }

    // 2. Calcular porcentaje de ahorro real de la Tesis
    if (ingresosMes > 0) {
      _porcentajeAhorro = (((ingresosMes - gastosMes) / ingresosMes) * 100)
          .round()
          .clamp(0, 100);
    } else {
      _porcentajeAhorro = 0;
    }

    // 3. Generar Estructuras para fl_chart (Dona) y Leyendas cruzando con los Budgets
    final List<PieChartSectionData> tempSections = [];
    final List<Map<String, dynamic>> tempCategoryData = [];

    gastosPorCat.forEach((catId, monto) {
      final name = _categoryNames[catId] ?? "Otros";
      final color = _categoryColors[catId] ?? Colors.grey;
      final double pct = gastosMes > 0 ? (monto / gastosMes) * 100 : 0.0;

      // 🔥 CORRECCIÓN: Buscamos en la lista de presupuestos usando también la notación de objetos (.categoryId)
      dynamic budgetMatch;
      try {
        budgetMatch = _allBudgets.firstWhere((b) => b.categoryId == catId);
      } catch (_) {
        budgetMatch =
            null; // Si no encuentra un presupuesto para esa categoría, se asigna null de forma segura
      }

      // Extraemos los montos asignados y gastados de tu entidad Budget de Azure
      double budgetLimit = budgetMatch != null
          ? budgetMatch.amount.toDouble()
          : 0.0;
      double budgetSpent = budgetMatch != null
          ? budgetMatch.spent.toDouble()
          : monto;

      tempSections.add(
        PieChartSectionData(color: color, value: monto, title: '', radius: 14),
      );

      tempCategoryData.add({
        'id': catId,
        'name': name,
        'pct': '${pct.toStringAsFixed(0)}%',
        'color': color,
        'actual': budgetSpent,
        'sugerido': budgetLimit,
        'cambio': budgetLimit - budgetSpent,
      });
    });

    if (tempSections.isEmpty) {
      tempSections.add(
        PieChartSectionData(
          color: Colors.white10,
          value: 1,
          title: '',
          radius: 14,
        ),
      );
    }

    setState(() {
      _totalIngresos = ingresosMes;
      _totalGastos = gastosMes;
      _pieSections = tempSections;
      _categoryDataList = tempCategoryData;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(child: CircularProgressIndicator()),
      );
    }

    return Scaffold(
      backgroundColor: AppTheme.darkBg,
      appBar: AppBar(
        backgroundColor: AppTheme.darkBg,
        title: const Text(
          'Reporte mensual',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        elevation: 0,
        actions: [_buildMonthDropdown(), const SizedBox(width: 16)],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // 📊 1. Fila de Tarjetas KPI
            Row(
              children: [
                Expanded(
                  child: _buildKpiCard(
                    'Ingresos',
                    'S/ ${_totalIngresos.toStringAsFixed(0)}',
                    AppTheme.primaryGreen,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    'Gastos',
                    'S/ ${_totalGastos.toStringAsFixed(0)}',
                    AppTheme.primaryRed,
                  ),
                ),
                const SizedBox(width: 8),
                Expanded(
                  child: _buildKpiCard(
                    'Ahorro',
                    '$_porcentajeAhorro%',
                    Colors.orangeAccent,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            Text(
              'Gastos por categoría',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),

            // 🍩 2. Sección del Gráfico de Dona Integrado
            Row(
              children: [
                Expanded(
                  flex: 4,
                  child: SizedBox(
                    height: 140,
                    child: Stack(
                      children: [
                        PieChart(
                          PieChartData(
                            sectionsSpace: 4,
                            centerSpaceRadius: 45,
                            startDegreeOffset: -90,
                            sections: _pieSections,
                          ),
                        ),
                        Center(
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'S/ ${_totalGastos.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: AppTheme.textPrimary,
                                  fontSize: 16,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text(
                                'total',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 12,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: _categoryDataList.map((cat) {
                      return Padding(
                        padding: const EdgeInsets.symmetric(vertical: 3),
                        child: Row(
                          children: [
                            Container(
                              width: 10,
                              height: 10,
                              decoration: BoxDecoration(
                                color: cat['color'] as Color,
                                shape: BoxShape.circle,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Text(
                              '${cat['name']} ${cat['pct']}',
                              style: TextStyle(
                                color: AppTheme.textPrimary,
                                fontSize: 13,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                      );
                    }).toList(),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),

            // 🔑 3. LISTA DE DETALLE DE AJUSTES (Cruce de Categoría, Actual y Sugerido de tu Figma)
            Text(
              'Ajuste recomendado para el mes',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 15,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 12),
            ListView.separated(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: _categoryDataList.length,
              separatorBuilder: (_, __) => const SizedBox(height: 10),
              itemBuilder: (context, idx) {
                final item = _categoryDataList[idx];
                final double actual = item['actual'];
                final double sugerido = item['sugerido'];
                final double cambio = item['cambio'];

                return Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.cardBg,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            item['name'],
                            style: TextStyle(
                              color: AppTheme.textPrimary,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Row(
                            children: [
                              Text(
                                'S/ ${actual.toStringAsFixed(0)}',
                                style: TextStyle(
                                  color: AppTheme.textSecondary,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Text(
                                'S/ ${sugerido.toStringAsFixed(0)}',
                                style: const TextStyle(
                                  color: Colors.purpleAccent,
                                  fontWeight: FontWeight.bold,
                                  fontSize: 13,
                                ),
                              ),
                              const SizedBox(width: 12),
                              Container(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 6,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: cambio >= 0
                                      ? AppTheme.primaryGreen.withOpacity(0.1)
                                      : AppTheme.primaryRed.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  cambio >= 0
                                      ? '+S/${cambio.toStringAsFixed(0)}'
                                      : '-S/${cambio.abs().toStringAsFixed(0)}',
                                  style: TextStyle(
                                    color: cambio >= 0
                                        ? AppTheme.primaryGreen
                                        : AppTheme.primaryRed,
                                    fontSize: 11,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      // Barras de progreso superpuestas: Azul (Actual) y Morada (Sugerido por ML)
                      Stack(
                        children: [
                          Container(
                            height: 6,
                            decoration: BoxDecoration(
                              color: Colors.white10,
                              borderRadius: BorderRadius.circular(4),
                            ),
                          ),
                          FractionallySizedBox(
                            widthFactor: sugerido > 0
                                ? (actual / sugerido).clamp(0.0, 1.0)
                                : 0.0,
                            child: Container(
                              height: 6,
                              decoration: BoxDecoration(
                                color: item['color'],
                                borderRadius: BorderRadius.circular(4),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          value: _selectedMonthStr,
          dropdownColor: AppTheme.cardBg,
          style: TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          onChanged: (String? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMonthStr = newValue;
                _selectedMonthInt = newValue.startsWith('Jun') ? 6 : 4;
              });
              _calculateReportMetrics();
            }
          },
          items: <String>['Abr 2026', 'Jun 2026'].map<DropdownMenuItem<String>>(
            (String value) {
              return DropdownMenuItem<String>(value: value, child: Text(value));
            },
          ).toList(),
        ),
      ),
    );
  }

  Widget _buildKpiCard(String title, String value, Color valueColor) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            title,
            style: TextStyle(color: AppTheme.textSecondary, fontSize: 11),
          ),
          const SizedBox(height: 4),
          Text(
            value,
            style: TextStyle(
              color: valueColor,
              fontSize: 16,
              fontWeight: FontWeight.bold,
            ),
          ),
        ],
      ),
    );
  }
}
