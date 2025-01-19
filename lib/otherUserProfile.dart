import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'message_page.dart'; // Import your messages page

class OtherUserProfilePage extends StatefulWidget {
  final String userId;

  const OtherUserProfilePage({Key? key, required this.userId})
      : super(key: key);

  @override
  _OtherUserProfilePageState createState() => _OtherUserProfilePageState();
}

class _OtherUserProfilePageState extends State<OtherUserProfilePage> {
  String username = '';
  String email = '';
  String bio = '';
  String dateOfBirth = '';
  List<String> genres = [];
  List<String> artworks = [];
  List<String> artForms = [];
  String profilePictureUrl = '';
  String status = '';
  bool isFollowing = false;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
    _checkIfFollowing();
  }

  Future<void> _loadUserProfile() async {
    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(widget.userId)
          .get();

      if (userDoc.exists) {
        setState(() {
          username = userDoc['username'] ?? 'No username found';
          email = userDoc['email'] ?? 'No email found';
          bio = userDoc['bio'] ?? 'No bio available';
          dateOfBirth = userDoc['date_of_birth'] ?? 'Date not available';
          genres = List<String>.from(userDoc['genres'] ?? []);
          artworks = List<String>.from(userDoc['posts'] ?? []);
          artForms = List<String>.from(userDoc['artworks'] ?? []);
          profilePictureUrl = userDoc['profilePictureUrl'] ?? '';
          status = userDoc['status'] ?? 'No status available';
        });
      } else {
        print('User document does not exist');
      }
    } catch (e) {
      print('Error loading user profile: $e'); // Log error
    }
  }

  Future<void> _checkIfFollowing() async {
    try {
      String currentUserId = FirebaseAuth.instance.currentUser!.uid;

      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      List<dynamic> followingList = currentUserDoc['following'] ?? [];
      setState(() {
        isFollowing = followingList.contains(widget.userId);
      });
    } catch (e) {
      print('Error checking follow status: $e');
    }
  }

  Future<void> _toggleFollow() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;
    DocumentReference currentUserRef =
        FirebaseFirestore.instance.collection('users').doc(currentUserId);
    DocumentReference otherUserRef =
        FirebaseFirestore.instance.collection('users').doc(widget.userId);

    try {
      if (isFollowing) {
        // Unfollow logic
        await currentUserRef.update({
          'following': FieldValue.arrayRemove([widget.userId])
        });
        await otherUserRef.update({
          'followers': FieldValue.arrayRemove([currentUserId])
        });
        setState(() {
          isFollowing = false;
        });
      } else {
        // Follow logic
        await currentUserRef.update({
          // Add other user to our following list
          'following': FieldValue.arrayUnion([widget.userId])
        });
        await otherUserRef.update({
          // Add us to other user's followers list
          'followers': FieldValue.arrayUnion([currentUserId]),
          // Optionally, send a follow request to the other user
          'followRequests': FieldValue.arrayUnion([currentUserId])
        });

        setState(() {
          isFollowing = true;
        });

        // Create chat after following
        await _createChat();
      }
    } catch (e) {
      print('Error toggling follow status: $e');
    }
  }

  Future<void> _createChat() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      DocumentReference chatRef = FirebaseFirestore.instance
          .collection('chats')
          .doc(); // Create a new chat document with a unique ID

      // Set the chat data
      await chatRef.set({
        'participants': [currentUserId, widget.userId],
        'lastMessage': '',
        'timestamp': FieldValue.serverTimestamp(),
      });

      // Navigate to chat page with chat ID
      Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) =>
                MessagePage(chatId: chatRef.id)), // Pass the unique chat ID
      );
    } catch (e) {
      print('Error creating chat: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark background color
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xFF162447), // Dark blue
      ),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Profile Picture
              Center(
                child: ClipOval(
                  child: Image(
                    image: profilePictureUrl.isNotEmpty
                        ? NetworkImage(profilePictureUrl)
                        : const AssetImage('assets/default_avatar.png')
                            as ImageProvider,
                    width: 120.0,
                    height: 120.0,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(height: 20),

              // User Info Card
              _buildUserInfoCard(),

              const SizedBox(height: 20),

              // Art Forms Section
              _buildInfoCard(
                  'Art Forms:',
                  artForms.isNotEmpty
                      ? artForms.join(', ')
                      : 'No art forms available'),

              // Genres Section
              _buildInfoCard(
                  'Genres:',
                  genres.isNotEmpty
                      ? genres.join(', ')
                      : 'No genres available'),
              const SizedBox(height: 20),

              // Artworks (Posts) Section
              _buildSectionTitle('Artworks:'),
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: artworks.length,
                itemBuilder: (context, index) {
                  return Card(
                    color: const Color(0xFF0F3460), // Deep blue for artworks
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      title: Text(
                        artworks[index],
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  );
                },
              ),

              // Follow/Unfollow Button and Message Button
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  ElevatedButton(
                    onPressed: _toggleFollow,
                    child: Text(isFollowing ? 'Unfollow' : 'Follow'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isFollowing
                          ? Colors.red
                          : Colors
                              .green, // Use backgroundColor instead of primary
                    ),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      // Navigate to chat page if already following
                      if (isFollowing) {
                        _createChat();
                      }
                    },
                    child: const Text('Message'),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildUserInfoCard() {
    return Card(
      color: const Color(0xFF0F3460), // Deep blue
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              username,
              style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  color: Colors.white),
            ),
            const SizedBox(height: 10),
            Text(
              email.isNotEmpty ? email : 'No email found',
              style: TextStyle(color: Colors.grey[300]),
            ),
            const SizedBox(height: 10),
            Text(
              bio.isNotEmpty ? bio : 'No bio available',
              style: const TextStyle(color: Colors.white70),
            ),
            const SizedBox(height: 10),
            Text(
              status.isNotEmpty ? status : 'No status available',
              style: TextStyle(color: Colors.grey[300]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      color: const Color(0xFF0F3460), // Deep blue
      margin: const EdgeInsets.symmetric(vertical: 10),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white)),
            Expanded(
              child: Text(content,
                  textAlign: TextAlign.end,
                  style: const TextStyle(color: Colors.white70)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 10),
      child: Text(
        title,
        style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
      ),
    );
  }
}
