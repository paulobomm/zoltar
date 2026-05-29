import 'package:flutter/material.dart';
import 'screens/home_screen.dart';

void main() {
  runApp(const ZoltarApp());
}

class ZoltarApp extends StatelessWidget {
  const ZoltarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Zoltar o Grande',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.deepPurple,
          brightness: Brightness.dark,
        ),
        useMaterial3: true,
      ),
      home: const HomeScreen(),
    );
  }
}
