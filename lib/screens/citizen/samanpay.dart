// Updated samanpay.dart with working database integration
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class SamanPayScreen extends StatefulWidget {
  const SamanPayScreen({super.key});

  @override
  State<SamanPayScreen> createState() => _SamanPayScreenState();
}

class _SamanPayScreenState extends State<SamanPayScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  
  double currentBalance = 0.0;
  List<Map<String, dynamic>> fines = [];
  bool isLoadingBalance = true;
  bool isLoadingFines = true;

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await Future.wait([
      _loadUserBalance(),
      _loadUserFines(),
    ]);
  }

  Future<void> _loadUserBalance() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final balance = await _dbService.getUserBalance(user.uid);
        setState(() {
          currentBalance = balance;
          isLoadingBalance = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingBalance = false;
      });
      print('Error loading balance: $e');
    }
  }

  Future<void> _loadUserFines() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userFines = await _dbService.getUserFines(user.uid);
        setState(() {
          fines = userFines;
          isLoadingFines = false;
        });
      }
    } catch (e) {
      setState(() {
        isLoadingFines = false;
      });
      print('Error loading fines: $e');
    }
  }

  Future<void> _refreshData() async {
    setState(() {
      isLoadingBalance = true;
      isLoadingFines = true;
    });
    await _loadData();
  }

  void _showFineDetails(Map<String, dynamic> fine) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (context) => FineDetailsSheet(
        fine: fine,
        currentBalance: currentBalance,
        onPayPressed: () => _processFinePayment(fine),
        onReloadPressed: () => _navigateToReload(),
      ),
    );
  }

  void _processFinePayment(Map<String, dynamic> fine) async {
    Navigator.of(context).pop(); // Close bottom sheet

    final amount = fine['amount']?.toDouble() ?? 0.0;
    
    if (currentBalance < amount) {
      _showInsufficientBalanceDialog(amount);
      return;
    }

    // Show loading
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => const Center(
        child: CircularProgressIndicator(color: Colors.white),
      ),
    );

    try {
      final user = _auth.currentUser;
      if (user != null) {
        await _dbService.payFine(user.uid, fine['id'], amount);
        
        // Update local state
        setState(() {
          currentBalance -= amount;
          fine['status'] = 'paid';
        });

        Navigator.of(context).pop(); // Close loading
        _showPaymentSuccessDialog(fine);
      }
    } catch (e) {
      Navigator.of(context).pop(); // Close loading
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Payment failed: $e'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  void _showInsufficientBalanceDialog(double amount) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        title: const Text('Insufficient Balance'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(
              Icons.warning_amber_rounded,
              size: 60,
              color: Colors.orange,
            ),
            const SizedBox(height: 16),
            Text(
              'Your current balance is RM${currentBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 16),
            ),
            const SizedBox(height: 8),
            Text(
              'You need RM${amount.toStringAsFixed(2)} to pay this fine.',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(height: 8),
            const Text(
              'Please reload your wallet first.',
              style: TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(context).pop();
              _navigateToReload();
            },
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF4A90E2),
            ),
            child: const Text(
              'Reload Now',
              style: TextStyle(color: Colors.white),
            ),
          ),
        ],
      ),
    );
  }

  void _showPaymentSuccessDialog(Map<String, dynamic> fine) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: const BoxDecoration(
                color: Colors.green,
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.check, color: Colors.white, size: 50),
            ),
            const SizedBox(height: 20),
            const Text(
              'Payment Successful!',
              style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 10),
            Text(
              'Fine for ${fine['vehiclePlate']} has been paid',
              style: const TextStyle(fontSize: 16, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Amount: RM${fine['amount'].toStringAsFixed(2)}',
              style: const TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 8),
            Text(
              'Remaining Balance: RM${currentBalance.toStringAsFixed(2)}',
              style: const TextStyle(fontSize: 14, color: Colors.grey),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 30),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () => Navigator.of(context).pop(),
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF4A90E2),
                  padding: const EdgeInsets.symmetric(vertical: 15),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: const Text(
                  'OK',
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                    color: Colors.white,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _navigateToReload() {
    // Navigate to reload screen - this would be handled by parent navigation
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(
        content: Text('Please use the reload option from the home screen'),
        backgroundColor: Colors.blue,
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
          'SamanPay',
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
        child: RefreshIndicator(
          onRefresh: _refreshData,
          child: Column(
            children: [
              // Balance Display
              Padding(
                padding: const EdgeInsets.all(16),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.9),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Column(
                    children: [
                      const Text(
                        'Wallet Balance',
                        style: TextStyle(fontSize: 16, color: Colors.grey),
                      ),
                      const SizedBox(height: 8),
                      isLoadingBalance
                          ? const CircularProgressIndicator()
                          : Text(
                              'RM ${currentBalance.toStringAsFixed(2)}',
                              style: const TextStyle(
                                fontSize: 28,
                                fontWeight: FontWeight.bold,
                                color: Colors.black87,
                              ),
                            ),
                    ],
                  ),
                ),
              ),

              Expanded(
                child: isLoadingFines
                    ? const Center(child: CircularProgressIndicator())
                    : fines.isEmpty
                        ? _buildEmptyState()
                        : _buildFinesList(),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(
            Icons.check_circle_outline,
            size: 64,
            color: Colors.green[400],
          ),
          const SizedBox(height: 16),
          Text(
            'No Fines Found',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.grey[600],
            ),
          ),
          const SizedBox(height: 8),
          Text(
            'You have no outstanding parking fines',
            style: TextStyle(
              fontSize: 14,
              color: Colors.grey[500],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFinesList() {
    final unpaidFines = fines.where((fine) => fine['status'] == 'unpaid').toList();
    final paidFines = fines.where((fine) => fine['status'] == 'paid').toList();

    return ListView(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      children: [
        // New Fine Section
        if (unpaidFines.isNotEmpty) ...[
          const Text(
            'Outstanding Fines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...unpaidFines.map((fine) => _buildFineItem(fine, isNew: true)),
          const SizedBox(height: 24),
        ],

        // Past Fine Section
        if (paidFines.isNotEmpty) ...[
          const Text(
            'Paid Fines',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w600,
              color: Colors.black87,
            ),
          ),
          const SizedBox(height: 12),
          ...paidFines.map((fine) => _buildFineItem(fine, isNew: false)),
          const SizedBox(height: 100),
        ],
      ],
    );
  }

  Widget _buildFineItem(Map<String, dynamic> fine, {required bool isNew}) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: InkWell(
        onTap: isNew ? () => _showFineDetails(fine) : null,
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    '${fine['vehiclePlate']} received a parking fine',
                    style: const TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    '${fine['formattedDate']} | ${fine['formattedTime']}',
                    style: TextStyle(fontSize: 14, color: Colors.grey[600]),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'RM${fine['amount'].toStringAsFixed(2)}',
                    style: const TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      color: Colors.black87,
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(width: 12),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
              decoration: BoxDecoration(
                color: fine['status'] == 'paid'
                    ? Colors.green.withOpacity(0.1)
                    : Colors.red.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                fine['status'] == 'paid' ? 'PAID' : 'NOT PAID',
                style: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: fine['status'] == 'paid' ? Colors.green : Colors.red,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Fine Details Sheet (keeping the existing implementation but updating with real data)
class FineDetailsSheet extends StatelessWidget {
  final Map<String, dynamic> fine;
  final double currentBalance;
  final VoidCallback onPayPressed;
  final VoidCallback onReloadPressed;

  const FineDetailsSheet({
    super.key,
    required this.fine,
    required this.currentBalance,
    required this.onPayPressed,
    required this.onReloadPressed,
  });

  @override
  Widget build(BuildContext context) {
    final amount = fine['amount']?.toDouble() ?? 0.0;
    bool canPay = currentBalance >= amount;

    return Container(
      height: MediaQuery.of(context).size.height * 0.85,
      decoration: const BoxDecoration(
        color: Color(0xFF87CEEB),
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(20),
          topRight: Radius.circular(20),
        ),
      ),
      child: Column(
        children: [
          // Handle bar
          Container(
            margin: const EdgeInsets.only(top: 8),
            width: 40,
            height: 4,
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.5),
              borderRadius: BorderRadius.circular(2),
            ),
          ),

          // Header
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text(
              'Fine Details',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
          ),

          Expanded(
            child: Container(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [Color(0xFF87CEEB), Colors.white],
                  stops: [0.0, 0.3],
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    // Fine Details Card
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: Colors.grey[300]!,
                          style: BorderStyle.solid,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          const Text(
                            'Parking Fine Details',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          const SizedBox(height: 20),
                          _buildDetailRow('Reference:', fine['refNo'] ?? fine['id']),
                          _buildDetailRow('Date:', fine['formattedDate'] ?? 'N/A'),
                          _buildDetailRow('Time:', fine['formattedTime'] ?? 'N/A'),
                          const SizedBox(height: 16),
                          Container(height: 1, color: Colors.grey[300]),
                          const SizedBox(height: 16),
                          _buildDetailRow('Vehicle:', fine['vehiclePlate'] ?? 'N/A'),
                          _buildDetailRow('Location:', fine['location'] ?? 'N/A'),
                          _buildDetailRow('Description:', fine['description'] ?? 'Parking violation'),
                          _buildDetailRow(
                            'Amount:',
                            'RM${amount.toStringAsFixed(2)}',
                          ),
                        ],
                      ),
                    ),

                    const SizedBox(height: 24),

                    // Balance Info
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: canPay
                            ? Colors.green.withOpacity(0.1)
                            : Colors.red.withOpacity(0.1),
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(
                          color: canPay ? Colors.green : Colors.red,
                          width: 1,
                        ),
                      ),
                      child: Column(
                        children: [
                          Text(
                            'Current Balance: RM${currentBalance.toStringAsFixed(2)}',
                            style: const TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            canPay
                                ? 'Sufficient balance to pay this fine'
                                : 'Insufficient balance. Please reload first.',
                            style: TextStyle(
                              fontSize: 14,
                              color: canPay ? Colors.green : Colors.red,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),

                    const Spacer(),

                    // Action Buttons
                    if (canPay)
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: onPayPressed,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: const Color(0xFF4A90E2),
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(25),
                            ),
                          ),
                          child: const Text(
                            'Pay Fine',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.w600,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      )
                    else
                      Column(
                        children: [
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: onReloadPressed,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.orange,
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Reload Wallet',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(height: 12),
                          SizedBox(
                            width: double.infinity,
                            child: OutlinedButton(
                              onPressed: () => Navigator.of(context).pop(),
                              style: OutlinedButton.styleFrom(
                                side: const BorderSide(color: Colors.grey),
                                padding: const EdgeInsets.symmetric(vertical: 16),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(25),
                                ),
                              ),
                              child: const Text(
                                'Cancel',
                                style: TextStyle(
                                  fontSize: 18,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.grey,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),

                    const SizedBox(height: 20),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 100,
            child: Text(
              label,
              style: const TextStyle(fontSize: 14, color: Colors.grey),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              textAlign: TextAlign.right,
            ),
          ),
        ],
      ),
    );
  }
}