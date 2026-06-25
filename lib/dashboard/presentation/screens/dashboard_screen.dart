import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';
import 'package:mobile_app_frontend/expenses/infrastructure/expenses_di.dart';
import 'package:mobile_app_frontend/user_and_profile/infrastructure/auth_di.dart';
import 'package:mobile_app_frontend/expenses/domain/entities/transaction.dart';

class DashboardReportScreen extends StatefulWidget {
  const DashboardReportScreen({Key? key}) : super(key: key);

  @override
  State<DashboardReportScreen> createState() => _DashboardReportScreenState();
}

class _DashboardReportScreenState extends State<DashboardReportScreen> {
  bool _loading = true;

  // Variables de control de periodos dinámicos
  late int _selectedMonthInt;
  late int _selectedYearInt;

  List<Transaction> _monthTransactions = [];
  List<Transaction> _allHistoricalTransactions =
      []; // Para el gráfico de evolución lineal

  double _totalIngresos = 0.0;
  double _totalGastos = 0.0;
  int _porcentajeAhorro = 0;

  List<PieChartSectionData> _pieSections = [];
  List<Map<String, dynamic>> _categoryDataList = [];

  List<FlSpot> _ingresosSpots = [];
  List<FlSpot> _gastosSpots = [];
  double _minX = 0;
  double _maxX = 0;
  double _minY = 0;
  double _maxY = 0;
  Map<int, String> _monthLabels = {};

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

