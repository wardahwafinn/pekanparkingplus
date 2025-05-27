import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

// Main App
class ParkingPayApp extends StatelessWidget {
  const ParkingPayApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const ParkingPayScreen();
  }
}

// Main Parking Screen
class ParkingPayScreen extends StatefulWidget {
  const ParkingPayScreen({super.key});

  @override
  State<ParkingPayScreen> createState() => _ParkingPayScreenState();
}

class _ParkingPayScreenState extends State<ParkingPayScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  
  String selectedVehicle = '';
  List<Map<String, dynamic>> userVehicles = [];
  bool isLoadingVehicles = true;

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
  void initState() {
    super.initState();
    _loadUserVehicles();
  }

  Future<void> _loadUserVehicles() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final vehicles = await _dbService.getUserVehicles(user.uid);
        setState(() {
          userVehicles = vehicles;
          // Set selected vehicle to the currently selected one or first vehicle
          final selected = vehicles.firstWhere(
            (v) => v['isSelected'] == true,
            orElse: () => vehicles.isNotEmpty ? vehicles.first : {},
          );
          selectedVehicle = selected['plate'] ?? '';
          isLoadingVehicles = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingVehicles = false;
      });
      print('Error loading vehicles: $e');
    }
  }

  void _showVehicleSelector() {
    if (userVehicles.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Please add a vehicle first in the Vehicle section'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        padding: const EdgeInsets.all(16),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Select Vehicle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 16),
            ...userVehicles.map((vehicle) => ListTile(
              title: Text(vehicle['plate']),
              subtitle: Text(vehicle['owner']),
              trailing: selectedVehicle == vehicle['plate']
                  ? const Icon(Icons.check, color: Colors.green)
                  : null,
              onTap: () {
                setState(() {
                  selectedVehicle = vehicle['plate'];
                });
                Navigator.pop(context);
              },
            )),
          ],
        ),
      ),
    );
  }

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
    if (isLoadingVehicles) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.grey[200]!),
        ),
        child: const Row(
          children: [
            SizedBox(
              width: 20,
              height: 20,
              child: CircularProgressIndicator(strokeWidth: 2),
            ),
            SizedBox(width: 12),
            Text('Loading vehicles...'),
          ],
        ),
      );
    }

    if (userVehicles.isEmpty) {
      return Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        decoration: BoxDecoration(
          color: Colors.orange[50],
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: Colors.orange[200]!),
        ),
        child: const Row(
          children: [
            Icon(Icons.warning, color: Colors.orange),
            SizedBox(width: 12),
            Expanded(
              child: Text(
                'No vehicles found. Please add a vehicle first.',
                style: TextStyle(color: Colors.orange),
              ),
            ),
          ],
        ),
      );
    }

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
      child: GestureDetector(
        onTap: _showVehicleSelector,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(
              selectedVehicle.isNotEmpty ? selectedVehicle : 'Select Vehicle',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w500,
                color: selectedVehicle.isNotEmpty ? Colors.black : Colors.grey,
              ),
            ),
            const Icon(Icons.chevron_right, color: Colors.grey, size: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildParkingOption(String duration, String price) {
    final isEnabled = selectedVehicle.isNotEmpty;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          onTap: isEnabled
              ? () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ParkingTransactionScreen(
                        vehicleNumber: selectedVehicle,
                        duration: duration,
                        price: price,
                      ),
                    ),
                  );
                }
              : null,
          borderRadius: BorderRadius.circular(8),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
            decoration: BoxDecoration(
              color: isEnabled ? Colors.white : Colors.grey[100],
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: Colors.grey[200]!),
              boxShadow: isEnabled
                  ? [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.05),
                        blurRadius: 4,
                        offset: const Offset(0, 2),
                      ),
                    ]
                  : null,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  duration,
                  style: TextStyle(
                    fontSize: 16,
                    color: isEnabled ? Colors.black : Colors.grey,
                  ),
                ),
                Text(
                  price,
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w500,
                    color: isEnabled ? Colors.black : Colors.grey,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

// Parking Transaction Screen
class ParkingTransactionScreen extends StatefulWidget {
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
  State<ParkingTransactionScreen> createState() => _ParkingTransactionScreenState();
}

class _ParkingTransactionScreenState extends State<ParkingTransactionScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  bool isProcessing = false;

  Future<void> _processPayment() async {
    setState(() {
      isProcessing = true;
    });

    try {
      final user = _auth.currentUser;
      if (user == null) {
        throw Exception('User not authenticated');
      }

      // Extract amount from price string (e.g., "RM0.60" -> 0.60)
      final priceStr = widget.price.replaceAll('RM', '').replaceAll(',', '');
      final amount = double.parse(priceStr);

      // Check user balance first
      final currentBalance = await _dbService.getUserBalance(user.uid);
      if (currentBalance < amount) {
        throw Exception('Insufficient balance. Please reload your wallet.');
      }

      // Process parking payment
      await _dbService.processParkingPayment(
        uid: user.uid,
        vehiclePlate: widget.vehicleNumber,
        duration: widget.duration,
        amount: amount,
      );

      // Show success message
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Payment processed successfully!'),
            backgroundColor: Colors.green,
          ),
        );
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          isProcessing = false;
        });
      }
    }
  }

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
                    _buildInfoCard(widget.vehicleNumber, centered: true),
                    const SizedBox(height: 24),
                    // Parking For Section
                    _buildSectionHeader('Parking For'),
                    const SizedBox(height: 8),
                    _buildInfoCard(widget.duration, centered: true),
                    const SizedBox(height: 24),
                    // Total Section
                    _buildSectionHeader('Total'),
                    const SizedBox(height: 8),
                    _buildInfoCard(widget.price, centered: true, isTotal: true),
                    const SizedBox(height: 40),
                    // Pay Button
                    Center(
                      child: ElevatedButton(
                        onPressed: isProcessing ? null : _processPayment,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFF4A90E2),
                          padding: const EdgeInsets.symmetric(
                            horizontal: 32,
                            vertical: 12,
                          ),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25),
                          ),
                          disabledBackgroundColor: Colors.grey[400],
                        ),
                        child: isProcessing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                'Pay',
                                style: TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.white,
                                ),
                              ),
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Payment info
                    Container(
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: Colors.blue[50],
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.blue[200]!),
                      ),
                      child: Row(
                        children: [
                          Icon(Icons.info_outline, color: Colors.blue[600], size: 20),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              'Payment will be deducted from your wallet balance immediately.',
                              style: TextStyle(
                                fontSize: 12,
                                color: Colors.blue[800],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
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
}