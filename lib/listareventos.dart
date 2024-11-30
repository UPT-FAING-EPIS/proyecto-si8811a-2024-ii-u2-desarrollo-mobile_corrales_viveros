import 'dart:convert';  // Necesario para jsonDecode
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;  // Importa el paquete http

class EventsListScreen extends StatelessWidget {
  const EventsListScreen({super.key});

  // Obtiene los datos desde la API
  Future<List<Map<String, dynamic>>> fetchEvents() async {
    final url = Uri.parse('http://localhost:50995/Evento');  // URL de la API
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((item) => item as Map<String, dynamic>).toList();
      } else {
        throw Exception('Failed to load events');
      }
    } catch (e) {
      throw Exception('Failed to load events: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Listado de Eventos'),
      ),
      body: FutureBuilder<List<Map<String, dynamic>>>(
        future: fetchEvents(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No hay eventos disponibles'));
          } else {
            final events = snapshot.data!;
            return ListView.builder(
              padding: const EdgeInsets.all(16.0),
              itemCount: events.length,
              itemBuilder: (context, index) {
                final event = events[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: Text(event['nombre'] ?? 'Sin nombre'),
                    subtitle: Text('ID: ${event['id']}'),
                  ),
                );
              },
            );
          }
        },
      ),
    );
  }
}
