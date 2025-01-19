import 'package:artic01/userProfile.dart';
import 'package:firebase_auth/firebase_auth.dart'; // Import Firebase Auth
import 'package:flutter/material.dart';
import 'personal_chat_tab.dart'; // Import your PersonalChatTab file
import 'rooms_tab.dart'; // Assuming these files exist
import 'groups_tab.dart'; // Assuming these files exist

class MessagePage extends StatefulWidget {
  final String chatId; // Add chatId parameter

  const MessagePage({Key? key, required this.chatId})
      : super(key: key); // Constructor

  @override
  _MessagePageState createState() => _MessagePageState();
}

class _MessagePageState extends State<MessagePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this); // Three tabs
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    // Retrieve the current user
    final User? user = FirebaseAuth.instance.currentUser;
    final String currentUserId = user?.uid ?? ''; // Get the user's UID

    return Scaffold(
      appBar: AppBar(
        title:
            const Text('Messages', style: TextStyle(color: Color(0xFF162447))),
        backgroundColor: const Color(0xffffffff), // Dark blue

        bottom: TabBar(
          controller: _tabController,
          tabs: const [
            Tab(
              text: 'Personal',
            ),
            Tab(text: 'Rooms'),
            Tab(text: 'Groups'),
          ],
        ),
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          PersonalChatTab(
              userId: currentUserId), // Pass currentUserId to the tab
          RoomsTab(), // Assuming RoomsTab exists
          GroupsTab(), // Assuming GroupsTab exists
        ],
      ),
    );
  }
}
