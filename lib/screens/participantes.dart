import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

class Participante {
  final String id;
  final String nombre;
  final String detalle;
  final String equipoId;
  String? nombreEquipo;

  Participante({
    required this.id,
    required this.nombre,
    required this.detalle,
    required this.equipoId,
    this.nombreEquipo,
  });

  factory Participante.fromJson(Map<String, dynamic> json) {
    return Participante(
      id: json['id'],
      nombre: json['nombre'],
      detalle: json['detalle'],
      equipoId: json['equipoId'],
    );
  }
}

class ParticipantesScreen extends StatefulWidget {
  @override
  _ParticipantesScreenState createState() => _ParticipantesScreenState();
}

class _ParticipantesScreenState extends State<ParticipantesScreen> {
  List<Participante> _participantes = [];
  List<Participante> _participantesFiltrados = [];
  TextEditingController _searchController = TextEditingController();
  bool _isLoading = false;
  Timer? _debounce;
  String? userRole;

  @override
  void initState() {
    super.initState();
    _fetchParticipantes();
    _getUserRole(); // Obtener el rol del usuario
  }

  @override
  void dispose() {
    _debounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _getUserRole() async {
    final prefs = await SharedPreferences.getInstance();
    setState(() {
      userRole = prefs.getString('userRole');
    });
  }

  Future<void> _fetchParticipantes() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final response = await http
          .get(Uri.parse('http://161.132.37.95:8080/api/Participante'));
      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _participantes =
            jsonResponse.map((data) => Participante.fromJson(data)).toList();
        setState(() {
          _participantesFiltrados = _participantes;
        });
      } else {
        throw Exception('Failed to load participantes');
      }
    } catch (e) {
      print('Error: $e');
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  Future<void> _searchParticipantes(String query) async {
    setState(() {
      _isLoading = true;
    });

    if (query.isEmpty) {
      setState(() {
        _participantesFiltrados = _participantes;
        _isLoading = false;
      });
      return;
    }

    try {
      final response = await http.get(
        Uri.parse('http://161.132.37.95:8080/api/Participante/search/$query'),
        headers: {'accept': 'text/plain'},
      );

      if (response.statusCode == 200) {
        List jsonResponse = json.decode(response.body);
        _participantesFiltrados =
            jsonResponse.map((data) => Participante.fromJson(data)).toList();
        setState(() {});
      } else {
        throw Exception('Failed to search participantes');
      }
    } catch (e) {
      print('Error: $e');
      setState(() {
        _participantesFiltrados = [];
      });
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  void _onSearchChanged(String query) {
    if (_debounce?.isActive ?? false) _debounce!.cancel();
    _debounce = Timer(const Duration(milliseconds: 500), () {
      _searchParticipantes(query);
    });
  }

  void _showAddEditParticipanteDialog({Participante? participante}) {
    final _formKey = GlobalKey<FormState>();
    String nombre = participante?.nombre ?? '';
    String detalle = participante?.detalle ?? '';

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(participante == null
              ? 'Agregar Participante'
              : 'Editar Participante'),
          content: Form(
            key: _formKey,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                TextFormField(
                  initialValue: nombre,
                  decoration: InputDecoration(labelText: 'Nombre'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor ingrese un nombre'
                      : null,
                  onSaved: (value) => nombre = value!,
                ),
                TextFormField(
                  initialValue: detalle,
                  decoration: InputDecoration(labelText: 'Detalle'),
                  validator: (value) => value == null || value.isEmpty
                      ? 'Por favor ingrese un detalle'
                      : null,
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
                  if (participante == null) {
                    // Agregar nuevo participante
                    _addParticipante(nombre, detalle);
                  } else {
                    // Editar participante existente
                    _editParticipante(participante.id, nombre, detalle);
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

  Future<void> _addParticipante(String nombre, String detalle) async {
    final response = await http.post(
      Uri.parse('http://161.132.37.95:8080/api/Participante'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': nombre,
        'detalle': detalle,
        // Agrega otros campos necesarios aquí
      }),
    );

    if (response.statusCode == 201) {
      setState(() {
        // Actualizar la lista de participantes después de agregar uno nuevo
        _fetchParticipantes();
      });
    } else {
      throw Exception('Failed to add participante');
    }
  }

  Future<void> _editParticipante(
      String id, String nombre, String detalle) async {
    final response = await http.put(
      Uri.parse('http://161.132.37.95:8080/api/Participante/$id'),
      headers: <String, String>{
        'Content-Type': 'application/json; charset=UTF-8',
      },
      body: jsonEncode(<String, dynamic>{
        'nombre': nombre,
        'detalle': detalle,
        // Agrega otros campos necesarios aquí
      }),
    );

    if (response.statusCode == 200) {
      setState(() {
        // Actualizar la lista de participantes después de editar uno existente
        _fetchParticipantes();
      });
    } else {
      throw Exception('Failed to edit participante');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Participantes',
            style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.red.shade800,
        elevation: 0,
        actions: [
          if (userRole == 'admin')
            IconButton(
              icon: Icon(Icons.add),
              onPressed: () => _showAddEditParticipanteDialog(),
            ),
        ],
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.red.shade800, Colors.red.shade200],
          ),
        ),
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  hintText: 'Buscar participantes...',
                  fillColor: Colors.white,
                  filled: true,
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                    borderSide: BorderSide.none,
                  ),
                  prefixIcon: Icon(Icons.search),
                  suffixIcon: IconButton(
                    icon: Icon(Icons.clear),
                    onPressed: () {
                      _searchController.clear();
                      // Llama a la función de búsqueda con un string vacío
                      _searchParticipantes('');
                    },
                  ),
                ),
                onChanged: _onSearchChanged,
              ),
            ),
            Expanded(
              child: _isLoading
                  ? Center(
                      child: CircularProgressIndicator(color: Colors.white))
                  : _participantesFiltrados.isEmpty
                      ? Center(
                          child: Text('No se encontraron participantes',
                              style: TextStyle(color: Colors.white)))
                      : ListView.builder(
                          itemCount: _participantesFiltrados.length,
                          itemBuilder: (context, index) {
                            final participante = _participantesFiltrados[index];
                            return Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16, vertical: 8),
                              child: Card(
                                elevation: 5,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15)),
                                child: Padding(
                                  padding: const EdgeInsets.all(16),
                                  child: Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          CircleAvatar(
                                            backgroundColor:
                                                Colors.red.shade800,
                                            child: Text(
                                              participante.nombre
                                                  .substring(0, 1)
                                                  .toUpperCase(),
                                              style: TextStyle(
                                                  color: Colors.white,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                          SizedBox(width: 16),
                                          Expanded(
                                            child: Text(
                                              participante.nombre,
                                              style: TextStyle(
                                                  fontWeight: FontWeight.bold,
                                                  fontSize: 18),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        participante.detalle,
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 2,
                                      ),
                                      SizedBox(height: 8),
                                      Text(
                                        'Equipo:${participante.nombreEquipo ?? 'Cargando...'}',
                                        style: TextStyle(
                                            color: Colors.grey.shade700),
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          },
                        ),
            ),
          ],
        ),
      ),
    );
  }
}
