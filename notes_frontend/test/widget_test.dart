import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:notes_frontend/main.dart';

void main() {
  testWidgets('Notes home screen displays', (WidgetTester tester) async {
    await tester.pumpWidget(const NotesApp());

    // Should find 'Notes' title on the app bar
    expect(find.text('Notes'), findsOneWidget);

    // FAB should exist
    expect(find.byType(FloatingActionButton), findsOneWidget);
  });
}
