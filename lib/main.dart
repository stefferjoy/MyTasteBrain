import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'data/taste_memory.dart';
import 'screens/home_screen.dart';

/// Entry point for the application. Wraps the [HomeScreen] in a
/// [ChangeNotifierProvider] so that widgets deeper in the tree can react
/// to changes in the user's food history and preferences. This is
/// deliberately minimal so that you can add additional providers or
/// configuration later on.
void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => TasteMemoryModel(),
      child: MaterialApp(
        title: 'My Taste Brain',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.green),
          useMaterial3: true,
        ),
        home: const HomeScreen(),
      ),
    );
  }
}
