// Enhanced firestore_service.dart with working database for all functionalities
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class DatabaseService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // ============================================================================
  // USER MANAGEMENT
  // ============================================================================
  Future<void> createUserProfile({
    required String uid,
    required String email,
    String? name,
    String? phone,
    String role = 'citizen',
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'email': email,
        'name': name ?? 'User',
        'phone': phone ?? '',
        'role': role,
        'emailNotifications': true,
        'balance': 12.00, // Default balance
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to create user profile: $e');
    }
  }

  Future<Map<String, dynamic>?> getUserProfile(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.exists ? doc.data() : null;
    } catch (e) {
      throw Exception('Failed to get user profile: $e');
    }
  }

  Future<void> updateUserProfile(String uid, Map<String, dynamic> data) async {
    try {
      data['updatedAt'] = FieldValue.serverTimestamp();
      await _firestore.collection('users').doc(uid).update(data);
    } catch (e) {
      throw Exception('Failed to update user profile: $e');
    }
  }

  // ============================================================================
  // BALANCE MANAGEMENT
  // ============================================================================
  Future<double> getUserBalance(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      return doc.data()?['balance']?.toDouble() ?? 0.0;
    } catch (e) {
      throw Exception('Failed to get user balance: $e');
    }
  }

  Future<void> topUpBalance(String uid, double amount) async {
    try {
      final batch = _firestore.batch();

      // Update user balance
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'balance': FieldValue.increment(amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add transaction to history
      final historyRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc();
      
      batch.set(historyRef, {
        'type': 'reload',
        'title': 'Reload PekanParking Plus Wallet',
        'amount': amount,
        'status': 'completed',
        'description': 'Wallet top-up via ${amount > 50 ? 'FPX' : 'Credit Card'}',
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to top up balance: $e');
    }
  }

  Future<void> deductBalance(String uid, double amount, String description, String type) async {
    try {
      final batch = _firestore.batch();

      // Update user balance
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'balance': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add transaction to history
      final historyRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc();
      
      batch.set(historyRef, {
        'type': type,
        'title': description,
        'amount': -amount,
        'status': 'completed',
        'description': description,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to deduct balance: $e');
    }
  }

  // ============================================================================
  // TRANSACTION HISTORY
  // ============================================================================
  Future<List<Map<String, dynamic>>> getTransactionHistory(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .orderBy('createdAt', descending: true)
          .limit(50)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Format timestamp for display
        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          data['formattedDate'] = '${date.day} ${_getMonthName(date.month)} ${date.year.toString().substring(2)} | ${_formatTime(date)}';
        }
        
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get transaction history: $e');
    }
  }

  // ============================================================================
  // VEHICLE MANAGEMENT
  // ============================================================================
  Future<void> addVehicle({
    required String uid,
    required String plate,
    required String owner,
  }) async {
    try {
      // Check if this is the first vehicle (auto-select it)
      final existingVehicles = await getUserVehicles(uid);
      final isFirstVehicle = existingVehicles.isEmpty;

      await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .add({
        'plate': plate.toUpperCase(),
        'owner': owner.toUpperCase(),
        'isSelected': isFirstVehicle,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add vehicle: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserVehicles(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .orderBy('createdAt', descending: false)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get vehicles: $e');
    }
  }

  Future<Map<String, dynamic>?> getSelectedVehicle(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('vehicles')
          .where('isSelected', isEqualTo: true)
          .limit(1)
          .get();

      if (querySnapshot.docs.isNotEmpty) {
        final data = querySnapshot.docs.first.data();
        data['id'] = querySnapshot.docs.first.id;
        return data;
      }
      return null;
    } catch (e) {
      throw Exception('Failed to get selected vehicle: $e');
    }
  }

  // ============================================================================
  // PARKING TRANSACTIONS
  // ============================================================================
  Future<void> processParkingPayment({
    required String uid,
    required String vehiclePlate,
    required String duration,
    required double amount,
  }) async {
    try {
      // Check if user has sufficient balance
      final currentBalance = await getUserBalance(uid);
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      // Deduct balance and add transaction
      await deductBalance(
        uid, 
        amount, 
        '$duration parking for $vehiclePlate',
        'parking'
      );
    } catch (e) {
      throw Exception('Failed to process parking payment: $e');
    }
  }

  // ============================================================================
  // FINE MANAGEMENT (SAMANPAY)
  // ============================================================================
  Future<void> createSampleFines(String uid) async {
    try {
      final vehicles = await getUserVehicles(uid);
      if (vehicles.isEmpty) return;

      final batch = _firestore.batch();
      
      // Sample fines data
      final sampleFines = [
        {
          'vehiclePlate': vehicles[0]['plate'],
          'amount': 10.00,
          'description': 'Fine for not purchasing parking ticket',
          'location': 'Jalan Seri Dagangan 1',
          'status': 'unpaid',
          'refNo': 'PG1234567',
          'reference1': 'LP12345',
          'createdAt': Timestamp.fromDate(DateTime.now().subtract(const Duration(days: 1))),
        },
      ];

      for (var fine in sampleFines) {
        final fineRef = _firestore
            .collection('users')
            .doc(uid)
            .collection('fines')
            .doc();
        batch.set(fineRef, fine);
      }

      await batch.commit();
    } catch (e) {
      print('Error creating sample fines: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserFines(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('fines')
          .orderBy('createdAt', descending: true)
          .get();

      List<Map<String, dynamic>> fines = querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Format timestamp for display
        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          data['formattedDate'] = '${date.day} ${_getMonthName(date.month)} ${date.year.toString().substring(2)}';
          data['formattedTime'] = _formatTime(date);
        }
        
        return data;
      }).toList();

      // If no fines exist, create sample data
      if (fines.isEmpty) {
        await createSampleFines(uid);
        return getUserFines(uid); // Recursive call to get the newly created fines
      }

      return fines;
    } catch (e) {
      throw Exception('Failed to get fines: $e');
    }
  }

  Future<void> payFine(String uid, String fineId, double amount) async {
    try {
      // Check if user has sufficient balance
      final currentBalance = await getUserBalance(uid);
      if (currentBalance < amount) {
        throw Exception('Insufficient balance');
      }

      final batch = _firestore.batch();

      // Update fine status
      final fineRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('fines')
          .doc(fineId);
      
      batch.update(fineRef, {
        'status': 'paid',
        'paidAt': FieldValue.serverTimestamp(),
      });

      // Update user balance
      final userRef = _firestore.collection('users').doc(uid);
      batch.update(userRef, {
        'balance': FieldValue.increment(-amount),
        'updatedAt': FieldValue.serverTimestamp(),
      });

      // Add transaction to history
      final fineDoc = await fineRef.get();
      final fineData = fineDoc.data();
      
      final historyRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc();
      
      batch.set(historyRef, {
        'type': 'fine_payment',
        'title': 'Parking fine pay for ${fineData?['vehiclePlate']}',
        'amount': -amount,
        'status': 'completed',
        'description': 'Fine payment for ${fineData?['description']}',
        'fineId': fineId,
        'createdAt': FieldValue.serverTimestamp(),
      });

      await batch.commit();
    } catch (e) {
      throw Exception('Failed to pay fine: $e');
    }
  }

  // ============================================================================
  // REPORTS MANAGEMENT
  // ============================================================================
  Future<void> submitReport({
    required String uid,
    required String location,
    required String description,
    String? vehiclePlate,
    List<String>? imageUrls,
  }) async {
    try {
      await _firestore.collection('reports').add({
        'reporterId': uid,
        'location': location,
        'description': description,
        'vehiclePlate': vehiclePlate,
        'imageUrls': imageUrls ?? [],
        'status': 'pending',
        'createdAt': FieldValue.serverTimestamp(),
        'reportNumber': 'RPT${DateTime.now().millisecondsSinceEpoch}',
      });
    } catch (e) {
      throw Exception('Failed to submit report: $e');
    }
  }

  // ============================================================================
  // NOTIFICATIONS
  // ============================================================================
  Future<void> addNotification({
    required String uid,
    required String title,
    required String message,
    String type = 'general',
  }) async {
    try {
      await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .add({
        'title': title,
        'message': message,
        'type': type,
        'isRead': false,
        'createdAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to add notification: $e');
    }
  }

  Future<List<Map<String, dynamic>>> getUserNotifications(String uid) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .doc(uid)
          .collection('notifications')
          .orderBy('createdAt', descending: true)
          .limit(20)
          .get();

      return querySnapshot.docs.map((doc) {
        final data = doc.data();
        data['id'] = doc.id;
        
        // Format timestamp for display
        if (data['createdAt'] != null) {
          final timestamp = data['createdAt'] as Timestamp;
          final date = timestamp.toDate();
          data['formattedDate'] = _formatTime(date);
        }
        
        return data;
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }

  // ============================================================================
  // UTILITY METHODS
  // ============================================================================
  String _getMonthName(int month) {
    const months = [
      '', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
      'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'
    ];
    return months[month];
  }

  String _formatTime(DateTime date) {
    final hour = date.hour > 12 ? date.hour - 12 : date.hour == 0 ? 12 : date.hour;
    final minute = date.minute.toString().padLeft(2, '0');
    final period = date.hour >= 12 ? 'PM' : 'AM';
    return '$hour:$minute $period';
  }

  // ============================================================================
  // INITIALIZATION HELPER
  // ============================================================================
  Future<void> initializeUserData(String uid) async {
    try {
      // Create sample notifications
      await addNotification(
        uid: uid,
        title: 'Welcome to PekanParking Plus!',
        message: 'Thank you for joining us. Enjoy convenient parking payments.',
        type: 'welcome',
      );

      // Create sample transaction history
      final historyRef = _firestore
          .collection('users')
          .doc(uid)
          .collection('transactions')
          .doc();
      
      await historyRef.set({
        'type': 'welcome_bonus',
        'title': 'Welcome bonus',
        'amount': 12.00,
        'status': 'completed',
        'description': 'Welcome bonus for new users',
        'createdAt': FieldValue.serverTimestamp(),
      });

    } catch (e) {
      print('Error initializing user data: $e');
    }
  }
}