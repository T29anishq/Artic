import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class SharePage extends StatefulWidget {
  final String artworkId;

  const SharePage({Key? key, required this.artworkId}) : super(key: key);

  @override
  _SharePageState createState() => _SharePageState();
}

class _SharePageState extends State<SharePage> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;

  Future<void> _shareArtwork(String recipientId) async {
    if (_userId == null) return;
    try {
      await FirebaseFirestore.instance
          .collection('users')
          .doc(recipientId)
          .collection('messages')
          .add({
        'senderId': _userId,
        'artworkId': widget.artworkId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Artwork shared!')),
      );
    } catch (e) {
      print('Error sharing artwork: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Share Artwork'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('users')
            .snapshots(), // Adjust user query
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return const Center(child: CircularProgressIndicator());
          }

          var users = snapshot.data!.docs;

          return ListView.builder(
            itemCount: users.length,
            itemBuilder: (context, index) {
              var user = users[index];
              if (user['id'] == _userId) return Container();

              return ListTile(
                title: Text(user['name']),
                subtitle: Text(user['email']),
                trailing: IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: () => _shareArtwork(user['id']),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
