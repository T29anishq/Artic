import 'package:flutter/material.dart';

class GroupsTab extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark background
      body: Center(
        child: Text(
          "Groups",
          style: TextStyle(color: Colors.white),
        ),
      ),
    );
  }
}
