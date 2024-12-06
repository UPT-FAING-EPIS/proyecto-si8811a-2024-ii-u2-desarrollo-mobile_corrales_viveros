// This is a basic Flutter widget test.
//
// To perform an interaction with a widget in your test, use the WidgetTester
// utility in the flutter_test package. For example, you can send tap and scroll
// gestures. You can also use WidgetTester to find child widgets in the widget
// tree, read text, and verify that the values of widget properties are correct.

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:florales/main.dart';

void main() {
  testWidgets('Login button test', (WidgetTester tester) async {
    // Construye la app y activa un frame
    await tester.pumpWidget(const MyApp());

    // Verifica que el título existe
    expect(find.text('Juegos Florales UPT'), findsOneWidget);
    expect(find.text('2024 - II'), findsOneWidget);

    // Verifica que el botón de inicio de sesión existe
    expect(find.text('Iniciar sesión con Microsoft'), findsOneWidget);
    expect(find.byIcon(Icons.login), findsOneWidget);
  });
}
