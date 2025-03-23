import 'package:alarm_practice/Screen/home_screen.dart';
import 'package:flutter/material.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();


  runApp(
    MaterialApp(
      home: HomeScreen(),
    ),
  );
}
