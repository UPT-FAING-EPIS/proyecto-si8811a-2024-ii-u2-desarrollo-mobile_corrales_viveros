import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'package:shared_preferences/shared_preferences.dart';

class UbicacionesScreen extends StatefulWidget {
  @override
  _UbicacionesScreenState createState() => _UbicacionesScreenState();
}

class _UbicacionesScreenState extends State<UbicacionesScreen> {
  late Future<List<Lugar>> _lugares;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _lugares = fetchLugares();
    _getUserRole();
  }

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole');
    });
  }

  Future<List<Lugar>> fetchLugares() async {
    final response =
        await http.get(Uri.parse('http://161.132.48.189:8000/lugares/'));

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

  void _showAddEditLugarDialog({Lugar? lugar}) {
    final _formKey = GlobalKey<FormState>();
    String nombreLugar = lugar?.nombreLugar ?? '';
    String direccionId = lugar?.direccionId ?? '';
    int capacidad = lugar?.capacidad ?? 0;
    String descripcion = lugar?.descripcion ?? '';
    double latitud = lugar?.latitud ?? 0.0;
    double longitud = lugar?.longitud ?? 0.0;
    String idCategoria = lugar?.idCategoria ?? '';
    int estado = lugar?.estado ?? 1;

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(lugar == null ? 'Agregar Ubicación' : 'Editar Ubicación'),
          content: SingleChildScrollView(
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  TextFormField(
                    initialValue: nombreLugar,
                    decoration: InputDecoration(labelText: 'Nombre del Lugar'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un nombre';
                      }
                      return null;
                    },
                    onSaved: (value) => nombreLugar = value!,
                  ),
                  TextFormField(
                    initialValue: direccionId,
                    decoration: InputDecoration(labelText: 'ID de Dirección'),
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese un ID de dirección';
                      }
                      return null;
                    },
                    onSaved: (value) => direccionId = value!,
                  ),
                  TextFormField(
                    initialValue: capacidad.toString(),
                    decoration: InputDecoration(labelText: 'Capacidad'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la capacidad';
                      }
                      return null;
                    },
                    onSaved: (value) => capacidad = int.parse(value!),
                  ),
                  TextFormField(
                    initialValue: descripcion,
                    decoration: InputDecoration(labelText: 'Descripción'),
                    maxLines: 3,
                    onSaved: (value) => descripcion = value ?? '',
                  ),
                  TextFormField(
                    initialValue: latitud.toString(),
                    decoration: InputDecoration(labelText: 'Latitud'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la latitud';
                      }
                      return null;
                    },
                    onSaved: (value) => latitud = double.parse(value!),
                  ),
                  TextFormField(
                    initialValue: longitud.toString(),
                    decoration: InputDecoration(labelText: 'Longitud'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese la longitud';
                      }
                      return null;
                    },
                    onSaved: (value) => longitud = double.parse(value!),
                  ),
                  TextFormField(
                    initialValue: idCategoria,
                    decoration: InputDecoration(labelText: 'ID de Categoría'),
                    onSaved: (value) => idCategoria = value ?? '',
                  ),
                  TextFormField(
                    initialValue: estado.toString(),
                    decoration: InputDecoration(labelText: 'Estado'),
                    keyboardType: TextInputType.number,
                    validator: (value) {
                      if (value == null || value.isEmpty) {
                        return 'Por favor ingrese el estado';
                      }
                      return null;
                    },
                    onSaved: (value) => estado = int.parse(value!),
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
                  if (lugar == null) {
                    _addLugar(nombreLugar, direccionId, capacidad, descripcion,
                        latitud, longitud, idCategoria, estado);
                  } else {
                    _editLugar(lugar.id, nombreLugar, direccionId, capacidad,
                        descripcion, latitud, longitud, idCategoria, estado);
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

  Future<void> _addLugar(
      String nombreLugar,
      String direccionId,
      int capacidad,
      String descripcion,
      double latitud,
      double longitud,
      String idCategoria,
      int estado) async {
    final response = await http.post(
      Uri.parse('http://161.132.48.189:8000/lugares/'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre_lugar': nombreLugar,
        'direccion_id': direccionId,
        'capacidad': capacidad,
        'descripcion': descripcion,
        'latitud': latitud,
        'longitud': longitud,
        'id_categoria': idCategoria,
        'estado': estado,
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        _lugares = fetchLugares();
      });
    } else {
      throw Exception('Failed to add lugar');
    }
  }

  Future<void> _editLugar(
      String id,
      String nombreLugar,
      String direccionId,
      int capacidad,
      String descripcion,
      double latitud,
      double longitud,
      String idCategoria,
      int estado) async {
    final response = await http.put(
      Uri.parse('http://161.132.48.189:8000/lugares/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre_lugar': nombreLugar,
        'direccion_id': direccionId,
        'capacidad': capacidad,
        'descripcion': descripcion,
        'latitud': latitud,
        'longitud': longitud,
        'id_categoria': idCategoria,
        'estado': estado,
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        _lugares = fetchLugares();
      });
    } else {
      throw Exception('Failed to edit lugar');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Ubicaciones', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.green.shade800,
        elevation: 0,
        actions: [
          if (userRole == 'admin')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddEditLugarDialog(),
            ),
        ],
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
              return Center(
                  child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(
                  child: Text('Error: ${snapshot.error}',
                      style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(
                  child: Text('No se encontraron lugares',
                      style: TextStyle(color: Colors.white)));
            } else {
              return ListView.builder(
                itemCount: snapshot.data!.length,
                itemBuilder: (context, index) {
                  final lugar = snapshot.data![index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16.0, vertical: 8.0),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(15)),
                      child: InkWell(
                        onTap: () =>
                            _openGoogleMaps(lugar.latitud, lugar.longitud),
                        child: Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                lugar.nombreLugar,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold, fontSize: 24),
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
                                style: TextStyle(
                                    color: Colors.blue,
                                    fontStyle: FontStyle.italic),
                              ),
                              if (userRole == 'admin')
                                TextButton(
                                  child: Text('Editar'),
                                  onPressed: () =>
                                      _showAddEditLugarDialog(lugar: lugar),
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
