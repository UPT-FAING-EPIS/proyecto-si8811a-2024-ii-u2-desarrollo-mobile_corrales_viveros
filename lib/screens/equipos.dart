import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class EquiposScreen extends StatefulWidget {
  @override
  _EquiposScreenState createState() => _EquiposScreenState();
}

class _EquiposScreenState extends State<EquiposScreen> {
  late Future<List<Equipo>> _equipos;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _equipos = fetchEquipos();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole');
    });
  }

  Future<List<Equipo>> fetchEquipos() async {
    final response =
        await http.get(Uri.parse('http://161.132.37.95:8080/api/Equipo'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Equipo.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load equipos');
    }
  }

  Future<List<Participante>> fetchParticipantes(String equipoId) async {
    final response = await http.get(Uri.parse(
        'http://161.132.37.95:8080/api/Equipo/$equipoId/participantes'));
    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Participante.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load participantes');
    }
  }

  void _showParticipantesDialog(BuildContext context, Equipo equipo) {
    // ... (código existente)
  }

  void _showAddEditEquipoDialog({Equipo? equipo}) {
    final _formKey = GlobalKey<FormState>();
    String nombre = equipo?.nombre ?? '';
    String detalle = equipo?.detalle ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(equipo == null ? 'Agregar Equipo' : 'Editar Equipo'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: nombre,
                  decoration: InputDecoration(labelText: 'Nombre del Equipo'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un nombre';
                    }
                    return null;
                  },
                  onSaved: (value) => nombre = value!,
                ),
                TextFormField(
                  initialValue: detalle,
                  decoration: InputDecoration(labelText: 'Detalle'),
                  validator: (value) {
                    if (value == null || value.isEmpty) {
                      return 'Por favor ingrese un detalle';
                    }
                    return null;
                  },
                  onSaved: (value) => detalle = value!,
                ),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () => Navigator.of(context).pop(),
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (equipo == null) {
                    _addEquipo(nombre, detalle);
                  } else {
                    _editEquipo(equipo.id, nombre, detalle);
                  }
                  Navigator.of(context).pop();
                }
              },
            ),
          ],
        );
      },
    );
  }

  Future<void> _addEquipo(String nombre, String detalle) async {
    final response = await http.post(
      Uri.parse('http://161.132.37.95:8080/api/Equipo'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': nombre,
        'detalle': detalle,
        'participantes': [],
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _equipos = fetchEquipos();
      });
    } else {
      throw Exception('Failed to add equipo');
    }
  }

  Future<void> _editEquipo(String id, String nombre, String detalle) async {
    final response = await http.put(
      Uri.parse('http://161.132.37.95:8080/api/Equipo/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': nombre,
        'detalle': detalle,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _equipos = fetchEquipos();
      });
    } else {
      throw Exception('Failed to edit equipo');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Equipos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.orange.shade800,
        elevation: 0,
        actions: [
          if (userRole == 'admin')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddEditEquipoDialog(),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.orange.shade800, Colors.orange.shade200],
          ),
        ),
        child: FutureBuilder<List<Equipo>>(
          future: _equipos,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('No se encontraron equipos',
                      style: TextStyle(color: Colors.white)));
            } else {
              final equipos = snapshot.data!;
              return ListView.builder(
                itemCount: equipos.length,
                itemBuilder: (context, index) {
                  final equipo = equipos[index];
                  return Padding(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        title: Text(
                          equipo.nombre,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Text(
                              equipo.detalle,
                              style: TextStyle(color: Colors.grey.shade700),
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.people,
                                    size: 16, color: Colors.orange.shade800),
                                SizedBox(width: 8),
                                Text(
                                  'Participantes: ${equipo.participantes.length}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: userRole == 'admin'
                            ? IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.orange.shade800),
                                onPressed: () =>
                                    _showAddEditEquipoDialog(equipo: equipo),
                              )
                            : Icon(Icons.arrow_forward_ios,
                                color: Colors.orange.shade800),
                        onTap: () {
                          _showParticipantesDialog(context, equipo);
                        },
                      ),
                    ),
                  );
                },
              );
            }
          },
        ),
      ),
    );
  }
}

class Equipo {
  final String id;
  final String nombre;
  final String detalle;
  final List<String> participantes;

  Equipo({
    required this.id,
    required this.nombre,
    required this.detalle,
    required this.participantes,
  });

  factory Equipo.fromJson(Map<String, dynamic> json) {
    return Equipo(
      id: json['id'],
      nombre: json['nombre'],
      detalle: json['detalle'],
      participantes: List<String>.from(json['participantes']),
    );
  }
}

class Participante {
  final String id;
  final String nombre;
  final String detalle;

  Participante({
    required this.id,
    required this.nombre,
    required this.detalle,
  });

  factory Participante.fromJson(Map<String, dynamic> json) {
    return Participante(
      id: json['id'],
      nombre: json['nombre'],
      detalle: json['detalle'],
    );
  }
}
