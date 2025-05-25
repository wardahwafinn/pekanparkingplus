import 'package:flutter/material.dart';

class ParkingHistoryScreen extends StatelessWidget {
  const ParkingHistoryScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB), // Sky blue background
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'History',
          style: TextStyle(
            color: Colors.black,
            fontSize: 30,
            fontWeight: FontWeight.w600,
            fontFamily: 'San Francisco', // iOS-like font
          ),
        ),
        centerTitle: true,
        leading: Container(), // Remove back button
      ),
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [
              Color(0xFF87CEEB), // Sky blue
              Colors.white,
            ],
            stops: [0.0, 0.1],
          ),
        ),
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            const SizedBox(height: 50),
            _buildHistoryItem(
              title: '1 HOUR parking for CEM1233',
              date: '10 Mar 25 | 12:58 PM',
              amount: '-RM0.60',
              isNegative: true,
            ),
            const SizedBox(height: 12),
            _buildHistoryItem(
              title: 'Parking fine pay for VFK4567',
              date: '9 Mar 25 | 8:01 AM',
              amount: '-RM10.00',
              isNegative: true,
            ),
            const SizedBox(height: 12),
            _buildHistoryItem(
              title: 'Reload PekanParking Plus Wallet',
              date: '9 Mar 25 | 8:01 AM',
              amount: '+RM100.00',
              isNegative: false,
            ),
            const SizedBox(height: 12),
            _buildHistoryItem(
              title: '3 HOUR parking for VFK4567',
              date: '21 Apr 25 | 8:01 AM',
              amount: '-RM1.80',
              isNegative: true,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    required bool isNegative,
  }) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: Colors.black87,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  date,
                  style: TextStyle(fontSize: 13, color: Colors.grey[600]),
                ),
              ],
            ),
          ),
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: isNegative ? Colors.red : Colors.green,
            ),
          ),
        ],
      ),
    );
  }
}
