// Updated citizen_nav.dart - Fix for black screen issue
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'history.dart';
import 'parking_pay.dart';
import 'notification.dart';
import 'profile.dart';
import 'samanpay.dart';
import 'report.dart';
import 'vehicle.dart';
import 'chatbot.dart';
import 'reload.dart';

class CitizenNav extends StatefulWidget {
  const CitizenNav({super.key});

  @override
  State<CitizenNav> createState() => _CitizenNavState();
}

class _CitizenNavState extends State<CitizenNav> {
  int _currentIndex = 0;

  // FIXED: Use navigation instead of changing index for sub-screens
  void navigateToSamanPay() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const SamanPayScreen()),
    );
  }

  void navigateToVehicle() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const VehicleListScreen()),
    );
  }

  void navigateToReport() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ReportScreen()),
    );
  }

  void navigateToChatbot() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const ChatbotScreen()),
    );
  }

  void navigateToReload() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const BalanceReloadScreen()),
    ).then((_) {
      // Refresh the home screen when returning from reload
      if (_currentIndex == 0) {
        setState(() {});
      }
    });
  }

  // Logout function
  Future<void> _logout() async {
    try {
      await FirebaseAuth.instance.signOut();
    } catch (e) {
      ScaffoldMessenger.of(
        context,
      ).showSnackBar(SnackBar(content: Text('Error logging out: $e')));
    }
  }

  void _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context);
                _logout();
              },
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text(
                'Logout',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        );
      },
    );
  }

  // FIXED: Only include main navigation screens
  List<Widget> get _screens => [
    HomePageCitizen(
      onNavigateToSamanPay: navigateToSamanPay,
      onNavigateToVehicle: navigateToVehicle,
      onNavigateToReport: navigateToReport,
      onNavigateToChatbot: navigateToChatbot,
      onNavigateToReload: navigateToReload,
      onLogout: _showLogoutDialog,
    ), // Index 0 - Home
    const ParkingHistoryScreen(), // Index 1 - History
    const ParkingPayApp(), // Index 2 - Parking Pay
    const NotificationScreen(), // Index 3 - Notification
    ProfileScreen(onLogout: _showLogoutDialog), // Index 4 - Profile
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
          _buildNavItem(Icons.history, 'History', 1),
          _buildParkingButton(),
          _buildNavItem(Icons.notifications_outlined, 'Notification', 3),
          _buildNavItem(Icons.person_outline, 'Profile', 4),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, int index) {
    bool isSelected = _currentIndex == index;

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

  Widget _buildParkingButton() {
    return GestureDetector(
      onTap: () => setState(() => _currentIndex = 2),
      child: Transform.translate(
        offset: const Offset(6.0, -5.0),
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
                  child: Icon(
                    Icons.local_parking,
                    color: Colors.white,
                    size: 30,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  static _CitizenNavState? of(BuildContext context) {
    return context.findAncestorStateOfType<_CitizenNavState>();
  }
}
