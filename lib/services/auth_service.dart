import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<User?> signUp(String email, String password, String role) async {
    try {
      UserCredential result = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      User user = result.user!;
      // Store role in Firestore
      await _firestore.collection('users').doc(user.uid).set({
        'role': role,
      });
      return user;
    } catch (e) {
      print('Signup Error: $e');
      return null;
    }
  }

  Future<User?> login(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print('Login Error: $e');
      return null;
    }
  }

  Future<String?> getUserRole(String uid) async {
    try {
      DocumentSnapshot doc = await _firestore.collection('users').doc(uid).get();
      return (doc.data() as Map<String, dynamic>)['role'];
    } catch (e) {
      print('Get role error: $e');
      return null;
    }
  }

  Future<void> signOut() async => await _auth.signOut();

  Stream<User?> get authStateChanges => _auth.authStateChanges();
}
