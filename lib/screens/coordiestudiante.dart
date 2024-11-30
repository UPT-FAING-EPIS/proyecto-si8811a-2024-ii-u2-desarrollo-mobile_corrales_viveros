import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CoordEstudianteScreen extends StatefulWidget {
  @override
  _CoordEstudianteScreenState createState() => _CoordEstudianteScreenState();
}

class _CoordEstudianteScreenState extends State<CoordEstudianteScreen> {
  late Future<List<Categoria>> _categorias;

  @override
  void initState() {
    super.initState();
    _categorias = fetchCategorias();
  }

  Future<List<Categoria>> fetchCategorias() async {
    // Simula una llamada a la API
    await Future.delayed(Duration(seconds: 1));
    return categorias.map((c) => Categoria.fromJson(c)).toList();
  }

  IconData getIconForCategory(String categoryName) {
    switch (categoryName) {
      case 'BAILE MODERNO':
      case 'BAILETON':
        return Icons.music_note;
      case 'BARRA':
        return Icons.group;
      case 'CANTO INTERNACIONAL':
      case 'CANTO NACIONAL':
        return Icons.mic;
      case 'CREACION POETICA':
        return Icons.create;
      case 'DANZAS NACIONALES':
      case 'MARINERA':
        return Icons.directions_run;
      case 'DECLAMACION':
        return Icons.record_voice_over;
      case 'INVENTO TECNOLOGICO':
        return Icons.lightbulb;
      case 'MISTER':
        return Icons.star;
      case 'ORTOGRAFIA':
        return Icons.spellcheck;
      case 'TEATRO':
        return Icons.theater_comedy;
      case 'TIK TOK':
        return Icons.video_call;
      default:
        return Icons.category;
    }
  }

