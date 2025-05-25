import 'package:flutter/material.dart';

class HomePageOfficer extends StatelessWidget {
  const HomePageOfficer({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Officer Home')),
      body: const Center(child: Text('Officer Home Page')),
    );
  }
}
