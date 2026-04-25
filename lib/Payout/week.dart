import 'package:flutter/material.dart';

class PayoutWeek extends StatelessWidget {
  const PayoutWeek({super.key});

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