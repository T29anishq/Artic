import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class PersonalChatTab extends StatefulWidget {
  final String userId; // Logged-in user's ID

  const PersonalChatTab({Key? key, required this.userId}) : super(key: key);

  @override
  _PersonalChatTabState createState() => _PersonalChatTabState();
}

class _PersonalChatTabState extends State<PersonalChatTab> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  List<Map<String, dynamic>> _chats = [];

  @override
  void initState() {
    super.initState();
    _fetchChats();
  }

  Future<void> _fetchChats() async {
    try {
      QuerySnapshot querySnapshot = await _firestore
          .collection('chats')
          .where('participants', arrayContains: widget.userId)
          .get();

      List<Map<String, dynamic>> chatsList = [];

      for (var doc in querySnapshot.docs) {
        Map<String, dynamic> data = doc.data() as Map<String, dynamic>;
        List<String> participants = List<String>.from(data['participants']);

        participants.remove(widget.userId);

        String chatPartnerId = participants.isNotEmpty ? participants[0] : '';

        if (chatPartnerId.isNotEmpty) {
          DocumentSnapshot userDoc =
              await _firestore.collection('users').doc(chatPartnerId).get();
          if (userDoc.exists) {
            Map<String, dynamic> userData =
                userDoc.data() as Map<String, dynamic>;
            String username = userData['username'] ?? chatPartnerId;

            chatsList.add({
              'chatId': doc.id,
              'chatPartnerId': chatPartnerId,
              'username': username,
              'lastMessage': data['lastMessage'] ?? 'No messages yet',
            });
          }
        }
      }

      setState(() {
        _chats = chatsList;
      });
    } catch (e) {
      print('Error fetching chats: $e');
    }
  }

  void _navigateToChatDetail(
      String chatId, String chatPartnerId, String username) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => TwoUserChatScreen(
          chatId: chatId,
          loggedInUserId: widget.userId,
          chatPartnerId: chatPartnerId,
          chatPartnerName: username,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with users',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xffffffff),
      ),
      backgroundColor: const Color(0xFF1A1A2E),
      body: _chats.isEmpty
          ? const Center(
              child: Text(
                'No chats found.',
                style: TextStyle(color: Colors.white),
              ),
            )
          : ListView.builder(
              itemCount: _chats.length,
              itemBuilder: (context, index) {
                final chat = _chats[index];
                return ListTile(
                  title: Text(
                    'Chat with: ${chat['username']}',
                    style: const TextStyle(color: Colors.white),
                  ),
                  subtitle: Text(
                    chat['lastMessage'],
                    style: const TextStyle(color: Colors.grey),
                  ),
                  onTap: () => _navigateToChatDetail(
                    chat['chatId'],
                    chat['chatPartnerId'],
                    chat['username'],
                  ),
                  tileColor: const Color(0xFF162447),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                );
              },
            ),
    );
  }
}

class TwoUserChatScreen extends StatefulWidget {
  final String chatId;
  final String loggedInUserId;
  final String chatPartnerId;
  final String chatPartnerName;

  const TwoUserChatScreen({
    Key? key,
    required this.chatId,
    required this.loggedInUserId,
    required this.chatPartnerId,
    required this.chatPartnerName,
  }) : super(key: key);

  @override
  _TwoUserChatScreenState createState() => _TwoUserChatScreenState();
}

class _TwoUserChatScreenState extends State<TwoUserChatScreen> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _messageController = TextEditingController();

  void _sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _firestore
          .collection('chats')
          .doc(widget.chatId)
          .collection('messages')
          .add({
        'text': _messageController.text,
        'senderId': widget.loggedInUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Chat with ${widget.chatPartnerName}'),
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: _firestore
                  .collection('chats')
                  .doc(widget.chatId)
                  .collection('messages')
                  .orderBy('timestamp')
                  .snapshots(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(
                    child: CircularProgressIndicator(),
                  );
                }

                List<DocumentSnapshot> docs = snapshot.data!.docs;

                return ListView.builder(
                  itemCount: docs.length,
                  itemBuilder: (context, index) {
                    Map<String, dynamic> messageData =
                        docs[index].data() as Map<String, dynamic>;

                    bool isMe =
                        messageData['senderId'] == widget.loggedInUserId;

                    return Align(
                      alignment:
                          isMe ? Alignment.centerLeft : Alignment.centerRight,
                      child: Container(
                        margin: const EdgeInsets.symmetric(
                          horizontal: 8.0,
                          vertical: 4.0,
                        ),
                        padding: const EdgeInsets.all(10.0),
                        decoration: BoxDecoration(
                          color: isMe ? Colors.blue : Colors.grey,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          messageData['text'] ?? '',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: const InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
