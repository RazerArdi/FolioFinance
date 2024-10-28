import 'package:flutter/material.dart';

class Porto extends StatelessWidget {
  const Porto({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Page 5'),
      ),
      body: const Center(
        child: Text('This is Page 5'),
      ),
    );
  }
}
