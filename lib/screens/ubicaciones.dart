import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';

class UbicacionesScreen extends StatefulWidget {
  @override
  _UbicacionesScreenState createState() => _UbicacionesScreenState();
}

class _UbicacionesScreenState extends State<UbicacionesScreen> {
  late Future<List<Lugar>> _lugares;

  @override
  void initState() {
    super.initState();
    _lugares = fetchLugares();
  }

  Future<List<Lugar>> fetchLugares() async {
    final response = await http.get(Uri.parse('http://161.132.48.189:8000/lugares/'));

    if (response.statusCode == 200) {
      List jsonResponse = json.decode(response.body);
      return jsonResponse.map((data) => Lugar.fromJson(data)).toList();
    } else {
      throw Exception('Failed to load lugares');
    }
  }

  void _openGoogleMaps(double lat, double lng) async {
    final url = 'https://www.google.com/maps/search/?api=1&query=$lat,$lng';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      throw 'Could not launch $url';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Ubicaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.green.shade800, Colors.green.shade200],
          ),
        ),
        child: FutureBuilder<List<Lugar>>(
          future: _lugares,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No se encontraron lugares', style: TextStyle(color: Colors.white)));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final lugar = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () => _openGoogleMaps(lugar.latitud, lugar.longitud),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lugar.nombreLugar,
                                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 24),
                              ),
                              SizedBox(height: 8),
                              Text('Dirección ID: ${lugar.direccionId}'),
                              SizedBox(height: 8),
                              Text('Capacidad: ${lugar.capacidad}'),
                              SizedBox(height: 8),
                              Text('Descripción: ${lugar.descripcion}'),
                              SizedBox(height: 8),
                              Text(
                                'Toca para ver en Google Maps',
                                style: TextStyle(color: Colors.blue, fontStyle: FontStyle.italic),
                              ),
                            ],
                          ),
                        ),
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

class Lugar {
  final String id;
  final String rev;
  final String nombreLugar;
  final String direccionId;
  final int capacidad;
  final String descripcion;
  final double latitud;
  final double longitud;
  final String idCategoria;
  final int estado;

  Lugar({
    required this.id,
    required this.rev,
    required this.nombreLugar,
    required this.direccionId,
    required this.capacidad,
    required this.descripcion,
    required this.latitud,
    required this.longitud,
    required this.idCategoria,
    required this.estado,
  });

  factory Lugar.fromJson(Map<String, dynamic> json) {
    return Lugar(
      id: json['_id'],
      rev: json['_rev'],
      nombreLugar: json['nombre_lugar'],
      direccionId: json['direccion_id'],
      capacidad: json['capacidad'],
      descripcion: json['descripcion'],
      latitud: json['latitud'].toDouble(),
      longitud: json['longitud'].toDouble(),
      idCategoria: json['id_categoria'],
      estado: json['estado'],
    );
  }
}