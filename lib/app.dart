import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'screens/auth/login_page.dart';
import 'screens/citizen/citizen_nav.dart';
import 'screens/officer/officer_nav.dart';
import 'services/auth_service.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Parking App',
      theme: ThemeData(useMaterial3: true, colorSchemeSeed: Colors.blue),
       home: CitizenNav(),
    );
  }
}

class AuthWrapper extends StatelessWidget {
  const AuthWrapper({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) return const CircularProgressIndicator();
        if (snapshot.hasData) {
          return FutureBuilder<String?>(
            future: AuthService().getUserRole(snapshot.data!.uid),
            builder: (context, roleSnap) {
              if (!roleSnap.hasData) return const CircularProgressIndicator();
              if (roleSnap.data == 'citizen') return const CitizenNav();
              if (roleSnap.data == 'officer') return const OfficerNav();
              return const Center(child: Text("Unknown role"));
            },
          );
        }
        return const LoginPage();
      },
    );
  }
}
