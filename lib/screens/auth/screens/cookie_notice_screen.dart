import 'package:flutter/material.dart';

class CookieNoticeScreen extends StatelessWidget {
  const CookieNoticeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    // final args = ModalRoute.of(context)?.settings.arguments as Map<String, dynamic>?;
    // final String sourceRoute = args?['sourceRoute'] ?? '/login';

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title: const Text(
          'Aviso de Cookies',
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
                      _buildTitle('1. ¿Qué son las Cookies?'),
                      _buildParagraph(
                        'Las cookies son pequeños archivos de texto que se almacenan en su dispositivo cuando utiliza nuestra aplicación. Nos ayudan a recordar sus preferencias y a entender cómo interactúa con nuestros servicios para mejorar su experiencia.',
                      ),
                      _buildTitle('2. ¿Cómo Usamos las Cookies?'),
                      _buildParagraph(
                        'Utilizamos diferentes tipos de cookies:\n'
                        '   • Cookies Esenciales: Necesarias para el funcionamiento básico de la app, como mantener su sesión iniciada.\n'
                        '   • Cookies de Rendimiento y Análisis: Nos ayudan a recopilar datos anónimos sobre el uso de la app para identificar áreas de mejora.\n'
                        '   • Cookies de Funcionalidad: Recuerdan sus elecciones (como el idioma o la región) para ofrecer una experiencia más personalizada.',
                      ),
                      _buildTitle('3. Su Consentimiento'),
                      _buildParagraph(
                        'Al hacer clic en "Aceptar", usted consiente el uso de estas tecnologías. Puede retirar su consentimiento en cualquier momento desde la configuración de la aplicación. Tenga en cuenta que deshabilitar ciertas cookies puede afectar la funcionalidad de la aplicación.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
            // --- BOTÓN DE ACEPTAR ---
            Padding(
              padding: const EdgeInsets.all(24.0),
              child: ElevatedButton(
                onPressed: () {
                  Navigator.of(context).pop(true);
                },
                child: const Text(
                  'Aceptar y Continuar',
                  style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
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
