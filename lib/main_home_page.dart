import 'package:bingo_admin/Payout/payout_page.dart';
import 'package:flutter/material.dart';
import 'Upload/upload_page.dart';
import 'User/user_page.dart';
import 'Rider/rider_page.dart';

class MainHomePage extends StatefulWidget {
  final String token;

  const MainHomePage({
    super.key,
    required this.token,
  });

  @override
  State<MainHomePage> createState() => _MainHomePageState();
}

class _MainHomePageState extends State<MainHomePage> {
  int _selectedIndex = 1;

  late final List<Widget> _pages;

  @override
  void initState() {
    super.initState();

    _pages = [
      const PayoutPage(),
      UploadPage(token: widget.token), // ✅ correct
      const RiderPage(),
      const UserPage(),
    ];
  }

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        type: BottomNavigationBarType.fixed,
        onTap: _onItemTapped,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.money),
            label: 'Payout',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.upload_file),
            label: 'Upload',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.bike_scooter),
            label: 'Rider',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.verified_user),
            label: 'User',
          ),
        ],
      ),
    );
  }
}