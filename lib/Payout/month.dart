import 'package:flutter/material.dart';

class MonthPage extends StatelessWidget {
  const MonthPage({super.key});

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