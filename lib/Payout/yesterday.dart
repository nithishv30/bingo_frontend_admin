import 'package:flutter/material.dart';

class PayoutYesterday extends StatelessWidget {
  const PayoutYesterday({super.key});

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