  final List<String> _monthNames = [
    '',
    'Ene',
    'Feb',
    'Mar',
    'Abr',
    'May',
    'Jun',
    'Jul',
    'Ago',
    'Sep',
    'Oct',
    'Nov',
    'Dic',
  ];

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _selectedMonthInt = now.month;
    _selectedYearInt = now.year;
    _loadBackendData();
  }

  Future<void> _loadBackendData() async {
    if (!mounted) return;
    setState(() => _loading = true);

    try {
      final user = await AuthDI.userRepository.getCurrentUser();
      if (user == null) return;

      // 1. Carga optimizada del mes filtrado (Evita colapsos de memoria transformando a String)
      final txsMes = await ExpensesDI.transactionService
          .getTransactionsByUserIdAndMonthAndYear(
            user.id,
            _selectedMonthInt,
            _selectedYearInt,
          );

      // 2. Traer el historial completo únicamente para trazar la línea de evolución de meses
      final txsHistoricas = await ExpensesDI.transactionService
          .getTransactionsByUserId(user.id);

      setState(() {
        _monthTransactions = txsMes;
        _allHistoricalTransactions = txsHistoricas;
      });

      _calculateReportMetrics();
      _calculateEvolutionData();
    } catch (e) {
      debugPrint('❌ Error cargando reportes: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al sincronizar métricas: $e')),
      );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  void _calculateReportMetrics() {
    double ingresosMes = 0.0;
    double gastosMes = 0.0;
    final Map<int, double> gastosPorCat = {};

    // Computar sobre la lista pre-filtrada del mes actual
    for (final tx in _monthTransactions) {
      final isExpense = tx.type.toLowerCase() == 'expense';
      final isIncome = tx.type.toLowerCase() == 'income';
      final amount = tx.amount.toDouble();

      if (isIncome) ingresosMes += amount;
      if (isExpense) {
        gastosMes += amount;
        final catId = tx.categoryId;
        gastosPorCat[catId] = (gastosPorCat[catId] ?? 0.0) + amount;
      }
    }

    if (ingresosMes > 0) {
      _porcentajeAhorro = (((ingresosMes - gastosMes) / ingresosMes) * 100)
          .round()
          .clamp(0, 100);
    } else {
      _porcentajeAhorro = 0;
    }

    final List<PieChartSectionData> tempSections = [];
    final List<Map<String, dynamic>> tempCategoryData = [];

    gastosPorCat.forEach((catId, monto) {
      final name = _categoryNames[catId] ?? "Otros";
      final color = _categoryColors[catId] ?? Colors.grey;
      final double pct = gastosMes > 0 ? (monto / gastosMes) * 100 : 0.0;

      tempSections.add(
        PieChartSectionData(color: color, value: monto, title: '', radius: 14),
      );

      tempCategoryData.add({
        'id': catId,
        'name': name,
        'pct': '${pct.toStringAsFixed(0)}%',
        'color': color,
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

  void _calculateEvolutionData() {
    // 1. LIMPIEZA DE SEGURIDAD: Resetear los estados anteriores para evitar que se mezclen datos viejos
    setState(() {
      _ingresosSpots = [];
      _gastosSpots = [];
      _monthLabels = {};
    });

    if (_allHistoricalTransactions.isEmpty) return;

    Map<int, Map<String, double>> monthlyTotals = {};
    Set<int> monthsPresent = {};

    for (final tx in _allHistoricalTransactions) {
      final date = tx.transactionDate;
      final month = date.month;
      final amount = tx.amount.toDouble();
      final isIncome = tx.type.toLowerCase() == 'income';
      final isExpense = tx.type.toLowerCase() == 'expense';

      monthsPresent.add(month);

      if (!monthlyTotals.containsKey(month)) {
        monthlyTotals[month] = {'income': 0.0, 'expense': 0.0};
      }

      if (isIncome)
        monthlyTotals[month]!['income'] =
            monthlyTotals[month]!['income']! + amount;
      if (isExpense)
        monthlyTotals[month]!['expense'] =
            monthlyTotals[month]!['expense']! + amount;
    }

    List<int> sortedMonths = monthsPresent.toList()..sort();
    List<FlSpot> incomeSpots = [];
    List<FlSpot> expenseSpots = [];
    Map<int, String> labels = {};
    double maxVal = 0;

    // CASO A: El usuario es nuevo o solo tiene transacciones registradas en un único mes histórico
    if (sortedMonths.length == 1) {
      int unicoMes = sortedMonths[0];
      double income = monthlyTotals[unicoMes]?['income'] ?? 0.0;
      double expense = monthlyTotals[unicoMes]?['expense'] ?? 0.0;
      maxVal = income > expense ? income : expense;

      // Creamos un rango artificial plano [0 a 1] para que fl_chart pueda dibujar la línea recta
      incomeSpots.add(FlSpot(0, income));
      incomeSpots.add(FlSpot(1, income));
      expenseSpots.add(FlSpot(0, expense));
      expenseSpots.add(FlSpot(1, expense));

      labels[0] = _monthNames[unicoMes];
      labels[1] = '';

      setState(() {
        _ingresosSpots = incomeSpots;
        _gastosSpots = expenseSpots;
        _minX = 0;
        _maxX = 1;
        _minY = 0;
        _maxY = maxVal > 0 ? maxVal * 1.3 : 100.0;
        _monthLabels = labels;
      });
      return;
    }

    // CASO B: Flujo normal multilperiodo (Múltiples meses con datos en la BD)
    for (int i = 0; i < sortedMonths.length; i++) {
      int month = sortedMonths[i];
      double x = i.toDouble();
      double income = monthlyTotals[month]?['income'] ?? 0.0;
      double expense = monthlyTotals[month]?['expense'] ?? 0.0;

      incomeSpots.add(FlSpot(x, income));
      expenseSpots.add(FlSpot(x, expense));
      labels[i] = _monthNames[month];

      if (income > maxVal) maxVal = income;
      if (expense > maxVal) maxVal = expense;
    }

    // 2. ACTUALIZACIÓN DEL ESTADO: Forzar el redibujado con los límites exactos calculados
    setState(() {
      _ingresosSpots = incomeSpots;
      _gastosSpots = expenseSpots;
      _minX = 0;
      _maxX = (sortedMonths.length - 1).toDouble();
      _minY = 0;
      _maxY = maxVal > 0
          ? (maxVal * 1.25).ceilToDouble()
          : 100.0; // Añade un 25% de margen superior visual
      _monthLabels = labels;
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_loading) {
      return const Scaffold(
        backgroundColor: AppTheme.darkBg,
        body: Center(
          child: CircularProgressIndicator(color: AppTheme.primaryGreen),
        ),
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
                                style: const TextStyle(
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
                              style: const TextStyle(
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
            Text(
              'Evolución mensual',
              style: TextStyle(
                color: AppTheme.textPrimary,
                fontSize: 16,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            Container(
              height: 200,
              padding: const EdgeInsets.only(right: 16, top: 16),
              child: _ingresosSpots.isEmpty
                  ? const Center(
                      child: Text(
                        "No hay datos",
                        style: TextStyle(color: Colors.white),
                      ),
                    )
                  : LineChart(
                      LineChartData(
                        gridData: FlGridData(show: false),
                        titlesData: FlTitlesData(
                          show: true,
                          bottomTitles: AxisTitles(
                            sideTitles: SideTitles(
                              showTitles: true,
                              reservedSize: 30,
                              interval: 1,
                              getTitlesWidget: (value, meta) {
                                return Padding(
                                  padding: const EdgeInsets.only(top: 8.0),
                                  child: Text(
                                    _monthLabels[value.toInt()] ?? '',
                                    style: TextStyle(
                                      color: AppTheme.textSecondary,
                                      fontSize: 10,
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                          leftTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          topTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                          rightTitles: AxisTitles(
                            sideTitles: SideTitles(showTitles: false),
                          ),
                        ),
                        borderData: FlBorderData(show: false),
                        minX: _minX,
                        maxX: _maxX,
                        minY: _minY,
                        maxY: _maxY,
                        lineBarsData: [
                          LineChartBarData(
                            spots: _ingresosSpots,
                            isCurved: true,
                            color: AppTheme.primaryGreen,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryGreen.withOpacity(0.1),
                            ),
                          ),
                          LineChartBarData(
                            spots: _gastosSpots,
                            isCurved: true,
                            color: AppTheme.primaryRed,
                            barWidth: 3,
                            isStrokeCapRound: true,
                            dotData: FlDotData(show: false),
                            belowBarData: BarAreaData(
                              show: true,
                              color: AppTheme.primaryRed.withOpacity(0.1),
                            ),
                          ),
                        ],
                      ),
                    ),
            ),
          ],
        ),
      ),
    );
  }

  // CORREGIDO: Menu Dropdown estructurado dinámicamente con los 12 meses del periodo actual
  Widget _buildMonthDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12),
      decoration: BoxDecoration(
        color: AppTheme.cardBg,
        borderRadius: BorderRadius.circular(8),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<int>(
          value: _selectedMonthInt,
          dropdownColor: AppTheme.cardBg,
          style: const TextStyle(
            color: AppTheme.textPrimary,
            fontWeight: FontWeight.w600,
          ),
          icon: const Icon(Icons.keyboard_arrow_down, color: Colors.white70),
          onChanged: (int? newValue) {
            if (newValue != null) {
              setState(() {
                _selectedMonthInt = newValue;
              });
              _loadBackendData(); // Vuelve a consultar al servidor con el nuevo filtro
            }
          },
          items: List.generate(12, (index) {
            final monthIndex = index + 1;
            return DropdownMenuItem<int>(
              value: monthIndex,
              child: Text('${_monthNames[monthIndex]} $_selectedYearInt'),
            );
          }),
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
