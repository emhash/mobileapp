import 'package:flutter/material.dart';
import 'screens/auth/login_screen.dart'; // Make sure this import path is correct

void main() => runApp(MyApp());

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'UniMate',
      theme: ThemeData(
        primaryColor: Color(0xFF1B5E20), // Dark green color
        colorScheme: ColorScheme.fromSeed(
          seedColor: Color(0xFF1B5E20),
          primary: Color(0xFF1B5E20),
          secondary: Color(0xFF4CAF50),
        ),
        useMaterial3: true,
      ),
      home: LoginScreen(), // This should now work correctly
    );
  }
}
