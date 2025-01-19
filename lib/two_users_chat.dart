import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:html' as html; // For web image selection

class TwoUserChat extends StatefulWidget {
  final String loggedInUserId;
  final String otherUserName;

  const TwoUserChat({
    Key? key,
    required this.loggedInUserId,
    required this.otherUserName,
  }) : super(key: key);

  @override
  _TwoUserChatState createState() => _TwoUserChatState();
}

class _TwoUserChatState extends State<TwoUserChat> {
  final TextEditingController _messageController = TextEditingController();
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  bool _isUploading = false;
  String? chatId;

  @override
  void initState() {
    super.initState();
    _initializeChat();
  }

  Future<void> _initializeChat() async {
    try {
      // Step 1: Get the logged-in user's followers and following
      DocumentSnapshot userDoc =
          await _firestore.collection('users').doc(widget.loggedInUserId).get();
      List following = userDoc['following'] ?? [];
      List followers = userDoc['followers'] ?? [];

      // Step 2: Check for existing chats with followers or followed users
      for (String userId in following) {
        // Assuming each chat is represented by a unique chat ID created by the users
        QuerySnapshot chatQuery = await _firestore
            .collection('chats')
            .where('participants', arrayContains: widget.loggedInUserId)
            .where('participants', arrayContains: userId)
            .get();

        if (chatQuery.docs.isNotEmpty) {
          chatId = chatQuery.docs.first.id;
          break;
        }
      }

      // If no chat exists, create a new chat document
      if (chatId == null) {
        DocumentReference newChat = await _firestore.collection('chats').add({
          'participants': [widget.loggedInUserId, ...following],
          'lastMessage': '',
          'timestamp': FieldValue.serverTimestamp(),
        });
        chatId = newChat.id; // Save the new chat ID
      }
    } catch (e) {
      print('Error initializing chat: $e');
    }
  }

  Future<void> _sendMessage() async {
    if (_messageController.text.trim().isEmpty || chatId == null) return;

    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add({
        'text': _messageController.text.trim(),
        'senderId': widget.loggedInUserId,
        'timestamp': FieldValue.serverTimestamp(),
      });

      _messageController.clear();
      // Update the last message in the chat document
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': _messageController.text.trim(),
        'timestamp': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error sending message: $e');
    }
  }

  Future<void> _sendImage() async {
    // Open a file picker
    html.FileUploadInputElement uploadInput = html.FileUploadInputElement();
    uploadInput.accept = 'image/*'; // Accept only image files
    uploadInput.click();

    uploadInput.onChange.listen((e) async {
      final files = uploadInput.files;
      if (files!.isEmpty) return;
      final reader = html.FileReader();

      reader.onLoadEnd.listen((e) async {
        final imageFile = reader.result; // Get image data
        final fileName = 'images/${DateTime.now().millisecondsSinceEpoch}.png';

        setState(() {
          _isUploading = true; // Set uploading state
        });

        try {
          // Create a reference to the storage location
          final uploadTask = _storage.ref(fileName).putBlob(imageFile);
          await uploadTask;

          String downloadUrl = await _storage.ref(fileName).getDownloadURL();

          // Store the image URL in Firestore
          await _firestore
              .collection('chats')
              .doc(chatId)
              .collection('messages')
              .add({
            'imageUrl': downloadUrl,
            'senderId': widget.loggedInUserId,
            'timestamp': FieldValue.serverTimestamp(),
          });
        } catch (e) {
          print('Error uploading image: $e');
        } finally {
          setState(() {
            _isUploading = false; // Reset uploading state
          });
        }
      });

      reader.readAsArrayBuffer(files[0]); // Read the file as an ArrayBuffer
    });
  }

  Widget _buildMessageItem(DocumentSnapshot messageDoc) {
    Map<String, dynamic> messageData =
        messageDoc.data() as Map<String, dynamic>;
    bool isSentByLoggedInUser =
        messageData['senderId'] == widget.loggedInUserId;

    return Container(
      padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 10),
      alignment:
          isSentByLoggedInUser ? Alignment.centerRight : Alignment.centerLeft,
      child: Container(
        constraints:
            BoxConstraints(maxWidth: MediaQuery.of(context).size.width * 0.6),
        padding: const EdgeInsets.symmetric(vertical: 10, horizontal: 15),
        decoration: BoxDecoration(
          color: isSentByLoggedInUser ? Colors.blue : Colors.grey.shade300,
          borderRadius: isSentByLoggedInUser
              ? const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomLeft: Radius.circular(18),
                )
              : const BorderRadius.only(
                  topLeft: Radius.circular(18),
                  topRight: Radius.circular(18),
                  bottomRight: Radius.circular(18),
                ),
        ),
        child: messageData['imageUrl'] != null
            ? Image.network(messageData['imageUrl'])
            : Text(
                messageData['text'] ?? '',
                style: TextStyle(
                  color: isSentByLoggedInUser ? Colors.white : Colors.black,
                  fontSize: 16,
                ),
              ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Chat with ${widget.otherUserName}',
          style: const TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.w600,
          ),
        ),
        backgroundColor: const Color(0xFF162447),
      ),
      body: Column(
        children: [
          // Chat messages area
          Expanded(
            child: StreamBuilder<QuerySnapshot>(
              stream: chatId != null
                  ? _firestore
                      .collection('chats')
                      .doc(chatId)
                      .collection('messages')
                      .orderBy('timestamp', descending: true)
                      .snapshots()
                  : Stream.empty(),
              builder: (context, snapshot) {
                if (!snapshot.hasData) {
                  return const Center(child: CircularProgressIndicator());
                }

                final messages = snapshot.data!.docs;

                return ListView.builder(
                  reverse: true,
                  padding: const EdgeInsets.symmetric(horizontal: 10),
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    return _buildMessageItem(messages[index]);
                  },
                );
              },
            ),
          ),

          // Text input field and send button
          Padding(
            padding:
                const EdgeInsets.symmetric(horizontal: 8.0, vertical: 10.0),
            child: Row(
              children: [
                // Image icon
                IconButton(
                  icon: const Icon(Icons.camera_alt, color: Colors.black),
                  onPressed: _sendImage, // Tap to select image
                ),
                const SizedBox(width: 10),
                // Text input field
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    textInputAction: TextInputAction.send,
                    decoration: InputDecoration(
                      hintText: 'Type a message...',
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(30),
                        borderSide: BorderSide(color: Colors.grey),
                      ),
                      filled: true,
                      fillColor: Colors.white,
                    ),
                    onSubmitted: (value) => _sendMessage(),
                  ),
                ),
                const SizedBox(width: 10),
                // Send button
                CircleAvatar(
                  radius: 25,
                  backgroundColor: const Color(0xFF1f4068),
                  child: IconButton(
                    icon: const Icon(Icons.send, color: Color(0xff000000)),
                    onPressed: _sendMessage,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
