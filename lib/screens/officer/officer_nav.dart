import 'package:flutter/material.dart';
import 'home_officer.dart';
import 'statistic.dart';
import 'officer_notif.dart';
import 'officer_profile.dart';
import 'fine_issuance.dart';
import 'reported_cases.dart';
import 'camera.dart';

class OfficerNav extends StatefulWidget {
  const OfficerNav({super.key});

  @override
  State<OfficerNav> createState() => _OfficerNavState();
}

class _OfficerNavState extends State<OfficerNav> {
  int _currentIndex = 0;

  void navigateToFineIssuance() {
    setState(() {
      _currentIndex = 4; // Fine Issuance at index 4
    });
  }

  void navigateToReportedCases() {
    setState(() {
      _currentIndex = 6; 
    });
  }
  void navigateToCameraPage() {
    setState(() {
      _currentIndex = 5; 
    });
  }

  List<Widget> get _screens => [
    OfficerHomePage(
      onNavigateToFineIssuance: navigateToFineIssuance,
      onNavigateToReportedCases: navigateToReportedCases,
    ), // Index 0 - Home
    const OfficerStatisticsPage(), // Index 1 - Statistics
    const OfficerNotificationsPage(), // Index 2 - Notifications
    const OfficerProfilePage(), // Index 3 - Profile
    const FineIssuancePage(), // Index 4 - Fine Issuance
    const CameraPage(),
    const ReportedCasesPage(), 
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _screens[_currentIndex],
      bottomNavigationBar: _buildBottomNavigationBar(),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 75,
      decoration: const BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Colors.white, Color(0xFF87CEEB)],
        ),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          _buildNavItem(Icons.home_outlined, 'Home', 0),
          _buildNavItem(Icons.bar_chart_outlined, 'Statistics', 1),
          _buildCenterButton(),
          _buildNavItem(Icons.notifications_outlined, 'Notification', 2),
          _buildNavItem(Icons.person_outline, 'Profile', 3),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected =
        _currentIndex == index ||
        (_currentIndex == 4 && index == 0) || // Fine Issuance
        (_currentIndex == 6 && index == 0); // Reported Cases

    return GestureDetector(
      onTap: () => setState(() => _currentIndex = index),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: isSelected ? Colors.blue : Colors.grey, size: 24),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                color: isSelected ? Colors.blue : Colors.grey,
                fontSize: 12,
                fontWeight: isSelected ? FontWeight.w600 : FontWeight.normal,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCenterButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 5), 
      child: Transform.translate(
        offset: const Offset(0.0, -5.0),
        child: Container(
          padding: const EdgeInsets.only(top: 4, bottom: 6),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                width: 65,
                height: 65,
                decoration: const BoxDecoration(
                  color: Color(0xFF4A90E2),
                  shape: BoxShape.circle,
                ),
                child: const Center(
                  child: Icon(Icons.videocam, color: Colors.white, size: 30),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Placeholder pages - you can replace these with your actual implementations
class OfficerStatisticsPage extends StatelessWidget {
  const OfficerStatisticsPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'Statistics',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Container(),
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF87CEEB), Colors.white],
            stops: [0.0, 0.3],
          ),
        ),
        child: const Center(
          child: Text(
            'Statistics Page\n(To be implemented)',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 18),
          ),
        ),
      ),
    );
  }
}
