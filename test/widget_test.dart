
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

void main() {
  testWidgets('Interface Flutter funciona', (tester) async {
    await tester.pumpWidget(
      const MaterialApp(
        home: Scaffold(
          body: Center(
            child: Text('Orango City'),
          ),
        ),
      ),
    );

    expect(
      find.text('Orango City'),
      findsOneWidget,
    );
  });
}
