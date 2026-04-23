import 'package:flutter/material.dart';

class RiderYesterday extends StatelessWidget {
  const RiderYesterday({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Yesterday',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}