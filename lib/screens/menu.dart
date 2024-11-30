import 'package:flutter/material.dart';
import 'package:dropdown_button2/dropdown_button2.dart';
import '../services/auth_service.dart';
import 'eventos.dart';
import 'equipos.dart';
import 'participantes.dart';
import 'ubicaciones.dart';
import 'coordidocente.dart';
import 'coordiestudiante.dart';

class MenuScreen extends StatelessWidget {
  final String userName;
  final String userRole;

  const MenuScreen({Key? key, required this.userName, required this.userRole})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
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
          DropdownButtonHideUnderline(
            child: DropdownButton2(
              customButton: Icon(
                Icons.menu,
                size: 30,
                color: Colors.white,
              ),
              items: [
                DropdownMenuItem<Divider>(
                  enabled: false,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(userName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.white)),
                      Divider(color: Colors.white30),
                    ],
                  ),
                ),
                ...MenuItems.allItems.map(
                  (item) => DropdownMenuItem<MenuItem>(
                    value: item,
                    child: MenuItems.buildItem(item),
                  ),
                ),
              ],
              onChanged: (value) {
                MenuItems.onChanged(context, value as MenuItem);
              },
              dropdownStyleData: DropdownStyleData(
                width: 220,
                padding: const EdgeInsets.symmetric(vertical: 6),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(4),
                  color: Colors.blue.shade800,
                ),
                elevation: 8,
                offset: const Offset(0, 8),
              ),
              menuItemStyleData: MenuItemStyleData(
                customHeights: [
                  56,
                  ...List<double>.filled(MenuItems.allItems.length, 48)
                ],
                padding: const EdgeInsets.only(left: 16, right: 16),
              ),
            ),
          ),
        ],
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
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Text(
                  "Juegos Florales 2024- II\nUniversidad Privada de Tacna",
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: GridView.count(
                    crossAxisCount: 2,
                    mainAxisSpacing: 16,
                    crossAxisSpacing: 16,
                    children: [
                      _buildImprovedCard('Eventos', 'lib/img/eventoss.png',
                          Colors.blue.shade600, context, EventosScreen()),
                      _buildImprovedCard(
                          'Ubicaciones',
                          'lib/img/ubicacioness.png',
                          Colors.green.shade600,
                          context,
                          UbicacionesScreen()),
                      _buildImprovedCard('Equipos', 'lib/img/equipos.png',
                          Colors.orange.shade600, context, EquiposScreen()),
                      _buildImprovedCard(
                          'Participantes',
                          'lib/img/participantess.png',
                          Colors.red.shade600,
                          context,
                          ParticipantesScreen()),
                      _buildImprovedCard(
                          'Coordinadores Docentes',
                          'lib/img/coordinador.png',
                          Colors.purple.shade600,
                          context,
                          CoordDocenteScreen()),
                      _buildImprovedCard(
                          'Coordinadores Estudiantes',
                          'lib/img/coordinador.png',
                          Colors.teal.shade600,
                          context,
                          CoordEstudianteScreen()),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildImprovedCard(String title, String imagePath, Color color,
      BuildContext context, Widget destination) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
            context, MaterialPageRoute(builder: (context) => destination));
      },
      child: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [color, color.withOpacity(0.7)],
          ),
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
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20),
          child: Material(
            color: Colors.transparent,
            child: InkWell(
              onTap: () {
                Navigator.push(context,
                    MaterialPageRoute(builder: (context) => destination));
              },
              splashColor: Colors.white.withOpacity(0.3),
              highlightColor: Colors.white.withOpacity(0.1),
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
                      boxShadow: [
                        BoxShadow(
                          color: color.withOpacity(0.3),
                          spreadRadius: 2,
                          blurRadius: 5,
                          offset: Offset(0, 2),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 12),
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

class MenuItem {
  final String text;
  final IconData icon;

  const MenuItem({
    required this.text,
    required this.icon,
  });
}

class MenuItems {
  static const List<MenuItem> allItems = [
    eventos,
    ubicaciones,
    equipos,
    participantes,
    coordDocentes,
    coordEstudiantes,
    logout
  ];

  static const eventos = MenuItem(text: 'Eventos', icon: Icons.event);
  static const ubicaciones =
      MenuItem(text: 'Ubicaciones', icon: Icons.location_on);
  static const equipos = MenuItem(text: 'Equipos', icon: Icons.group);
  static const participantes =
      MenuItem(text: 'Participantes', icon: Icons.people);
  static const coordDocentes =
      MenuItem(text: 'Coordinadores Docentes', icon: Icons.school);
  static const coordEstudiantes =
      MenuItem(text: 'Coordinadores Estudiantes', icon: Icons.person);
  static const logout = MenuItem(text: 'Cerrar sesión', icon: Icons.logout);

  static Widget buildItem(MenuItem item) {
    return Row(
      children: [
        Icon(item.icon, color: Colors.white, size: 22),
        const SizedBox(width: 10),
        Expanded(
          child: Text(
            item.text,
            style: const TextStyle(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }

  static onChanged(BuildContext context, MenuItem item) {
    switch (item) {
      case MenuItems.eventos:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EventosScreen()));
        break;
      case MenuItems.ubicaciones:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => UbicacionesScreen()));
        break;
      case MenuItems.equipos:
        Navigator.of(context)
            .push(MaterialPageRoute(builder: (context) => EquiposScreen()));
        break;
      case MenuItems.participantes:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => ParticipantesScreen()));
        break;
      case MenuItems.coordDocentes:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CoordDocenteScreen()));
        break;
      case MenuItems.coordEstudiantes:
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => CoordEstudianteScreen()));
        break;
      case MenuItems.logout:
        _logout(context);
        break;
    }
  }

  static void _logout(BuildContext context) async {
    try {
      final authService = AuthService();
      await authService.logout();
      Navigator.of(context)
          .pushNamedAndRemoveUntil('/', (Route<dynamic> route) => false);
    } catch (e) {
      print('Error al cerrar sesión: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al cerrar sesión: $e')),
      );
    }
  }
}
