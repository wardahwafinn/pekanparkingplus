import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'firestore_service.dart'; // Fixed import path

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseService _dbService = DatabaseService();

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password (renamed from signInWithEmailAndPassword)
  Future<UserCredential?> login({
    required String email,
    required String password,
  }) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Register with email and password (renamed from registerWithEmailAndPassword)
  Future<UserCredential?> signUp({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'citizen',
  }) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (result.user != null) {
        // Update display name
        await result.user!.updateDisplayName(name);

        // Create user profile in Firestore
        await _dbService.createUserProfile(
          uid: result.user!.uid,
          email: email,
          name: name,
          phone: phone,
          role: role,
        );

        // Send email verification
        await result.user!.sendEmailVerification();
      }

      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Keep the original method names for backward compatibility
  Future<UserCredential?> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    return await login(email: email, password: password);
  }

  Future<UserCredential?> registerWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
    String? phone,
    String role = 'citizen',
  }) async {
    return await signUp(
      email: email,
      password: password,
      name: name,
      phone: phone,
      role: role,
    );
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
    } catch (e) {
      throw Exception('Failed to sign out: $e');
    }
  }

  // Reset password
  Future<void> resetPassword(String email) async {
    try {
      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Get user role
  Future<String?> getUserRole(String uid) async {
    try {
      final userProfile = await _dbService.getUserProfile(uid);
      return userProfile?['role'];
    } catch (e) {
      return null;
    }
  }

  // Update email
  Future<void> updateEmail(String newEmail) async {
    try {
      await _auth.currentUser?.updateEmail(newEmail);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update email: $e');
    }
  }

  // Update password
  Future<void> updatePassword(String newPassword) async {
    try {
      await _auth.currentUser?.updatePassword(newPassword);
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to update password: $e');
    }
  }

  // Reauthenticate user (required for sensitive operations)
  Future<void> reauthenticateUser(String password) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.email != null) {
        final credential = EmailAuthProvider.credential(
          email: user.email!,
          password: password,
        );
        await user.reauthenticateWithCredential(credential);
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to reauthenticate: $e');
    }
  }

  // Send email verification
  Future<void> sendEmailVerification() async {
    try {
      await _auth.currentUser?.sendEmailVerification();
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to send email verification: $e');
    }
  }

  // Check if user email is verified
  bool get isEmailVerified => _auth.currentUser?.emailVerified ?? false;

  // Reload user to get updated info
  Future<void> reloadUser() async {
    try {
      await _auth.currentUser?.reload();
    } catch (e) {
      throw Exception('Failed to reload user: $e');
    }
  }

  // Delete user account
  Future<void> deleteAccount() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        // Delete user data from Firestore
        await FirebaseFirestore.instance
            .collection('users')
            .doc(user.uid)
            .delete();
        
        // Delete user account
        await user.delete();
      }
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('Failed to delete account: $e');
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(FirebaseAuthException e) {
    switch (e.code) {
      case 'user-not-found':
        return 'No user found with this email address.';
      case 'wrong-password':
        return 'Incorrect password. Please try again.';
      case 'email-already-in-use':
        return 'An account already exists with this email address.';
      case 'weak-password':
        return 'Password is too weak. Please choose a stronger password.';
      case 'invalid-email':
        return 'Please enter a valid email address.';
      case 'user-disabled':
        return 'This account has been disabled. Please contact support.';
      case 'too-many-requests':
        return 'Too many failed attempts. Please try again later.';
      case 'network-request-failed':
        return 'Network error. Please check your internet connection.';
      case 'requires-recent-login':
        return 'Please re-authenticate to complete this action.';
      default:
        return 'Authentication failed: ${e.message}';
    }
  }

  // Check authentication status and create profile if needed
  Future<void> checkAndCreateUserProfile() async {
    try {
      final user = _auth.currentUser;
      if (user != null) {
        final userProfile = await _dbService.getUserProfile(user.uid);
        
        if (userProfile == null) {
          // Create user profile if it doesn't exist
          await _dbService.createUserProfile(
            uid: user.uid,
            email: user.email ?? '',
            name: user.displayName ?? 'User',
            role: 'citizen',
          );
        }
      }
    } catch (e) {
      print('Error checking/creating user profile: $e');
    }
  }

  // Sign in anonymously (for demo purposes)
  Future<UserCredential?> signInAnonymously() async {
    try {
      UserCredential result = await _auth.signInAnonymously();
      
      if (result.user != null) {
        // Create anonymous user profile
        await _dbService.createUserProfile(
          uid: result.user!.uid,
          email: 'anonymous@demo.com',
          name: 'Demo User',
          role: 'citizen',
        );
      }
      
      return result;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }

  // Convert anonymous account to permanent account
  Future<UserCredential?> linkWithEmailAndPassword({
    required String email,
    required String password,
    required String name,
  }) async {
    try {
      final user = _auth.currentUser;
      if (user != null && user.isAnonymous) {
        final credential = EmailAuthProvider.credential(
          email: email,
          password: password,
        );
        
        UserCredential result = await user.linkWithCredential(credential);
        
        if (result.user != null) {
          await result.user!.updateDisplayName(name);
          
          // Update user profile
          await _dbService.updateUserProfile(result.user!.uid, {
            'email': email,
            'name': name,
          });
        }
        
        return result;
      }
      return null;
    } on FirebaseAuthException catch (e) {
      throw _handleAuthException(e);
    } catch (e) {
      throw Exception('An unexpected error occurred: $e');
    }
  }
}