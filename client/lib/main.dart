import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_flutter/hive_flutter.dart';

import 'models/quest_save_state.dart';
import 'screens/login_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register Hive Adapters
  Hive.registerAdapter(QuestSaveStateAdapter());
  
  // Open Hive box
  await Hive.openBox<QuestSaveState>('quest_saves');

  runApp(
    const ProviderScope(
      child: TNEpicApp(),
    ),
  );
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
