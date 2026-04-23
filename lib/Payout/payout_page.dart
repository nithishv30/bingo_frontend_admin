import 'package:flutter/material.dart';
import 'today.dart';
import 'yesterday.dart';
import 'week.dart';
import 'month.dart';

class PayoutPage extends StatelessWidget {
  const PayoutPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Payout Details'),
          bottom: const TabBar(
            isScrollable: true,
            tabAlignment: TabAlignment.start,
            labelPadding: EdgeInsets.symmetric(horizontal: 18),
            indicatorSize: TabBarIndicatorSize.label,
            labelStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.bold,
            ),
            unselectedLabelStyle: TextStyle(
              fontSize: 20,
              fontWeight: FontWeight.w500,
            ),
            tabs: [
              Tab(text: 'Today'),
              Tab(text: 'Yesterday'),
              Tab(text: 'This Week'),
              Tab(text: 'This Month'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            TodayPage(),
            YesterdayPage(),
            WeekPage(),
            MonthPage(),
          ],
        ),
      ),
    );
  }
}