  void _showContactosDialog(BuildContext context, Categoria categoria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contactos de ${categoria.nombre}',
              style: TextStyle(fontWeight: FontWeight.bold, color: Colors.teal.shade800)),
          content: Container(
            width: double.maxFinite,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: categoria.contactos.length,
              itemBuilder: (context, index) {
                final contacto = categoria.contactos[index];
                return Card(
                  elevation: 2,
                  margin: EdgeInsets.symmetric(vertical: 4, horizontal: 0),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: Colors.teal.shade200,
                      child: Icon(Icons.person, color: Colors.teal.shade800),
                    ),
                    title: Text(contacto.nombre,
                        style: TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(contacto.escuela),
                        Text(contacto.telefono),
                      ],
                    ),
                    trailing: IconButton(
                      icon: Icon(Icons.copy, color: Colors.teal.shade800),
                      onPressed: () {
                        Clipboard.setData(ClipboardData(text: contacto.telefono));
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text('Número copiado al portapapeles')),
                        );
                      },
                    ),
                  ),
                );
              },
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('Cerrar', style: TextStyle(color: Colors.teal.shade800)),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinadores Estudiantes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.teal.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.teal.shade800, Colors.teal.shade200],
          ),
        ),
        child: FutureBuilder<List<Categoria>>(
          future: _categorias,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(child: CircularProgressIndicator(color: Colors.white));
            } else if (snapshot.hasError) {
              return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(color: Colors.white)));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Center(child: Text('No se encontraron categorías', style: TextStyle(color: Colors.white)));
            } else {
              final categorias = snapshot.data!;
              return ListView.builder(
                itemCount: categorias.length,
                itemBuilder: (context, index) {
                  final categoria = categorias[index];
                  return Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    child: Card(
                      elevation: 5,
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                      child: ListTile(
                        contentPadding: EdgeInsets.all(16),
                        leading: Icon(
                          getIconForCategory(categoria.nombre),
                          color: Colors.teal.shade800,
                          size: 30,
                        ),
                        title: Text(
                          categoria.nombre,
                          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                        ),
                        subtitle: Text(
                          '${categoria.contactos.length} contactos',
                          style: TextStyle(color: Colors.grey.shade700),
                        ),
                        trailing: Icon(Icons.arrow_forward_ios, color: Colors.teal.shade800),
                        onTap: () {
                          _showContactosDialog(context, categoria);
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

class Categoria {
  final String nombre;
  final List<Contacto> contactos;

  Categoria({required this.nombre, required this.contactos});

  factory Categoria.fromJson(Map<String, dynamic> json) {
    var contactosList = json['contactos'] as List;
    List<Contacto> contactos = contactosList.map((i) => Contacto.fromJson(i)).toList();
    return Categoria(
      nombre: json['nombre'],
      contactos: contactos,
    );
  }
}

class Contacto {
  final String nombre;
  final String escuela;
  final String telefono;

  Contacto({required this.nombre, required this.escuela, required this.telefono});

  factory Contacto.fromJson(Map<String, dynamic> json) {
    return Contacto(
      nombre: json['nombre'],
      escuela: json['escuela'],
      telefono: json['telefono'],
    );
  }
}

// Datos completos
final categorias = [
  {
    "nombre": "BAILE MODERNO",
    "contactos": [
      {"nombre": "Vega Pampa Valeria Sofia", "escuela": "EPII", "telefono": "970509098"},
      {"nombre": "MEDINA QUISPE JOAN CHRISTIAN", "escuela": "EPIS", "telefono": "931447550"}
    ]
  },
  {
    "nombre": "BAILETON",
    "contactos": [
      {"nombre": "Joaquín Enrique Valdivia esqueiros", "escuela": "EPIC", "telefono": "954204671"}
    ]
  },
  {
    "nombre": "BARRA",
    "contactos": [
      {"nombre": "Atencio Vargas Emanuel", "escuela": "EPIS", "telefono": "944084507"},
      {"nombre": "Chambilla Quiroga Renato Marcelo", "escuela": "EPII", "telefono": "952820084"}
    ]
  },
  {
    "nombre": "CANTO INTERNACIONAL",
    "contactos": [
      {"nombre": "Mamani Campos Victor Adrian", "escuela": "EPIC", "telefono": "958985034"}
    ]
  },
  {
    "nombre": "CANTO NACIONAL",
    "contactos": [
      {"nombre": "Mamani Campos Victor Adrian", "escuela": "EPIC", "telefono": "958985034"}
    ]
  },
  {
    "nombre": "CREACION POETICA",
    "contactos": [
      {"nombre": "Nicho Vera Enrique Josué", "escuela": "EPIS", "telefono": "987503337"},
      {"nombre": "Valdez Fernadez André Fernando", "escuela": "EPIS", "telefono": "993261391"}
    ]
  },
  {
    "nombre": "DANZAS NACIONALES",
    "contactos": [
      {"nombre": "Houghton Miranda Piero André", "escuela": "EPIC", "telefono": "985300596"}
    ]
  },
  {
    "nombre": "DECLAMACION",
    "contactos": [
      {"nombre": "Poma Manchego Rene Manuel", "escuela": "EPIS", "telefono": "980363662"}
    ]
  },
  {
    "nombre": "INVENTO TECNOLOGICO",
    "contactos": [
      {"nombre": "Chávez Yataco Pedroluis Eduardo", "escuela": "EPIAM", "telefono": "993600024"},
      {"nombre": "Chambilla Quiroga Renato Marcelo", "escuela": "EPII", "telefono": "952820084"}
    ]
  },
  {
    "nombre": "MARINERA",
    "contactos": [
      {"nombre": "Callata Quenta Liz", "escuela": "EPIC", "telefono": ""}
    ]
  },
  {
    "nombre": "MISTER",
    "contactos": [
      {"nombre": "Valenza Copa Gabriela Indira", "escuela": "EPIC", "telefono": "982944699"}
    ]
  },
  {
    "nombre": "ORTOGRAFIA",
    "contactos": [
      {"nombre": "Catunta Monasterio Cristell Ariana", "escuela": "EPII", "telefono": "983353338"},
      {"nombre": "Llanos Pizarro Belen Alexandra", "escuela": "EPII", "telefono": "937607500"}
    ]
  },
  {
    "nombre": "TEATRO",
    "contactos": [
      {"nombre": "Valenza Copa Gabriela Indira", "escuela": "EPIC", "telefono": "982944699"},
      {"nombre": "Vargas Calizaya Santiago Jesus", "escuela": "EPII", "telefono": "982506256"}
    ]
  },
  {
    "nombre": "TIK TOK",
    "contactos": [
      {"nombre": "AZOCAR OSORIO KATHERINE DEL PILAR", "escuela": "EPII", "telefono": "985123665"},
      {"nombre": "LANCHIPA RAMOS CAMILA FERNANDA", "escuela": "EPII", "telefono": "982758315"}
    ]
  }
];