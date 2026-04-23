import 'package:flutter/material.dart';

class RiderToday extends StatelessWidget {
  const RiderToday({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'Today',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}