import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class LoginWebView extends StatefulWidget {
  @override
  _LoginWebViewState createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  late final WebViewController controller;

  @override
  void initState() {
    super.initState();
    controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onNavigationRequest: (NavigationRequest request) {
            if (request.url.startsWith('https://login-cr5q.onrender.com')) {
              // Aquí deberías extraer el texto de bienvenida de la página
              // Por ahora, simularemos obtener el texto
              final welcomeText = 'Hola, Usuario de Prueba! Roles: [admin]';
              final userData = processWelcomeText(welcomeText);
              Navigator.pop(context, userData);
              return NavigationDecision.prevent;
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://login.microsoftonline.com/b6b466ee-468d-4011-b9fc-fbdcf82ac90a/oauth2/v2.0/authorize?client_id=994e057f-ba8f-4e91-9d79-3cf8eb5026f7&response_type=code&redirect_uri=https%3A%2F%2Flogin-cr5q.onrender.com%2FgetAToken&scope=User.Read+offline_access+openid+profile&sso_reload=true'));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: WebViewWidget(controller: controller),
    );
  }

  Map<String, String>? processWelcomeText(String welcomeText) {
    final RegExp regExp = RegExp(r"Hola, (.+?)! Roles: \[(.+?)\]");
    final match = regExp.firstMatch(welcomeText);

    if (match != null) {
      final fullName = match.group(1);
      final role = match.group(2)?.replaceAll("'", "");

      return {'fullName': fullName ?? '', 'role': role ?? ''};
    }
    return null;
  }
}
