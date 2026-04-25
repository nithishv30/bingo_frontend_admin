import 'package:flutter/material.dart';

class PayoutMonth extends StatelessWidget {
  const PayoutMonth ({super.key});

  @override
  Widget build(BuildContext context) {
    return const Center(
      child: Text(
        'This Month',
        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
      ),
    );
  }
}