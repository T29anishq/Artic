import 'package:flutter/material.dart';
import 'userProfile.dart'; // Import UserProfilePage
import 'publishedWorkPage.dart';

class StorylinesPage extends StatelessWidget {
  const StorylinesPage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    int _currentIndex = 1; // Set current index for the BottomNavigationBar

    void _onItemTapped(int index) {
      switch (index) {
        case 0:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const UserProfilePage()),
          );
          break;
        case 2:
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const PublishedWorkPage()),
          );
          break;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Storylines'),
        backgroundColor: const Color(0xFF162447), // Dark blue background
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: () {
                // Handle adding a new storyline here
                // For example, navigate to a form to add a new storyline
              },
              child: const Text('Add New Storyline'),
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xff8a07c1), // Purple accent
              ),
            ),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: 10, // Replace with the actual number of storylines
                itemBuilder: (context, index) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: Padding(
                      padding: const EdgeInsets.all(16.0),
                      child: Text(
                          'Storyline ${index + 1}'), // Replace with actual storyline data
                    ),
                  );
                },
              ),
            ),
          ],
        ),
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: const Color(0xFF162447), // Dark blue background
        selectedItemColor:
            const Color(0xff8a07c1), // Purple accent for selected item
        unselectedItemColor:
            Colors.white, // Semi-transparent white for unselected items
        currentIndex: _currentIndex, // Set the current active tab
        onTap: _onItemTapped, // Handle tab navigation
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Profile',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.book),
            label: 'Storylines',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.library_books),
            label: 'Published Work',
          ),
        ],
      ),
    );
  }
}
