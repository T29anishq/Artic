import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artic01/otherUserProfile.dart'; // Keep if used
import 'userProfile.dart';
import 'storylinesPage.dart';
import 'publishedWorkPage.dart';
import 'home.dart';

class SearchPage extends StatefulWidget {
  @override
  _SearchPageState createState() => _SearchPageState();
}

class _SearchPageState extends State<SearchPage> {
  final TextEditingController _searchController = TextEditingController();
  List<Map<String, dynamic>> _users = [];
  String _selectedGenre = 'All'; // Default selected genre
  String _selectedArtform = 'All'; // Default selected artform

  // For filtering options
  final List<String> genres = [
    'All',
    'Horror',
    'Mystery',
    'Fantasy',
  ]; // Add your genres here
  final List<String> artforms = [
    'All',
    'Drawing',
    'Painting',
    'Sculpture',
  ]; // Add your artforms here

// Bottom Navigation variables
  int _currentIndex = 1;

  @override
  void initState() {
    super.initState();
    _fetchUsers();
  }

  Future<void> _fetchUsers() async {
    try {
      QuerySnapshot querySnapshot =
          await FirebaseFirestore.instance.collection('users').get();
      setState(() {
        _users = querySnapshot.docs.map((doc) {
          Map<String, dynamic> userData = doc.data() as Map<String, dynamic>;
          return {
            'uid': doc.id, // Store UID
            ...userData,
          };
        }).toList();
      });
    } catch (e) {
      print('Error fetching users: $e');
    }
  }

  void _filterUsers() {
    String query = _searchController.text.toLowerCase();
    setState(() {
      _users = _users.where((user) {
        bool matchesUsername =
            (user['username'] as String).toLowerCase().contains(query);
        bool matchesGenre = _selectedGenre == 'All' ||
            (user['genres'] as List).contains(_selectedGenre);
        bool matchesArtform = _selectedArtform == 'All' ||
            (user['artworks'] as List).contains(_selectedArtform);
        return matchesUsername && matchesGenre && matchesArtform;
      }).toList();
    });
  }

  void _onUserTap(Map<String, dynamic> user) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => OtherUserProfilePage(
          userId: user['uid'], // Pass the UID to the profile page
        ),
      ),
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
        Navigator.pushReplacement(context,
            MaterialPageRoute(builder: (context) => UserProfilePage()));
        break;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Search Users', style: TextStyle(color: Colors.white)),
        backgroundColor: Colors.deepPurple, // Match with login.dart
      ),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Colors.purple.shade300,
              Colors.blue.shade300,
            ],
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              TextField(
                controller: _searchController,
                decoration: InputDecoration(
                  filled: true,
                  fillColor: Colors.white, // Match the input field style
                  hintText: 'Search by username',
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(10),
                    borderSide: BorderSide.none,
                  ),
                  suffixIcon: IconButton(
                    icon: const Icon(Icons.search),
                    onPressed: _filterUsers,
                  ),
                ),
              ),
              SizedBox(height: 16),
              DropdownButton<String>(
                value: _selectedGenre,
                isExpanded: true,
                items: genres.map((String genre) {
                  return DropdownMenuItem<String>(
                    value: genre,
                    child: Text(genre),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedGenre = value!;
                  });
                  _filterUsers(); // Re-filter users when genre changes
                },
                hint: const Text('Select Genre'),
              ),
              SizedBox(height: 8),
              DropdownButton<String>(
                value: _selectedArtform,
                isExpanded: true,
                items: artforms.map((String artform) {
                  return DropdownMenuItem<String>(
                    value: artform,
                    child: Text(artform),
                  );
                }).toList(),
                onChanged: (value) {
                  setState(() {
                    _selectedArtform = value!;
                  });
                  _filterUsers(); // Re-filter users when artform changes
                },
                hint: const Text('Select Artform'),
              ),
              SizedBox(height: 16),
              Expanded(
                child: ListView.builder(
                  itemCount: _users.length,
                  itemBuilder: (context, index) {
                    final user = _users[index];
                    return Card(
                      margin: const EdgeInsets.symmetric(vertical: 8.0),
                      elevation: 4, // Add elevation for shadow effect
                      child: InkWell(
                        onTap: () => _onUserTap(
                            user), // Navigate to OtherUserProfilePage
                        child: Padding(
                          padding: const EdgeInsets.all(16.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 30,
                                backgroundImage: NetworkImage(
                                  user['profileImage'] ??
                                      'https://via.placeholder.com/150', // Fallback image
                                ),
                              ),
                              SizedBox(width: 16),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      user['username'],
                                      style: TextStyle(
                                          fontSize: 18,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      user['bio'] ?? 'No bio available',
                                      style: TextStyle(color: Colors.grey[600]),
                                    ),
                                    SizedBox(height: 4),
                                    Text(
                                      (user['genres'] as List?)?.join(', ') ??
                                          'No genres',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                    Text(
                                      (user['artworks'] as List?)?.join(', ') ??
                                          'No art forms',
                                      style: TextStyle(color: Colors.blue),
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ),
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
}
