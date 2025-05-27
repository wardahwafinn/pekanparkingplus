import 'package:flutter/material.dart';
import 'home.dart';
import 'history.dart';
import 'parking_pay.dart';
import 'notification.dart';
import 'profile.dart';
import 'samanpay.dart';
import 'report.dart';
import 'vehicle.dart';

class CitizenNav extends StatefulWidget {
  const CitizenNav({super.key});

  @override
  State<CitizenNav> createState() => _CitizenNavState();
}

class _CitizenNavState extends State<CitizenNav> {
  int _currentIndex = 0;

  // Method to navigate to SamanPay from homepage
  void navigateToSamanPay() {
    setState(() {
      _currentIndex = 5; // SamanPay is at index 5
    });
  }

  void navigateToVehicle() {
    setState(() {
      _currentIndex = 6; // Vehicle is at index 6
    });
  }

  void navigateToReport() {
    setState(() {
      _currentIndex = 7; // Report is at index 7
    });
  }

  List<Widget> get _screens => [
    HomePageCitizen(
      onNavigateToSamanPay: navigateToSamanPay,
      onNavigateToVehicle: navigateToVehicle,
      onNavigateToReport: navigateToReport,
    ), // Index 0 - Home
    const ParkingHistoryScreen(), // Index 1 - History
    const ParkingPayApp(), // Index 2 - Parking Pay
    const NotificationPage(), // Index 3 - Notification
    const ProfileScreen(), // Index 4 - Profile
    const SamanPayScreen(), // Index 5 - SamanPay
    const VehicleListScreen(), // Index 6 - Vehicle
    const ReportScreen(), // Index 7 - Report
  ];

  @override
  Widget build(BuildContext context) {
    print("Current index: $_currentIndex");

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
    // Show home as selected when on SamanPay (5), Vehicle (6), or Report (7)
    bool isSelected =
        _currentIndex == index ||
        (_currentIndex == 5 && index == 0) || // SamanPay
        (_currentIndex == 6 && index == 0) || // Vehicle
        (_currentIndex == 7 && index == 0); // Report

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
