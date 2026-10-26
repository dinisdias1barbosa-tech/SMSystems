import 'package:flutter/material.dart';

class dashboard extends StatefulWidget {
  const dashboard({super.key});

  @override
  State<dashboard> createState() => _DashboardState();
}

class _DashboardState extends State<dashboard> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Serralharia'),
        backgroundColor: Colors.blueGrey,
      ),
      body: const Center(
        child: Text(
          'Bem-vindo à Serralharia!',
          style: TextStyle(fontSize: 22),
        ),
      ),
    );
  }
}