import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/auth_model.dart';
import 'data/taste_memory.dart';
import 'screens/auth/login_screen.dart';

/// Entry point for the application.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthModel()),
        ChangeNotifierProvider(create: (_) => TasteMemoryModel()),
      ],
      child: MaterialApp(
        title: 'My Taste Brain',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const LoginScreen(),
      ),
    );
  }
}
