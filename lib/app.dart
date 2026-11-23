import 'package:flutter/material.dart';

import 'features/home/home_page.dart';

class PermissionsApp extends StatelessWidget {
  const PermissionsApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Permisos en Flutter',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.indigo),
      home: const HomePage(),
    );
  }
}
