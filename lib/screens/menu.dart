import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'eventos.dart';
import 'equipos.dart';
import 'participantes.dart';
import 'ubicaciones.dart';
import '../services/auth.dart';
import 'coordidocente.dart';
import 'coordiestudiante.dart';

class MenuScreen extends StatelessWidget {
  final String userName;

  const MenuScreen({Key? key, required this.userName}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    SystemChrome.setSystemUIOverlayStyle(SystemUiOverlayStyle.light);
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Colors.transparent,
        title: Text(
          'Bienvenido, $userName!',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
        ),
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Colors.blue.shade800, Colors.blue.shade500],
            ),
          ),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.logout, color: Colors.white),
            onPressed: () => _logout(context),
          ),
        ],
      ),
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: <Widget>[
            UserAccountsDrawerHeader(
              accountName: Text(userName),
              accountEmail: Text('Universidad Privada de Tacna'),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  userName.substring(0, 1).toUpperCase(),
                  style: TextStyle(fontSize: 40.0),
                ),
              ),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [Colors.blue.shade800, Colors.blue.shade500],
                ),
              ),
            ),
            ListTile(
              leading: Icon(Icons.event),
              title: Text('Eventos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EventosScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.location_on),
              title: Text('Ubicaciones'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => UbicacionesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.group),
              title: Text('Equipos'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => EquiposScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.people),
              title: Text('Participantes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => ParticipantesScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.school),
              title: Text('Coordinadores Docentes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoordDocenteScreen()),
                );
              },
            ),
            ListTile(
              leading: Icon(Icons.person),
              title: Text('Coordinadores Estudiantes'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => CoordEstudianteScreen()),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade100, Colors.white],
          ),
        ),
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 16,
              crossAxisSpacing: 16,
              children: [
                _buildCard('Eventos', 'lib/img/eventos.png',
                    Colors.blue.shade600, context, EventosScreen()),
                _buildCard('Ubicaciones', 'lib/img/ubicaciones.png',
                    Colors.green.shade600, context, UbicacionesScreen()),
                _buildCard('Equipos', 'lib/img/equipos.png',
                    Colors.orange.shade600, context, EquiposScreen()),
                _buildCard('Participantes', 'lib/img/parti.png',
                    Colors.red.shade600, context, ParticipantesScreen()),
                _buildCard('Coordinadores Docentes', 'lib/img/coordinador.png',
                    Colors.purple.shade600, context, CoordDocenteScreen()),
                _buildCard('Coordinadores Estudiantes', 'lib/img/coordinador.png',
                    Colors.teal.shade600, context, CoordEstudianteScreen()),
              ],
            ),
          ),
        ),
      ),
    );
  }

  void _logout(BuildContext context) async {
    try {
      final authService = AuthService(
          Navigator.of(context).widget.key as GlobalKey<NavigatorState>);
      await authService.logout();
      Navigator.pushReplacementNamed(context, '/login');
    } catch (e) {
      print('Error al cerrar sesión: $e');
    }
  }

  Widget _buildCard(String title, String imagePath, Color color,
      BuildContext context, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        decoration: BoxDecoration(
          color: color,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: color.withOpacity(0.5),
              spreadRadius: 2,
              blurRadius: 7,
              offset: Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white,
                image: DecorationImage(
                  image: AssetImage(imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(height: 12),
            Text(
              title,
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.white,
              ),
            ),
          ],
        ),
      ),
    );
  }
}