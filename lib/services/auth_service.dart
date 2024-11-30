import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:path_provider/path_provider.dart';

class AuthService {
  Map<String, String>? userData;

  Future<Map<String, String>?> login(BuildContext context) async {
    final result = await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => LoginWebView(),
      ),
    );
    if (result != null) {
      userData = result;
      await _saveUserData(result);
    }
    return result;
  }

  Future<void> logout() async {
    userData = null;
    await _clearUserData();

    // Borra todas las preferencias compartidas
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();

    // Borra el caché de la aplicación
    final cacheDir = await getTemporaryDirectory();
    if (cacheDir.existsSync()) {
      cacheDir.deleteSync(recursive: true);
    }

    print('Sesión cerrada y datos eliminados.');
  }

  Future<void> _saveUserData(Map<String, String> data) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('userName', data['fullName'] ?? '');
    await prefs.setString('userRole', data['role'] ?? '');
  }

  Future<void> _clearUserData() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('userName');
    await prefs.remove('userRole');
  }

  Future<Map<String, String>?> getUserData() async {
    final prefs = await SharedPreferences.getInstance();
    final userName = prefs.getString('userName');
    final userRole = prefs.getString('userRole');
    if (userName != null && userRole != null) {
      return {'fullName': userName, 'role': userRole};
    }
    return null;
  }
}

class LoginWebView extends StatefulWidget {
  @override
  _LoginWebViewState createState() => _LoginWebViewState();
}

class _LoginWebViewState extends State<LoginWebView> {
  bool _isLoading = true;
  late final WebViewController _controller;

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() {
              _isLoading = true;
            });
          },
          onPageFinished: (String url) {
            setState(() {
              _isLoading = false;
            });
            if (url.startsWith('https://login-cr5q.onrender.com/')) {
              _extractUserInfo();
            }
          },
        ),
      )
      ..loadRequest(Uri.parse(
          'https://login.microsoftonline.com/b6b466ee-468d-4011-b9fc-fbdcf82ac90a/oauth2/v2.0/authorize?client_id=994e057f-ba8f-4e91-9d79-3cf8eb5026f7&response_type=code&redirect_uri=https%3A%2F%2Flogin-cr5q.onrender.com%2FgetAToken&scope=User.Read+offline_access+openid+profile&sso_reload=true'));
  }

  void _extractUserInfo() async {
    try {
      await Future.delayed(Duration(seconds: 2));
      final welcomeText = await _controller
          .runJavaScriptReturningResult('document.body.innerText') as String;

      print('Contenido de la página: $welcomeText');

      RegExp regExp = RegExp(r"Hola,\s*(.+?)!\s*Roles:\s*\[(.+?)\]");
      Match? match = regExp.firstMatch(welcomeText);

      if (match != null) {
        String fullName = match.group(1)?.trim() ?? '';
        String role = match.group(2)?.replaceAll("'", '').trim() ?? '';
        Navigator.pop(context, {'fullName': fullName, 'role': role});
      } else {
        throw 'No se pudo extraer la información del usuario';
      }
    } catch (e) {
      print('Error al extraer información del usuario: $e');
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Iniciar sesión')),
      body: Stack(
        children: [
          WebViewWidget(controller: _controller),
          if (_isLoading) Center(child: CircularProgressIndicator()),
        ],
      ),
    );
  }
}
