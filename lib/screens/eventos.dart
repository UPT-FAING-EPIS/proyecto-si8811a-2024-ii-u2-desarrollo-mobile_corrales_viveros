import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

class EventosScreen extends StatefulWidget {
  @override
  _EventosScreenState createState() => _EventosScreenState();
}

class _EventosScreenState extends State<EventosScreen> {
  late Future<List<Evento>> _eventos;

  @override
  void initState() {
    super.initState();
    _eventos = fetchEventos();
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Eventos', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.blue.shade800,
        elevation: 0,
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
                        trailing: Icon(Icons.arrow_forward_ios,
                            color: Colors.blue.shade800),
                        onTap: () {
                          _showDescriptionDialog(evento
                              .descripcion); // Mostrar la descripción en el pop-up
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
}
