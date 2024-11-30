import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

class EventosScreen extends StatefulWidget {
  @override
  _EventosScreenState createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Evento>> _eventos;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _eventos = fetchEventos();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole');
    });
  }

  Future<List<Evento>> fetchEventos() async {
    final response =
        await http.get(Uri.parse('http://161.132.48.189:9091/evento'));

    if (response.statusCode == 200) {
      List<dynamic> data = json.decode(response.body);
      return data.map((json) => Evento.fromJson(json)).toList();
    } else {
      throw Exception('Failed to load eventos');
    }
  }

  void _showDescriptionDialog(String descripcion) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Descripción del Evento'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(descripcion),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showAddEditEventDialog({Evento? evento}) {
    final _formKey = GlobalKey<FormState>();
    String nombre = evento?.nombre ?? '';
    DateTime fechaInicio = evento?.fechaInicio ?? DateTime.now();
    DateTime fechaTermino = evento?.fechaTermino ?? DateTime.now();
    String facultad = evento?.facultad ?? '';
    String resultado = evento?.resultado ?? '';
    String descripcion = evento?.descripcion ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(evento == null ? 'Agregar Evento' : 'Editar Evento'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: nombre,
                    decoration: InputDecoration(labelText: 'Nombre'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                    onSaved: (value) => nombre = value!,
                  ),
                  TextFormField(
                    initialValue: DateFormat('yyyy-MM-dd').format(fechaInicio),
                    decoration: InputDecoration(labelText: 'Fecha de Inicio'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una fecha de inicio';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        fechaInicio = DateFormat('yyyy-MM-dd').parse(value!),
                  ),
                  TextFormField(
                    initialValue: DateFormat('yyyy-MM-dd').format(fechaTermino),
                    decoration: InputDecoration(labelText: 'Fecha de Término'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una fecha de término';
                      }
                      return null;
                    },
                    onSaved: (value) =>
                        fechaTermino = DateFormat('yyyy-MM-dd').parse(value!),
                  ),
                  TextFormField(
                    initialValue: facultad,
                    decoration: InputDecoration(labelText: 'Facultad'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese una facultad';
                      }
                      return null;
                    },
                    onSaved: (value) => facultad = value!,
                  ),
                  TextFormField(
                    initialValue: resultado,
                    decoration: InputDecoration(labelText: 'Resultado'),
                    onSaved: (value) => resultado = value ?? '',
                  ),
                  TextFormField(
                    initialValue: descripcion,
                    decoration: InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                    onSaved: (value) => descripcion = value ?? '',
                  ),
                ],
              ),
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Guardar'),
              onPressed: () {
                if (_formKey.currentState!.validate()) {
                  _formKey.currentState!.save();
                  if (evento == null) {
                    _addEvento(nombre, fechaInicio, fechaTermino, facultad,
                        resultado, descripcion);
                  } else {
                    _editEvento(evento.id, nombre, fechaInicio, fechaTermino,
                        facultad, resultado, descripcion);
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

  Future<void> _addEvento(
      String nombre,
      DateTime fechaInicio,
      DateTime fechaTermino,
      String facultad,
      String resultado,
      String descripcion) async {
    final response = await http.post(
      Uri.parse('http://161.132.48.189:9091/evento'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': nombre,
        'fechaInicio': fechaInicio.toIso8601String(),
        'fechaTermino': fechaTermino.toIso8601String(),
        'facultad': facultad,
        'resultado': resultado,
        'descripcion': descripcion,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _eventos = fetchEventos();
      });
    } else {
      throw Exception('Failed to add evento');
    }
  }

  Future<void> _editEvento(
      String id,
      String nombre,
      DateTime fechaInicio,
      DateTime fechaTermino,
      String facultad,
      String resultado,
      String descripcion) async {
    try {
      final response = await http.put(
        Uri.parse('http://161.132.48.189:9091/Evento/$id'),
        headers: <String, String>{
          'Content-Type': 'application/json; charset=UTF-8',
        },
        body: jsonEncode(<String, dynamic>{
          'id': id,
          'nombre': nombre,
          'fechaInicio': fechaInicio.toUtc().toIso8601String(),
          'fechaTermino': fechaTermino.toUtc().toIso8601String(),
          'facultad': facultad,
          'resultado': resultado,
          'descripcion': descripcion,
        }),
      );

      if (response.statusCode == 200) {
        setState(() {
          _eventos = fetchEventos();
        });
        print('Evento editado con éxito');
      } else {
        print(
            'Error al editar evento: ${response.statusCode} ${response.body}');
        throw Exception(
            'Failed to edit evento: ${response.statusCode} ${response.body}');
      }
    } catch (e) {
      print('Error editing evento: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error al editar el evento: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
        actions: [
          if (userRole == 'admin')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddEditEventDialog(),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.blue.shade800, Colors.blue.shade200],
          ),
        ),
        child: FutureBuilder<List<Evento>>(
          future: _eventos,
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
                  child: Text('No se encontraron eventos',
                      style: TextStyle(color: Colors.white)));
            } else {
              final eventos = snapshot.data!;
              return ListView.builder(
                itemCount: eventos.length,
                itemBuilder: (context, index) {
                  final evento = eventos[index];
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
                          evento.nombre,
                          style: TextStyle(
                              fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.calendar_today,
                                    size: 16, color: Colors.blue.shade800),
                                SizedBox(width: 8),
                                Text(
                                  '${DateFormat('dd/MM/yyyy').format(evento.fechaInicio)} - ${DateFormat('dd/MM/yyyy').format(evento.fechaTermino)}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                            SizedBox(height: 4),
                            Row(
                              children: [
                                Icon(Icons.school,
                                    size: 16, color: Colors.blue.shade800),
                                SizedBox(width: 8),
                                Text(
                                  evento.facultad,
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                            SizedBox(height: 8),
                            Row(
                              children: [
                                Icon(Icons.check_circle,
                                    size: 16, color: Colors.green.shade700),
                                SizedBox(width: 8),
                                Text(
                                  'Resultado: ${evento.resultado == 'Vacio' ? 'Aún por verse' : evento.resultado}',
                                  style: TextStyle(color: Colors.grey.shade700),
                                ),
                              ],
                            ),
                          ],
                        ),
                        trailing: userRole == 'admin'
                            ? IconButton(
                                icon: Icon(Icons.edit,
                                    color: Colors.blue.shade800),
                                onPressed: () =>
                                    _showAddEditEventDialog(evento: evento),
                              )
                            : Icon(Icons.arrow_forward_ios,
                                color: Colors.blue.shade800),
                        onTap: () {
                          _showDescriptionDialog(evento.descripcion);
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

class Evento {
  final String id;
  final String nombre;
  final DateTime fechaInicio;
  final DateTime fechaTermino;
  final String facultad;
  final String resultado;
  final String descripcion;

  Evento({
    required this.id,
    required this.nombre,
    required this.fechaInicio,
    required this.fechaTermino,
    required this.facultad,
    required this.resultado,
    required this.descripcion,
  });

  factory Evento.fromJson(Map<String, dynamic> json) {
    return Evento(
      id: json['id'],
      nombre: json['nombre'],
      fechaInicio: DateTime.parse(json['fechaInicio']),
      fechaTermino: DateTime.parse(json['fechaTermino']),
      facultad: json['facultad'],
      resultado: json['resultado'],
      descripcion: json['descripcion'],
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'nombre': nombre,
        'fechaInicio': fechaInicio.toUtc().toIso8601String(),
        'fechaTermino': fechaTermino.toUtc().toIso8601String(),
        'facultad': facultad,
        'resultado': resultado,
        'descripcion': descripcion,
      };
}
