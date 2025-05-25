import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../services/auth_service.dart';
import '../citizen/citizen_nav.dart';
import '../officer/officer_nav.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController emailCtrl = TextEditingController();
  final TextEditingController passwordCtrl = TextEditingController();
  String selectedRole = 'citizen'; // default role
  final AuthService _authService = AuthService();
  bool isLogin = true;

  void handleAuth() async {
    String email = emailCtrl.text.trim();
    String pass = passwordCtrl.text.trim();
    User? user;

    if (isLogin) {
      user = await _authService.login(email, pass);
    } else {
      user = await _authService.signUp(email, pass, selectedRole);
    }

    if (user != null) {
      String? role = await _authService.getUserRole(user.uid);
      if (role == 'citizen') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const CitizenNav()));
      } else if (role == 'officer') {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (_) => const OfficerNav()));
      } else {
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Role not found')));
      }
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Authentication failed')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(isLogin ? 'Login' : 'Register')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(controller: emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            TextField(controller: passwordCtrl, obscureText: true, decoration: const InputDecoration(labelText: 'Password')),
            if (!isLogin)
              DropdownButton<String>(
                value: selectedRole,
                items: const [
                  DropdownMenuItem(value: 'citizen', child: Text('Citizen')),
                  DropdownMenuItem(value: 'officer', child: Text('Officer')),
                ],
                onChanged: (val) => setState(() => selectedRole = val!),
              ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: handleAuth,
              child: Text(isLogin ? 'Login' : 'Register'),
            ),
            TextButton(
              onPressed: () => setState(() => isLogin = !isLogin),
              child: Text(isLogin ? 'Don\'t have an account? Register' : 'Already have an account? Login'),
            ),
          ],
        ),
      ),
    );
  }
}
