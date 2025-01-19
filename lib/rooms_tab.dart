import 'package:flutter/material.dart';

class RoomsTab extends StatefulWidget {
  @override
  _RoomsTabState createState() => _RoomsTabState();
}

class _RoomsTabState extends State<RoomsTab> {
  List<String> rooms = []; // List to hold created room names

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF1A1A2E), // Dark background
      appBar: AppBar(
        title: const Text("Rooms"),
        backgroundColor: const Color(0xFF162447), // Dark blue
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () {
              _showCreateRoomDialog(context);
            },
          ),
        ],
      ),
      body: ListView.builder(
        itemCount: rooms.length,
        itemBuilder: (context, index) {
          return Card(
            color: const Color(0xFF0F3460), // Deep blue for room cards
            margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
            child: ListTile(
              title: Text(
                rooms[index],
                style: const TextStyle(color: Colors.white),
              ),
              onTap: () {
                // Handle room selection (optional)
                ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(
                    content: Text("Joined room: ${rooms[index]}"),
                  ),
                );
              },
            ),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showCreateRoomDialog(context);
        },
        backgroundColor: const Color(0xff8a07c1), // Purple accent color
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showCreateRoomDialog(BuildContext context) {
    final TextEditingController roomNameController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text("Create a New Room"),
          content: TextField(
            controller: roomNameController,
            decoration: const InputDecoration(hintText: "Enter room name"),
          ),
          actions: [
            TextButton(
              child: const Text("Cancel"),
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog
              },
            ),
            TextButton(
              child: const Text("Create"),
              onPressed: () {
                String roomName = roomNameController.text;
                if (roomName.isNotEmpty) {
                  setState(() {
                    rooms.add(roomName); // Add the new room to the list
                  });
                  Navigator.of(context).pop(); // Close the dialog
                  // Show a snackbar as confirmation
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                      content: Text("Room '$roomName' created!"),
                    ),
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}
