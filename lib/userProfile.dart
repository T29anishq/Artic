import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'editProfile.dart'; // Import your EditProfilePage
import 'userListPage.dart'; // Import the UserListPage
import 'addPost.dart'; // Import your AddPostPage
import 'login.dart'; // Import your LoginPage
import 'home.dart'; // Import your HomePage
import 'search.dart'; // Import your SearchPage
import 'storylinesPage.dart'; // Import your StorylinesPage
import 'publishedWorkPage.dart'; // Import your PublishedWorkPage

class UserProfilePage extends StatefulWidget {
  const UserProfilePage({Key? key}) : super(key: key);

  @override
  _UserProfilePageState createState() => _UserProfilePageState();
}

class _UserProfilePageState extends State<UserProfilePage> {
  String userId = '';
  String username = '';
  String email = '';
  String bio = '';
  String dateOfBirth = '';
  List<String> genres = [];
  List<String> artworks = [];
  List<String> artForms = [];
  String profilePictureUrl = '';
  String status = '';
  List<String> followers = []; // List of follower user IDs
  List<String> following = []; // List of following user IDs

  // Bottom Navigation variables
  int _currentIndex = 4; // Default index for Profile

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    try {
      User? user = FirebaseAuth.instance.currentUser;
      if (user != null) {
        userId = user.uid;
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
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
            followers = List<String>.from(userDoc['followers'] ?? []);
            following = List<String>.from(userDoc['following'] ?? []);
          });
        }
      }
    } catch (e) {
      // Handle error
    }
  }

  Future<void> _logout() async {
    await FirebaseAuth.instance.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginPage()),
    );
  }

  Future<void> _showLogoutConfirmationDialog() async {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('Confirm Logout'),
          content: const Text('Are you sure you want to logout?'),
          actions: [
            TextButton(
              child: const Text('No'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text('Yes'),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
                _logout(); // Perform logout
              },
            ),
          ],
        );
      },
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
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  username,
                  style: const TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.white),
                ),
                IconButton(
                  icon: const Icon(Icons.logout, color: Colors.red),
                  onPressed: _showLogoutConfirmationDialog,
                ),
              ],
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

  Widget _buildFollowersFollowingCard(String title, List<String> userIds) {
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => UserListPage(
              userIds: userIds,
              title: title,
            ),
          ),
        );
      },
      child: Card(
        color: const Color(0xFF0F3460), // Deep blue
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              Text(
                title,
                style: const TextStyle(
                    fontWeight: FontWeight.bold, color: Colors.white),
              ),
              const SizedBox(height: 5),
              Text(
                '${userIds.length}',
                style: const TextStyle(color: Colors.white, fontSize: 20),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildFollowersFollowingSection() {
    return Row(
      children: [
        Expanded(
          child: _buildFollowersFollowingCard('Following', following),
        ),
        const SizedBox(width: 10),
        Expanded(
          child: _buildFollowersFollowingCard('Followers', followers),
        ),
      ],
    );
  }

  Widget _buildArtworksSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildSectionTitle('Artworks'),
        artworks.isNotEmpty
            ? GridView.builder(
                physics: NeverScrollableScrollPhysics(), // Prevent scrolling
                shrinkWrap: true, // Make the grid view fit inside the column
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 2, // Two artworks per row
                  childAspectRatio: 0.8, // Adjust aspect ratio as needed
                  crossAxisSpacing: 10,
                  mainAxisSpacing: 10,
                ),
                itemCount: artworks.length,
                itemBuilder: (context, index) {
                  // Replace with actual field for image URLs
                  return Card(
                    color: const Color(0xFF0F3460),
                    child: Column(
                      children: [
                        Expanded(
                          child: Image.network(
                            artworks[index], // Use actual image URL
                            fit: BoxFit.cover,
                          ),
                        ),
                        const SizedBox(height: 5),
                        Text(
                          'Artwork ${index + 1}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ],
                    ),
                  );
                },
              )
            : Text(
                'No artworks available',
                style: const TextStyle(color: Colors.white70),
              ),
      ],
    );
  }

  void _onItemTapped(int index) {
    setState(() {
      _currentIndex = index;
    });

    // Handle navigation based on the selected index
    switch (index) {
      case 0:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => HomePage()));
        break;
      case 1:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => SearchPage()));
        break;
      case 2:
        Navigator.pushReplacement(
            context, MaterialPageRoute(builder: (context) => StorylinesPage()));
        break;
      case 3:
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => PublishedWorkPage()));
        break;
      case 4:
        // Stay on the current page
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark background color
      appBar: AppBar(
        title: const Text('User Profile'),
        backgroundColor: const Color(0xffffffff), // White AppBar
        actions: [
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => EditProfilePage()),
              );
            },
            color: Color(0xFF162447),
          ),
          IconButton(
            icon: const Icon(Icons.add_box_outlined),
            onPressed: () {
              // Navigate to AddPostPage when the AddPost button is pressed
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const AddPostPage()),
              );
            },
            color: Color(0xFF162447), // Icon color (Dark blue)
          ),
        ],
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

              // Followers and Following Section
              _buildFollowersFollowingSection(),

              const SizedBox(height: 20),

              // Art Forms Section
              _buildInfoCard(
                  'Art Forms:',
                  artForms.isNotEmpty
                      ? artForms.join(', ')
                      : 'No art forms available'),

              const SizedBox(height: 20),

              // Genres Section
              _buildInfoCard(
                  'Genres:',
                  genres.isNotEmpty
                      ? genres.join(', ')
                      : 'No genres available'),

              const SizedBox(height: 20),

              // Artworks Section
              _buildArtworksSection(), // Call the new artworks section
            ],
          ),
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF162447), // Dark blue background
        selectedItemColor:
            const Color(0xff8a07c1), // Purple accent for selected item
        unselectedItemColor: const Color(
            0xFF162447), // Semi-transparent white for unselected items
        currentIndex: _currentIndex, // Set the current active tab
        onTap: _onItemTapped, // Handle tab navigation
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.search),
            label: 'Search',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Storylines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Published Work',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
      ),
    );
  }

  Widget _buildInfoCard(String title, String content) {
    return Card(
      color: const Color(0xFF0F3460), // Deep blue
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
                  style: const TextStyle(color: Colors.white)),
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
        style: const TextStyle(
            fontSize: 20, fontWeight: FontWeight.bold, color: Colors.white),
      ),
    );
  }
}
