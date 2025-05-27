// Updated history.dart with working database integration
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/firestore_service.dart';

class ParkingHistoryScreen extends StatefulWidget {
  const ParkingHistoryScreen({Key? key}) : super(key: key);

  @override
  State<ParkingHistoryScreen> createState() => _ParkingHistoryScreenState();
}

class _ParkingHistoryScreenState extends State<ParkingHistoryScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();
  
  List<Map<String, dynamic>> transactions = [];
  bool isLoading = true;
  String? errorMessage;

  @override
  void initState() {
    super.initState();
    _loadTransactionHistory();
  }

  Future<void> _loadTransactionHistory() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final history = await _dbService.getTransactionHistory(user.uid);
        setState(() {
          transactions = history;
          isLoading = false;
          errorMessage = null;
        });
      }
    } catch (e) {
      setState(() {
        isLoading = false;
        errorMessage = 'Unable to load transaction history';
      });
      print('Error loading transaction history: $e');
    }
  }

  Future<void> _refreshHistory() async {
    setState(() {
      isLoading = true;
      errorMessage = null;
    });
    await _loadTransactionHistory();
  }

  Color _getAmountColor(double amount) {
    return amount >= 0 ? Colors.green : Colors.red;
  }

  String _getAmountText(double amount) {
    final prefix = amount >= 0 ? '+' : '';
    return '${prefix}RM${amount.abs().toStringAsFixed(2)}';
  }

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
        child: RefreshIndicator(
          onRefresh: _refreshHistory,
          child: _buildContent(),
        ),
      ),
    );
  }

  Widget _buildContent() {
    if (isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
        ),
      );
    }

    if (errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.error_outline,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              errorMessage!,
              style: TextStyle(
                fontSize: 16,
                color: Colors.grey[600],
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _refreshHistory,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF4A90E2),
              ),
              child: const Text(
                'Try Again',
                style: TextStyle(color: Colors.white),
              ),
            ),
          ],
        ),
      );
    }

    if (transactions.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.history,
              size: 64,
              color: Colors.grey[400],
            ),
            const SizedBox(height: 16),
            Text(
              'No Transaction History',
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w600,
                color: Colors.grey[600],
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Your parking and payment history will appear here',
              style: TextStyle(
                fontSize: 14,
                color: Colors.grey[500],
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: transactions.length,
      itemBuilder: (context, index) {
        final transaction = transactions[index];
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: _buildHistoryItem(
            title: transaction['title'] ?? 'Transaction',
            date: transaction['formattedDate'] ?? 'Unknown date',
            amount: _getAmountText(transaction['amount']?.toDouble() ?? 0.0),
            isNegative: (transaction['amount']?.toDouble() ?? 0.0) < 0,
            type: transaction['type'] ?? 'general',
          ),
        );
      },
    );
  }

  Widget _buildHistoryItem({
    required String title,
    required String date,
    required String amount,
    required bool isNegative,
    required String type,
  }) {
    // Get icon based on transaction type
    IconData getIcon() {
      switch (type) {
        case 'parking':
          return Icons.local_parking;
        case 'fine_payment':
          return Icons.account_balance;
        case 'reload':
          return Icons.add_circle;
        case 'welcome_bonus':
          return Icons.card_giftcard;
        default:
          return Icons.receipt;
      }
    }

    // Get icon color based on transaction type
    Color getIconColor() {
      switch (type) {
        case 'parking':
          return Colors.blue;
        case 'fine_payment':
          return Colors.orange;
        case 'reload':
          return Colors.green;
        case 'welcome_bonus':
          return Colors.purple;
        default:
          return Colors.grey;
      }
    }

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Row(
        children: [
          // Transaction type icon
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: getIconColor().withOpacity(0.1),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(
              getIcon(),
              color: getIconColor(),
              size: 20,
            ),
          ),
          const SizedBox(width: 12),
          // Transaction details
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
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey[600],
                  ),
                ),
              ],
            ),
          ),
          // Amount
          Text(
            amount,
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.w600,
              color: _getAmountColor(isNegative ? -1.0 : 1.0),
            ),
          ),
        ],
      ),
    );
  }
}