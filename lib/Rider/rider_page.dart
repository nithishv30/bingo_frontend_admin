import 'package:bingo_admin/Rider/rider_bio.dart';
import 'package:flutter/material.dart';
import 'today.dart';
import 'yesterday.dart';
import 'week.dart';
import 'month.dart';

class RiderPage extends StatelessWidget {
  const RiderPage({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 5,
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Rider Details'),
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
              Tab(text: 'Rider Bio'),
              Tab(text: 'Today'),
              Tab(text: 'Yesterday'),
              Tab(text: 'This Week'),
              Tab(text: 'This Month'),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            RiderBio(),
            RiderToday(),
            RiderYesterday(),
            RiderWeek(),
            RiderMonth(),
          ],
        ),
      ),
    );
  }
}