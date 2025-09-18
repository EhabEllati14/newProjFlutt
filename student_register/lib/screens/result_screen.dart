import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Helloooo'),
      ),
      body: const Center(
        child: Text('Hello from screen2'),
      ),
    );
  }
}