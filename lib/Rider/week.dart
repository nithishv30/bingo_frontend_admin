import 'package:flutter/material.dart';

class RiderWeek extends StatelessWidget {
  const RiderWeek({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'This Week',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}