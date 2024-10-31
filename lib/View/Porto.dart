import 'package:flutter/material.dart';

class Porto extends StatelessWidget {
  const Porto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page Porto'),
      ),
      body: const Center(
        child: Text('This is Page Porto'),
      ),
    );
  }
}
