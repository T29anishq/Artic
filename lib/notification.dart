import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class NotificationsPage extends StatefulWidget {
  @override
  _NotificationsPageState createState() => _NotificationsPageState();
}

class _NotificationsPageState extends State<NotificationsPage> {
  List<Map<String, dynamic>> followRequests = [];

  @override
  void initState() {
    super.initState();
    _loadFollowRequests();
  }

  Future<void> _loadFollowRequests() async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Fetch the current user's document from Firestore
      DocumentSnapshot currentUserDoc = await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .get();

      // Get the list of follow requests UIDs
      List<dynamic> requests = currentUserDoc['followRequests'] ?? [];

      List<Map<String, dynamic>> tempRequests = [];
      for (String requestId in requests) {
        // Fetch the user document of each request sender
        DocumentSnapshot userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(requestId)
            .get();

        if (userDoc.exists) {
          tempRequests.add({
            'uid': requestId,
            'username': userDoc['username'],
            'status': userDoc['status'], // Add status if needed
          });
        }
      }

      setState(() {
        followRequests = tempRequests;
      });
    } catch (e) {
      print('Error loading follow requests: $e');
    }
  }

  Future<void> _acceptRequest(String uid) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Update the following list for both users
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'following': FieldValue.arrayUnion([uid]),
        'followRequests':
            FieldValue.arrayRemove([uid]), // Remove from followRequests
      });

      await FirebaseFirestore.instance.collection('users').doc(uid).update({
        'followers': FieldValue.arrayUnion([currentUserId]), // Add to followers
      });

      // Optionally, update the status (e.g., 'accepted')
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'status': 'accepted'});

      // Remove the request from the UI immediately after acceptance
      setState(() {
        followRequests.removeWhere((request) => request['uid'] == uid);
      });
    } catch (e) {
      print('Error accepting request: $e');
    }
  }

  Future<void> _denyRequest(String uid) async {
    String currentUserId = FirebaseAuth.instance.currentUser!.uid;

    try {
      // Remove the request without accepting it
      await FirebaseFirestore.instance
          .collection('users')
          .doc(currentUserId)
          .update({
        'followRequests':
            FieldValue.arrayRemove([uid]), // Remove from followRequests
      });

      // Optionally, update status to 'denied'
      await FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .update({'status': 'denied'});

      // Remove the request from the UI immediately after denial
      setState(() {
        followRequests.removeWhere((request) => request['uid'] == uid);
      });
    } catch (e) {
      print('Error denying request: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Follow Requests'),
        backgroundColor: const Color(0xffffffff), // Dark blue
      ),
      body: followRequests.isEmpty
          ? Center(
              child: Text(
                'No new follow requests.',
                style: TextStyle(fontSize: 18.0, color: Colors.grey),
              ),
            )
          : Container(
              padding: const EdgeInsets.all(16.0),
              child: ListView.builder(
                itemCount: followRequests.length,
                itemBuilder: (context, index) {
                  final request = followRequests[index];

                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 10),
                    child: ListTile(
                      title: Text(
                        '${request['username']} has followed you. Follow back?',
                        style: const TextStyle(color: Colors.black),
                      ),
                      trailing: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          IconButton(
                            icon: const Icon(Icons.check, color: Colors.green),
                            onPressed: () => _acceptRequest(request['uid']),
                            tooltip: 'Follow Back',
                          ),
                          IconButton(
                            icon: const Icon(Icons.close, color: Colors.red),
                            onPressed: () => _denyRequest(request['uid']),
                            tooltip: 'Deny',
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
            ),
    );
  }
}
