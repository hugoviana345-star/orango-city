import 'package:flutter/material.dart';
import 'telas/menu_inicial.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const OrangoApp());
}

class OrangoApp extends StatelessWidget {
  const OrangoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Orango City',
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        fontFamily: 'Roboto',
      ),
      home: const MenuInicial(),
    );
  }
}
