import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SeeUserPage extends StatelessWidget {
  final String userId;

  const SeeUserPage({Key? key, required this.userId}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(userId), // Displaying the username as the title
      ),
      body: FutureBuilder<DocumentSnapshot>(
        future:
            FirebaseFirestore.instance.collection('users').doc(userId).get(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (!snapshot.hasData || !snapshot.data!.exists) {
            return Center(child: Text('User not found.'));
          }

          // Extracting user data from the snapshot
          final userData = snapshot.data!.data() as Map<String, dynamic>;
          final artworks = userData['artworks'] as List<dynamic>? ?? [];
          final genres = userData['genres'] as List<dynamic>? ?? [];

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  userData['username'] ?? 'No Username',
                  style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                ),
                SizedBox(height: 8),
                Text(
                  'Bio: ${userData['bio'] ?? 'No bio available'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Date of Birth: ${userData['date_of_birth'] ?? 'Not provided'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Email: ${userData['email'] ?? 'Not provided'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 8),
                Text(
                  'Status: ${userData['status'] ?? 'No status available'}',
                  style: TextStyle(fontSize: 16),
                ),
                SizedBox(height: 16),
                Text(
                  'Genres:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                for (var genre in genres) Text('- $genre'),
                SizedBox(height: 16),
                Text(
                  'Artworks:',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
                for (var artwork in artworks) Text('- $artwork'),
              ],
            ),
          );
        },
      ),
    );
  }
}
