import 'package:flutter/material.dart';
import 'screens/scan_screen.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'CardCapture OCR',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blueAccent),
        // Hna sllahna l-error: beddelna smiya l'useMaterial3
        useMaterial3: true, 
      ),
      home: const ScanScreen(),
    );
  }
}