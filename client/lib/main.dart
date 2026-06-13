import 'package:flutter/material.dart';

import 'screens/login_screen.dart';

void main() {
  runApp(const TNEpicApp());
}

class TNEpicApp extends StatelessWidget {
  const TNEpicApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'TN-Epic',
      debugShowCheckedModeBanner: false,
      home: LoginScreen(),
    );
  }
}
