import 'package:flutter/material.dart'; // Importa la librería Flutter
import 'package:url_launcher/url_launcher.dart';

class ChatScreen extends StatelessWidget {
  // Define una clase llamada HelloWorldScreen que extiende StatelessWidget.
  final VoidCallback onLogout;

  ChatScreen({required this.onLogout});

  // Función para abrir URL
  Future<void> _launchURL(String url) async {
    final Uri uri = Uri.parse(url);
    if (!await launchUrl(uri, mode: LaunchMode.externalApplication)) {
      throw Exception('No se pudo abrir $url');
    }
  }

  @override
  Widget build(BuildContext context) {
    // Método para construir la interfaz de HelloWorldScreen.
    return Scaffold(
      appBar: AppBar(title: Text('¡Hola Mundo!')),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              '¡Bienvenido! Has iniciado sesión exitosamente.',
              style: TextStyle(fontSize: 24),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: 50),

            // Fila con 4 logotipos de redes sociales
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                // Facebook
                GestureDetector(
                  onTap: () {
                    _launchURL('https://www.facebook.com');
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          '../imagenes/facebook.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),

                // Instagram
                GestureDetector(
                  onTap: () {
                    _launchURL('https://www.instagram.com');
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          '../imagenes/instagram.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),

                // YouTube
                GestureDetector(
                  onTap: () {
                    _launchURL('https://www.youtube.com');
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          '../imagenes/Youtube.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),

                // Spotify
                GestureDetector(
                  onTap: () {
                    _launchURL('https://www.spotify.com');
                  },
                  child: Column(
                    children: [
                      Container(
                        height: 60,
                        width: 60,
                        child: Image.asset(
                          '../imagenes/Spotify.png',
                          fit: BoxFit.contain,
                        ),
                      ),
                      SizedBox(height: 5),
                    ],
                  ),
                ),
              ],
            ),

            SizedBox(height: 50),
          ],
        ),
      ),
    );
  }
}
