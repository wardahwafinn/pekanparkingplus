import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

// Main App
class ParkingPayApp extends StatelessWidget {
  const ParkingPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ParkingPay',
      theme: ThemeData(primarySwatch: Colors.blue, fontFamily: 'San Francisco'),
      home: const ParkingPayScreen(),
      debugShowCheckedModeBanner: false,
    );
  }
}

void main() {
  runApp(ParkingPayApp());
}

// Main Parking Screen
class ParkingPayScreen extends StatefulWidget {
  const ParkingPayScreen({super.key});

  @override
  State<ParkingPayScreen> createState() => _ParkingPayScreenState();
}

class _ParkingPayScreenState extends State<ParkingPayScreen> {
  String selectedVehicle = 'VFK4567';

  final List<Map<String, String>> hourlyRates = [
    {'duration': '1 Hour', 'price': 'RM0.60'},
    {'duration': '2 Hours', 'price': 'RM1.20'},
    {'duration': '3 Hours', 'price': 'RM1.80'},
    {'duration': '4 Hours', 'price': 'RM2.40'},
  ];

  final List<Map<String, String>> monthlyRates = [
    {'duration': '1 Month', 'price': 'RM65.00'},
    {'duration': '3 Months', 'price': 'RM195.00'},
    {'duration': '6 Months', 'price': 'RM390.00'},
    {'duration': '12 Months', 'price': 'RM780.00'},
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ParkingPay',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: Container(),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        child: Column(
          children: [
            Expanded(
              child: ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  const SizedBox(height: 20),
                  // Vehicle Selection
                  _buildSectionHeader('Your Vehicle'),
                  const SizedBox(height: 8),
                  _buildVehicleSelector(),
                  const SizedBox(height: 24),
                  // Buy Parking Section
                  _buildSectionHeader('Buy Parking'),
                  const SizedBox(height: 16),
                  // Hourly Section
                  _buildSubSectionHeader('Hourly'),
                  const SizedBox(height: 8),
                  ...hourlyRates.map(
                    (rate) =>
                        _buildParkingOption(rate['duration']!, rate['price']!),
                  ),
                  const SizedBox(height: 24),
                  // Monthly Section
                  _buildSubSectionHeader('Monthly'),
                  const SizedBox(height: 8),
                  ...monthlyRates.map(
                    (rate) =>
                        _buildParkingOption(rate['duration']!, rate['price']!),
                  ),
                  const SizedBox(height: 100),
                ],
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 14,
          color: Colors.black87,
          fontWeight: FontWeight.w500,
        ),
      ),
    );
  }

  Widget _buildSubSectionHeader(String title) {
    return Align(
      alignment: Alignment.centerLeft,
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 12,
          color: Colors.grey,
          fontWeight: FontWeight.w400,
        ),
      ),
    );
  }

  Widget _buildVehicleSelector() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            selectedVehicle,
            style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w500,
              color: Colors.black,
            ),
          ),
          const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
        ],
      ),
    );
  }

  Widget _buildParkingOption(String duration, String price) {
    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder:
                  (context) => ParkingTransactionScreen(
                    vehicleNumber: selectedVehicle,
                    duration: duration,
                    price: price,
                  ),
            ),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              duration,
              style: const TextStyle(fontSize: 16, color: Colors.black),
            ),
            Text(
              price,
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
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
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.history, 'History', false),
          _buildParkingButton(),
          _buildNavItem(Icons.notifications_outlined, 'Notification', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF4A90E2) : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF4A90E2) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildParkingButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF4A90E2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.local_parking, color: Colors.white, size: 30),
    );
  }
}

// Parking Transaction Screen
class ParkingTransactionScreen extends StatelessWidget {
  final String vehicleNumber;
  final String duration;
  final String price;

  const ParkingTransactionScreen({
    super.key,
    required this.vehicleNumber,
    required this.duration,
    required this.price,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF87CEEB),
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        title: const Text(
          'ParkingPay',
          style: TextStyle(
            color: Colors.black,
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.black),
          onPressed: () => Navigator.pop(context),
        ),
        systemOverlayStyle: SystemUiOverlayStyle.dark,
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
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 20),
                    // Vehicle Section
                    _buildSectionHeader('Your Vehicle'),
                    const SizedBox(height: 8),
                    _buildInfoCard(vehicleNumber, centered: true),
                    const SizedBox(height: 24),
                    // Parking For Section
                    _buildSectionHeader('Parking For'),
                    const SizedBox(height: 8),
                    _buildInfoCard(duration, centered: true),
                    const SizedBox(height: 24),
                    // Total Section
                    _buildSectionHeader('Total'),
                    const SizedBox(height: 8),
                    _buildInfoCard(price, centered: true, isTotal: true),
                    const SizedBox(height: 40),
                    // Pay Button
                    Center(
                      child: ElevatedButton(
                        onPressed: () {
                          // Handle payment logic here
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(
                              content: Text('Payment processed successfully!'),
                              backgroundColor: Colors.green,
                            ),
                          );
                        },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                        ),
                        child: const Text(
                          'Pay',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            _buildBottomNavigationBar(),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 14,
        color: Colors.black87,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _buildInfoCard(
    String content, {
    bool centered = false,
    bool isTotal = false,
  }) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey[200]!),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 4,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Text(
        content,
        textAlign: centered ? TextAlign.center : TextAlign.left,
        style: TextStyle(
          fontSize: isTotal ? 20 : 18,
          fontWeight: isTotal ? FontWeight.w600 : FontWeight.w500,
          color: Colors.black,
        ),
      ),
    );
  }

  Widget _buildBottomNavigationBar() {
    return Container(
      height: 80,
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
          _buildNavItem(Icons.home_outlined, 'Home', false),
          _buildNavItem(Icons.history, 'History', false),
          _buildParkingButton(),
          _buildNavItem(Icons.notifications_outlined, 'Notification', false),
          _buildNavItem(Icons.person_outline, 'Profile', false),
        ],
      ),
    );
  }

  Widget _buildNavItem(IconData icon, String label, bool isActive) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Icon(
          icon,
          color: isActive ? const Color(0xFF4A90E2) : Colors.grey[600],
          size: 24,
        ),
        const SizedBox(height: 4),
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            color: isActive ? const Color(0xFF4A90E2) : Colors.grey[600],
            fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
          ),
        ),
      ],
    );
  }

  Widget _buildParkingButton() {
    return Container(
      width: 60,
      height: 60,
      decoration: const BoxDecoration(
        color: Color(0xFF4A90E2),
        shape: BoxShape.circle,
      ),
      child: const Icon(Icons.local_parking, color: Colors.white, size: 30),
    );
  }
}
