import 'package:flutter/material.dart';
import 'services/auth.dart';
import 'screens/menu.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    final GlobalKey<NavigatorState> navigatorKey = GlobalKey<NavigatorState>();

    return MaterialApp(
      title: 'Juegos Florales UPT 2024 - II',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          primary: Colors.blue,
          secondary: Colors.orange,
        ),
        useMaterial3: true,
        textTheme: TextTheme(
          headlineLarge: TextStyle(
            fontSize: 36,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 10.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(2, 2),
              ),
            ],
          ),
          headlineMedium: TextStyle(
            fontSize: 28,
            fontWeight: FontWeight.bold,
            color: Colors.white,
            shadows: [
              Shadow(
                blurRadius: 8.0,
                color: Colors.black.withOpacity(0.5),
                offset: Offset(1, 1),
              ),
            ],
          ),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            foregroundColor: Colors.white,
            backgroundColor: Colors.blue,
            padding: EdgeInsets.symmetric(horizontal: 40, vertical: 20),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(30),
            ),
            textStyle: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            elevation: 5,
          ),
        ),
      ),
      navigatorKey: navigatorKey,
      home: MyHomePage(
        title: 'Juegos Florales UPT 2024 - II',
        navigatorKey: navigatorKey,
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
    required this.navigatorKey,
  });

  final String title;
  final GlobalKey<NavigatorState> navigatorKey;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  late final AuthService _authService;
  String? userName;

  @override
  void initState() {
    super.initState();
    _authService = AuthService(widget.navigatorKey);
  }

  void _login() async {
    try {
      print('Iniciando sesión...');
      final name = await _authService.login();
      if (name != null) {
        setState(() {
          userName = name;
        });
        _navigateToMenu();
      }
    } catch (e) {
      print('Error durante el inicio de sesión: $e');
    }
  }

  void _navigateToMenu() {
    if (userName != null) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => MenuScreen(userName: userName!),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          Container(
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage("lib/img/logomejorado.png"),
                fit: BoxFit.cover,
              ),
            ),
          ),
          SafeArea(
            child: Stack(
              children: [
                Positioned(
                  top:
                      120, // Ajusta este valor para mover el título hacia abajo
                  left: 0,
                  right: 0,
                  child: Column(
                    children: [
                      Text(
                        'Juegos Florales UPT',
                        style: Theme.of(context).textTheme.headlineLarge,
                        textAlign: TextAlign.center,
                      ),
                      Text(
                        '2024 - II',
                        style: Theme.of(context).textTheme.headlineMedium,
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                ),
                Positioned(
                  top: 40,
                  right: 20,
                  child: Image.asset(
                    'lib/img/insigniaupt.png',
                    width: 80,
                    height: 80,
                  ),
                ),
                Positioned.fill(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      if (userName == null)
                        ElevatedButton(
                          onPressed: _login,
                          child: Text('Iniciar sesión con Microsoft'),
                        )
                      else
                        Text(
                          'Bienvenido, $userName!',
                          style: Theme.of(context).textTheme.headlineSmall,
                        ),
                      SizedBox(height: 40),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
