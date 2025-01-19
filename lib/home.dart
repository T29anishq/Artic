import 'package:artic01/userProfile.dart';
import 'package:artic01/search.dart'; // Adjust the import according to your file structure
import 'package:artic01/message_page.dart'; // Import the MessagePage file
import 'package:artic01/notification.dart'; // Import the Notifications Page
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:artic01/comments.dart';
import 'package:artic01/share.dart';
import 'storylinesPage.dart';
import 'publishedWorkPage.dart';
import 'personal_chat_tab.dart';

class HomePage extends StatefulWidget {
  @override
  _HomePageState createState() => _HomePageState();
}

// Bottom Navigation variables
int _currentIndex = 0; // Default index for Profile

class _HomePageState extends State<HomePage> {
  final String? _userId = FirebaseAuth.instance.currentUser?.uid;
  bool hasUnseenRequests = false;
  List<Map<String, dynamic>> artworks = [];

  int _currentIndex = 0;

  @override
  void initState() {
    super.initState();
    _checkUnseenRequests();
    _loadArtworks();
  }

  Future<void> _checkUnseenRequests() async {
    if (_userId != null) {
      try {
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .get();
        List<dynamic> requests = userDoc['requests'] ?? [];
        hasUnseenRequests = requests.any((request) => !request['seen']);
        setState(() {});
      } catch (e) {
        print('Error checking unseen requests: $e');
      }
    }
  }

  Future<void> _loadArtworks() async {
    try {
      QuerySnapshot snapshot =
          await FirebaseFirestore.instance.collection('artworks').get();

      List<Map<String, dynamic>> fetchedArtworks = snapshot.docs.map((doc) {
        return {
          'id': doc.id, // Document ID
          'caption': doc['caption'],
          'fileUrls': doc['fileUrls'],
          'likes': doc['likes'],
          'timestamp': doc['timestamp'],
          'userId': doc['userId'],
        };
      }).toList();

      setState(() {
        artworks = fetchedArtworks;
      });
    } catch (e) {
      print('Error fetching artworks: $e');
    }
  }

  Future<void> _likeArtwork(String artworkId, bool isLike) async {
    if (_userId != null) {
      try {
        DocumentReference artworkRef =
            FirebaseFirestore.instance.collection('artworks').doc(artworkId);
        DocumentSnapshot artworkSnapshot = await artworkRef.get();

        if (artworkSnapshot.exists) {
          List<dynamic> likes = (artworkSnapshot['likes'] ?? []).toList();
          List<dynamic> dislikes = (artworkSnapshot['dislikes'] ?? []).toList();

          // Check if the user already liked or disliked
          bool userLiked = likes.contains(_userId);
          bool userDisliked = dislikes.contains(_userId);

          // Update likes/dislikes based on the user's action
          if (isLike) {
            if (userLiked) {
              likes.remove(_userId); // Remove like
            } else {
              likes.add(_userId); // Add like
              if (userDisliked)
                dislikes.remove(_userId); // Remove dislike if it exists
            }
          } else {
            if (userDisliked) {
              dislikes.remove(_userId); // Remove dislike
            } else {
              dislikes.add(_userId); // Add dislike
              if (userLiked) likes.remove(_userId); // Remove like if it exists
            }
          }

          // Update the database
          await artworkRef.update({
            'likes': likes,
            'dislikes': dislikes,
          });

          // Update the local state
          setState(() {
            final artwork =
                artworks.firstWhere((art) => art['id'] == artworkId);
            artwork['likes'] = likes.length; // Update count in UI
            artwork['dislikes'] = dislikes.length;
          });
        }
      } catch (e) {
        print('Error updating like/dislike: $e');
      }
    }
  }

  Future<void> _saveArtwork(String artworkId) async {
    if (_userId != null) {
      try {
        await FirebaseFirestore.instance
            .collection('users')
            .doc(_userId)
            .update({
          'savedArtworks': FieldValue.arrayUnion([artworkId]),
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Artwork saved!')),
        );
      } catch (e) {
        print('Error saving artwork: $e');
      }
    }
  }

  void _commentOnArtwork(String artworkId) {
    // Navigate to a separate comments page (to be implemented)
    print('Navigate to comments page for artwork $artworkId');
  }

  void _shareArtwork(String fileUrl) {
    // Implement sharing functionality
    print('Sharing artwork with URL $fileUrl');
  }

  Widget _buildArtworksSection() {
    return artworks.isNotEmpty
        ? ListView.builder(
            itemCount: artworks.length,
            itemBuilder: (context, index) {
              var artwork = artworks[index];
              return Card(
                color: const Color(0xFF0F3460),
                margin:
                    const EdgeInsets.symmetric(vertical: 10, horizontal: 10),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Artwork image

                    Image.network(
                      artwork['fileUrls'][0],
                      fit: BoxFit.cover,
                      width: double.infinity,
                      height: 300,
                    ),

                    Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Text(
                        artwork['caption'] ?? 'No Caption',
                        style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                        ),
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 10.0),
                      child: Text(
                        '${artwork['likes'] ?? 0} Likes  ${artwork['dislikes'] ?? 0} Dislikes',
                        style: const TextStyle(color: Colors.white70),
                      ),
                    ),
                    // Action buttons
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceAround,
                      children: [
                        IconButton(
                          icon: Icon(Icons.thumb_up, color: Colors.white),
                          onPressed: () => _likeArtwork(artwork['id'], true),
                        ),
                        IconButton(
                          icon: Icon(Icons.thumb_down, color: Colors.white),
                          onPressed: () => _likeArtwork(artwork['id'], false),
                        ),
                        IconButton(
                          icon: const Icon(Icons.comment, color: Colors.white),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  CommentsPage(artworkId: artwork['id']),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.share, color: Colors.white),
                          onPressed: () => Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) =>
                                  SharePage(artworkId: artwork['id']),
                            ),
                          ),
                        ),
                        IconButton(
                          icon: const Icon(Icons.bookmark, color: Colors.white),
                          onPressed: () => _saveArtwork(artwork['id']),
                        ),
                      ],
                    ),
                  ],
                ),
              );
            },
          )
        : const Center(
            child: Text(
              "No artworks available yet.",
              style: TextStyle(color: Colors.white, fontSize: 18),
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
      backgroundColor: const Color(0xFF1A1A2E),
      appBar: AppBar(
        title: const Text(
          'Artic',
          style: TextStyle(
            fontFamily: 'RobotoMono',
            fontSize: 22,
            fontWeight: FontWeight.bold,
            color: Color(0xff8729ae),
          ),
        ),
        backgroundColor: const Color(0xffffffff),
        actions: [
          IconButton(
            icon: Icon(
              Icons.notifications,
              color: hasUnseenRequests ? Colors.red : const Color(0xFF162447),
            ),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => NotificationsPage()),
              );
            },
          ),
          IconButton(
            icon: const Icon(
              Icons.message,
              color: Color(0xFF162447),
            ),
            onPressed: () {
              if (_userId != null) {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => PersonalChatTab(userId: _userId),
                  ),
                );
              } else {
                // Optional: Handle cases where userId is null

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('User not logged in.')),
                );
              }
            },
          ),
        ],
      ),
      body: _buildArtworksSection(),
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
