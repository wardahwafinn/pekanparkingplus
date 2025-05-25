import 'package:flutter/material.dart';
import 'home_officer.dart';
import 'camera.dart';
import 'statistic.dart';
import 'notification.dart';
import 'profile.dart';

class OfficerNav extends StatefulWidget {
  const OfficerNav({super.key});

  @override
  State<OfficerNav> createState() => _OfficerNavState();
}

class _OfficerNavState extends State<OfficerNav> {
  int _currentIndex = 0;
  final List<Widget> _screens = [
    HomePageOfficer(),
    CameraPage(),
    StatisticPage(),
    OfficerNotificationPage(),
    OfficerProfilePage(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) => setState(() => _currentIndex = index),
        selectedItemColor: Colors.blue,
        unselectedItemColor: Colors.grey,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home), label: "Home"),
          BottomNavigationBarItem(icon: Icon(Icons.camera), label: "Camera"),
          BottomNavigationBarItem(icon: Icon(Icons.bar_chart), label: "Stats"),
          BottomNavigationBarItem(icon: Icon(Icons.notifications), label: "Notifications"),
          BottomNavigationBarItem(icon: Icon(Icons.person), label: "Profile"),
        ],
      ),
    );
  }
}
