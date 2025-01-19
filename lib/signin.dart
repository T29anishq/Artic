import 'package:flutter/material.dart';
import 'signin1.dart'; // Import the next page
import 'package:cloud_firestore/cloud_firestore.dart';

class SignInPage extends StatelessWidget {
  final TextEditingController usernameController = TextEditingController();
  final TextEditingController emailController = TextEditingController();
  final TextEditingController dobController =
      TextEditingController(); // Date of Birth

  SignInPage({Key? key}) : super(key: key);

  Future<void> _saveUserInfo(BuildContext context) async {
    String username = usernameController.text.trim();
    String email = emailController.text.trim();
    String dob = dobController.text.trim();

    // Validate input fields
    if (username.isEmpty || email.isEmpty || dob.isEmpty) {
      _showErrorDialog(context, 'All fields are required.');
      return;
    }

    // Pass user information to the next page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => ArtFormSelectionPage(
          username: username,
          email: email,
          dateOfBirth: dob,
        ),
      ),
    );
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? pickedDate = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime.now(),
    );
    if (pickedDate != null) {
      dobController.text = "${pickedDate.toLocal()}"
          .split(' ')[0]; // Format the date to YYYY-MM-DD
    }
  }

  void _showErrorDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Error'),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: const Text('OK'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark background color
      appBar: AppBar(
        title: const Text('User Info'),
        backgroundColor: const Color(0xFF162447), // Dark blue
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Container(
            padding: const EdgeInsets.all(20.0),
            decoration: BoxDecoration(
              color: const Color(0xFF0F3460), // Deep blue
              borderRadius: BorderRadius.circular(15),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.5),
                  spreadRadius: 2,
                  blurRadius: 10,
                  offset: const Offset(0, 3),
                ),
              ],
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const SizedBox(height: 20),
                Text(
                  'Create an Account',
                  style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  'Please enter your details',
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.white70,
                  ),
                ),
                const SizedBox(height: 30),
                TextField(
                  controller: usernameController,
                  decoration: InputDecoration(
                    labelText: 'Username',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF162447), // Light blue
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: emailController,
                  decoration: InputDecoration(
                    labelText: 'Email',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF162447), // Light blue
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                  ),
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 20),
                TextField(
                  controller: dobController,
                  decoration: InputDecoration(
                    labelText: 'Date of Birth',
                    labelStyle: TextStyle(color: Colors.white70),
                    filled: true,
                    fillColor: const Color(0xFF162447), // Light blue
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    suffixIcon:
                        Icon(Icons.calendar_today, color: Colors.white70),
                  ),
                  readOnly: true,
                  onTap: () {
                    _selectDate(context); // Show date picker on tap
                  },
                  style: const TextStyle(color: Colors.white),
                ),
                const SizedBox(height: 30),
                ElevatedButton(
                  onPressed: () => _saveUserInfo(context),
                  child: const Text(
                    'Next',
                    style: TextStyle(color: Colors.white70),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xff8a07c1), // Brighter purple
                    padding: const EdgeInsets.symmetric(
                        horizontal: 30, vertical: 15),
                    textStyle: const TextStyle(fontSize: 18),
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
