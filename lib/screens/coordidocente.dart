import 'package:flutter/material.dart';

class CoordDocenteScreen extends StatelessWidget {
  final List<String> categorias = [
    'BAILE MODERNO', 'BAILETON', 'BARRA', 'CANTO INTERNACIONAL',
    'CANTO NACIONAL', 'CREACION POETICA', 'DANZAS NACIONALES',
    'DECLAMACION', 'INVENTO TECNOLOGICO', 'MARINERA', 'MISTER',
    'ORTOGRAFIA', 'TEATRO', 'TIK TOK'
  ];

  final Map<String, List<Map<String, String>>> contactos = {
    'BAILE MODERNO': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'BAILETON': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'BARRA': [
      {'nombre': 'Mg. Marlene Enriquez Huayta', 'telefono': '952638343'},
    ],
    'CANTO INTERNACIONAL': [
      {'nombre': 'Mg. Marlene Enriquez Huayta', 'telefono': '952638343'},
    ],
    'CANTO NACIONAL': [
      {'nombre': 'Mg. Marlene Enriquez Huayta', 'telefono': '952638343'},
    ],
    'CREACION POETICA': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'DANZAS NACIONALES': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'DECLAMACION': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'INVENTO TECNOLOGICO': [
      {'nombre': 'Mg. Erbert Osco Mamani', 'telefono': '952307605'},
    ],
    'MARINERA': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'MISTER': [
      {'nombre': 'Mg. Marlene Enriquez Huayta', 'telefono': '952638343'},
    ],
    'ORTOGRAFIA': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'TEATRO': [
      {'nombre': 'Mg. Vanessa Juárez Medina', 'telefono': '952951035'},
    ],
    'TIK TOK': [
      {'nombre': 'Mg. Marlene Enriquez Huayta', 'telefono': '952638343'},
    ],
  };

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Coordinadores Docentes', style: TextStyle(fontWeight: FontWeight.bold)),
        backgroundColor: Colors.indigo.shade800,
        elevation: 0,
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Colors.indigo.shade800, Colors.indigo.shade200],
          ),
        ),
        child: ListView.builder(
          itemCount: categorias.length,
          itemBuilder: (context, index) {
            return Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Card(
                elevation: 5,
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                child: ListTile(
                  contentPadding: EdgeInsets.all(16),
                  title: Text(
                    categorias[index],
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                  trailing: Icon(Icons.arrow_forward_ios, color: Colors.indigo.shade800),
                  onTap: () {
                    _mostrarContactos(context, categorias[index]);
                  },
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  void _mostrarContactos(BuildContext context, String categoria) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Contactos - $categoria'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: contactos[categoria]?.map((contacto) {
                return ListTile(
                  title: Text(contacto['nombre'] ?? ''),
                  subtitle: Text(contacto['telefono'] ?? ''),
                  leading: CircleAvatar(
                    backgroundColor: Colors.indigo.shade200,
                    child: Icon(Icons.person, color: Colors.indigo.shade800),
                  ),
                );
              }).toList() ?? [],
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
}