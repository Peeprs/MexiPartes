import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatelessWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final args =
        ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    final String sourceRoute = args?['sourceRoute'] ?? '/login';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.close, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Aviso de Privacidad',
          style: TextStyle(color: Colors.white),
        ),
        centerTitle: true,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(
                  horizontal: 24.0,
                  vertical: 16.0,
                ),
                child: RichText(
                  text: TextSpan(
                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 16,
                      height: 1.5,
                    ),
                    children: [
                      _buildTitle('1. Responsable de los Datos Personales'),
                      _buildParagraph(
                        'MexiPartes ("La Aplicación") es responsable del tratamiento de sus datos personales. Para cualquier duda relacionada con la protección de sus datos, puede contactarnos en [tu_correo_de_soporte@email.com].',
                      ),
                      _buildTitle('2. Datos que Recopilamos'),
                      _buildParagraph(
                        'Para crear su cuenta y ofrecerle nuestros servicios, recopilamos la siguiente información:\n'
                        '   • Información de cuenta: Nombre de usuario, correo electrónico, contraseña.\n'
                        '   • Información personal: Nombre(s) y apellidos.\n'
                        '   • Información de contacto (opcional): Número de teléfono.\n'
                        '   • Datos de uso: Interacciones dentro de la app, búsquedas realizadas e información del dispositivo.',
                      ),
                      _buildTitle('3. Finalidad del Tratamiento de Datos'),
                      _buildParagraph(
                        'Utilizamos sus datos para:\n'
                        '   • Proveer, mantener y mejorar nuestros servicios.\n'
                        '   • Personalizar su experiencia.\n'
                        '   • Procesar transacciones y prevenir fraudes.\n'
                        '   • Comunicarnos con usted para fines de soporte y notificaciones.\n'
                        '   • Cumplir con obligaciones legales.',
                      ),
                      _buildTitle('4. Transferencia de Datos'),
                      _buildParagraph(
                        'No compartiremos su información personal con terceros, excepto cuando sea necesario para proveer el servicio (ej. pasarelas de pago) o cuando sea requerido por la ley.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --- NAVEGACIÓN INFERIOR ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      final result = await Navigator.pushNamed(
                        context,
                        '/cookie_notice',
                        arguments: {'sourceRoute': sourceRoute},
                      );
                      if (result == true && context.mounted) {
                        Navigator.of(context).pop(true);
                      }
                    },
                    child: const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Text(
                          'Siguiente: Cookies',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(width: 8),
                        Icon(Icons.arrow_forward, color: Colors.white),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // --- Helpers para dar estilo al texto ---
  TextSpan _buildTitle(String text) {
    return TextSpan(
      text: '\n$text\n',
      style: const TextStyle(
        color: Colors.white,
        fontWeight: FontWeight.bold,
        fontSize: 18,
      ),
    );
  }

  TextSpan _buildParagraph(String text) {
    return TextSpan(text: '$text\n');
  }
}
