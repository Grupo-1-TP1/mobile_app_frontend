import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  // Theme colors
  static const Color _bg = Color(0xFF071826);
  static const Color _cardBg = Color(0xFF102936);
  static const Color _textLight = Colors.white70;
  static const Color _textDark = Colors.white54;

  // Section colors
  static const List<Color> _sectionColors = [
    Color(0xFF2EE3A2),  // Verde (1)
    Color(0xFF3B82F6),  // Azul (2)
    Color(0xFFFB923C),  // Naranja (3)
    Color(0xFFA78BFA),  // Púrpura (4)
    Color(0xFFF87171),  // Rojo (5)
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: _bg,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios_new, color: Colors.white70),
          onPressed: () => Navigator.of(context).maybePop(),
        ),
        title: const Text(
          'Política de privacidad',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.w600),
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: 8),

              // Fecha de actualización
              const Text(
                'Última actualización: abril 2026',
                style: TextStyle(color: _textDark, fontSize: 13),
              ),

              const SizedBox(height: 20),

              // Sección 1: Responsable del tratamiento
              _buildPolicySection(
                number: 1,
                title: 'Responsable del tratamiento',
                content:
                    'Finio App S.A.C., con domicilio en Lima, Perú.\n\n'
                    'Responsable conforme a la Ley N° 29733 y su Reglamento\n'
                    'D.S. 003-2013-JUS.',
                color: _sectionColors[0],
              ),

              const SizedBox(height: 16),

              // Sección 2: Datos que recopilamos
              _buildPolicySection(
                number: 2,
                title: 'Datos que recopilamos',
                content:
                    '• Identificación: nombre, correo electrónico.\n'
                    '• Financieros: ingresos y gastos ingresados manualmente.\n'
                    '• Uso: patrones de interacción (anonimizados para ML).\n'
                    '• Biométricos: huella/Face ID procesados localmente.',
                color: _sectionColors[1],
              ),

              const SizedBox(height: 16),

              // Sección 3: Finalidad y base legal
              _buildPolicySection(
                number: 3,
                title: 'Finalidad y base legal',
                content:
                    'Prestación del servicio (art. 13 Ley 29733), mejora del '
                    'modelo de IA con datos anonimizados, y comunicaciones '
                    'con tu consentimiento expreso.',
                color: _sectionColors[2],
              ),

              const SizedBox(height: 16),

              // Sección 4: Tus derechos (ARCO)
              _buildPolicySection(
                number: 4,
                title: 'Tus derechos (ARCO)',
                content:
                    'Tienes derecho de Acceso, Rectificación, Cancelación y '
                    'Oposición conforme al art. 19 de la Ley 29733. Escribenos a '
                    'privacidad@finio.pe',
                color: _sectionColors[3],
              ),

              const SizedBox(height: 16),

              // Sección 5: Seguridad y transferencia
              _buildPolicySection(
                number: 5,
                title: 'Seguridad y transferencia',
                content:
                    'Datos cifrados en tránsito (TLS 1.3) y en reposo (AES-256). '
                    'No se venden a terceros. Compartición solo con proveedores '
                    'bajo acuerdo de confidencialidad.',
                color: _sectionColors[4],
              ),

              const SizedBox(height: 30),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPolicySection({
    required int number,
    required String title,
    required String content,
    required Color color,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: _cardBg,
        borderRadius: BorderRadius.circular(12),
        border: Border(left: BorderSide(color: color, width: 4)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  color: color,
                  shape: BoxShape.circle,
                ),
                child: Center(
                  child: Text(
                    '$number',
                    style: const TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 12),
              Expanded(
                child: Text(
                  title,
                  style: TextStyle(
                    color: color,
                    fontWeight: FontWeight.w600,
                    fontSize: 15,
                  ),
                ),
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(
            content,
            style: const TextStyle(
              color: _textLight,
              fontSize: 13,
              height: 1.6,
            ),
          ),
        ],
      ),
    );
  }
}