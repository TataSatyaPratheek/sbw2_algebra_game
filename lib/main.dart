import 'package:flutter/material.dart';
import 'environment.dart';  // Importing the environment setup

void main() {
  runApp(const AlgebraicKingdomApp());
}

class AlgebraicKingdomApp extends StatelessWidget {
  const AlgebraicKingdomApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Valley of Simple Equations',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: Environment(),  // Start the app with the Environment widget
    );
  }
}
