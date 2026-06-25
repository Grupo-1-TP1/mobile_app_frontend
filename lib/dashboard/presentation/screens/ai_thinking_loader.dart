import 'dart:async';
import 'package:flutter/material.dart';
import 'package:mobile_app_frontend/shared/presentation/theme/app_theme.dart';

class AiThinkingLoader extends StatefulWidget {
  const AiThinkingLoader({Key? key}) : super(key: key);

  @override
  State<AiThinkingLoader> createState() => _AiThinkingLoaderState();
}

class _AiThinkingLoaderState extends State<AiThinkingLoader> {
  late Timer _timer;
  int _messageIndex = 0;

  // Lista de mensajes realistas alineados con tu modelo ML y tesis
  final List<String> _thinkingMessages = [
    "🤖 Conectando con el motor de Inteligencia Artificial...",
    "📊 Recuperando tu historial financiero del mes pasado...",
    "🧠 Analizando tus patrones de gastos por categoría...",
    "🔍 Evaluando variaciones y desviaciones...",
    "⚖️ Balanceando topes máximos y fijos...",
    "💡 Casi listo! Estructurando tus presupuestos óptimos para este mes...",
  ];

  @override
  void initState() {
    super.initState();
    // Cambia el mensaje secuencialmente cada 6 segundos
    _timer = Timer.periodic(const Duration(seconds: 6), (timer) {
      if (mounted) {
        setState(() {
          if (_messageIndex < _thinkingMessages.length - 1) {
            _messageIndex++;
          } else {
            // Si llega al final y sigue cargando, se queda en el último o reinicia los últimos 3
            _messageIndex = _thinkingMessages.length - 3; 
          }
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // Un indicador un poco más estético e institucional
            const SizedBox(
              width: 50,
              height: 50,
              child: CircularProgressIndicator(
                color: AppTheme.primaryGreen,
                strokeWidth: 3,
              ),
            ),
            const SizedBox(height: 32),
            // Contenedor con tamaño fijo para evitar saltos bruscos en la UI al cambiar el texto
            SizedBox(
              height: 60,
              child: AnimatedSwitcher(
                duration: const Duration(milliseconds: 500),
                child: Text(
                  _thinkingMessages[_messageIndex],
                  key: ValueKey<int>(_messageIndex),
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                    color: AppTheme.textPrimary,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              "Esto puede demorar hasta un minuto debido al procesamiento del modelo.",
              style: TextStyle(
                color: AppTheme.textSecondary.withOpacity(0.6),
                fontSize: 11,
              ),
            ),
          ],
        ),
      ),
    );
  }
}