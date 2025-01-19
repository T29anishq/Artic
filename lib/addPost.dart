import 'dart:html' as html;
import 'dart:typed_data';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AddPostPage extends StatefulWidget {
  const AddPostPage({Key? key}) : super(key: key);

  @override
  _AddPostPageState createState() => _AddPostPageState();
}

class _AddPostPageState extends State<AddPostPage> {
  String _selectedPostType = 'images'; // Default post type is images
  List<html.File>? _selectedImages = [];
  List<html.File>? _selectedVideos = [];
  html.File? _selectedAudio; // For background audio
  bool _isLoading = false;
  String _caption = ""; // Caption for the post

  // Pick images from gallery
  Future<void> _pickImages() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'image/*';
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        setState(() {
          _selectedImages = List.from(files);
        });
      }
    });
  }

  // Pick a video
  Future<void> _pickVideo() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'video/*';
    uploadInput.multiple = true;
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        setState(() {
          _selectedVideos = List.from(files);
        });
      }
    });
  }

  // Pick audio
  Future<void> _pickAudio() async {
    final html.FileUploadInputElement uploadInput =
        html.FileUploadInputElement();
    uploadInput.accept = 'audio/*';
    uploadInput.click();

    uploadInput.onChange.listen((e) {
      final files = uploadInput.files;
      if (files!.isNotEmpty) {
        setState(() {
          _selectedAudio = files[0];
        });
      }
    });
  }

  // Upload images, videos, and audio
  Future<void> _uploadPost() async {
    setState(() {
      _isLoading = true;
    });

    try {
      List<String> fileUrls = [];

      // Upload images
      if (_selectedImages != null) {
        for (var image in _selectedImages!) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(image);
          await reader.onLoadEnd.first; // Wait for the file to read

          final ref =
              FirebaseStorage.instance.ref().child('images/${image.name}');
          await ref.putData(reader.result as Uint8List);
          final url = await ref.getDownloadURL();
          fileUrls.add(url);
        }
      }

      // Upload videos
      if (_selectedVideos != null) {
        for (var video in _selectedVideos!) {
          final reader = html.FileReader();
          reader.readAsArrayBuffer(video);
          await reader.onLoadEnd.first; // Wait for the file to read

          final ref =
              FirebaseStorage.instance.ref().child('videos/${video.name}');
          await ref.putData(reader.result as Uint8List);
          final url = await ref.getDownloadURL();
          fileUrls.add(url);
        }
      }

      // Upload audio if post type is images
      if (_selectedAudio != null && _selectedPostType == 'images') {
        final reader = html.FileReader();
        reader.readAsArrayBuffer(_selectedAudio!);
        await reader.onLoadEnd.first; // Wait for the file to read

        final ref = FirebaseStorage.instance
            .ref()
            .child('audio/${_selectedAudio!.name}');
        await ref.putData(reader.result as Uint8List);
        final url = await ref.getDownloadURL();
        fileUrls.add(url);
      }

      // Save post data to Firestore in artworks collection
      final userId =
          FirebaseAuth.instance.currentUser?.uid; // Get actual user ID
      if (userId != null) {
        final postData = {
          'userId': userId, // Use actual user ID
          'postType': _selectedPostType,
          'fileUrls': fileUrls,
          'caption': _caption,
          'likes': [],
          'dislikes': [],
          'comments': [],
          'timestamp': FieldValue.serverTimestamp(),
        };

        await FirebaseFirestore.instance.collection('artworks').add(postData);

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Post uploaded successfully!')),
        );
      } else {
        throw Exception("User not logged in.");
      }
    } catch (e) {
      print('Error uploading post: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to upload post!!')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Post'),
        backgroundColor: const Color(0xFF162447),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text(
                    'Select Post Type:',
                    style: TextStyle(fontSize: 18, color: Colors.white),
                  ),
                  const SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Radio<String>(
                        value: 'images',
                        groupValue: _selectedPostType,
                        onChanged: (value) {
                          setState(() {
                            _selectedPostType = value!;
                            _selectedImages = [];
                            _selectedVideos = [];
                          });
                        },
                      ),
                      const Text('Images',
                          style: TextStyle(color: Colors.white)),
                      const SizedBox(width: 20),
                      Radio<String>(
                        value: 'videos',
                        groupValue: _selectedPostType,
                        onChanged: (value) {
                          setState(() {
                            _selectedPostType = value!;
                            _selectedImages = [];
                            _selectedVideos = [];
                          });
                        },
                      ),
                      const Text('Videos',
                          style: TextStyle(color: Colors.white)),
                    ],
                  ),
                  const SizedBox(height: 20),

                  // Show image or video picker based on selected post type
                  if (_selectedPostType == 'images') _buildImagePicker(),
                  if (_selectedPostType == 'videos') _buildVideoPicker(),

                  const SizedBox(height: 20),

                  // Caption input field
                  TextField(
                    onChanged: (value) {
                      setState(() {
                        _caption = value;
                      });
                    },
                    decoration: InputDecoration(
                      labelText: 'Caption',
                      labelStyle: TextStyle(color: Colors.white),
                      border: OutlineInputBorder(),
                      filled: true,
                      fillColor: Colors.grey[800],
                    ),
                    style: TextStyle(color: Colors.white),
                  ),

                  const SizedBox(height: 20),

                  // Background audio selection
                  if (_selectedPostType == 'images') ...[
                    ElevatedButton(
                      onPressed: _pickAudio,
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xff7768ff),
                      ),
                      child: const Text('Select Background Audio'),
                    ),
                    if (_selectedAudio != null)
                      Padding(
                        padding: const EdgeInsets.only(top: 10),
                        child: Text(
                          'Selected audio: ${_selectedAudio!.name}',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                  ],

                  const SizedBox(height: 30),

                  // Submit Button
                  Center(
                    child: ElevatedButton(
                      onPressed: _uploadPost,
                      style: ElevatedButton.styleFrom(
                        padding: const EdgeInsets.symmetric(
                            vertical: 16, horizontal: 32),
                        backgroundColor: const Color(0xff7768ff),
                      ),
                      child: const Text(
                        'Submit Post',
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
                  ),
                ],
              ),
            ),
      backgroundColor: const Color(0xFF1A1A2E), // Dark background color
    );
  }

  // Widget to display image picker and selected images
  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _pickImages,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff7768ff),
          ),
          child: const Text('Select Images'),
        ),
        const SizedBox(height: 10),
        if (_selectedImages != null && _selectedImages!.isNotEmpty)
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: 3,
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
            ),
            itemCount: _selectedImages!.length,
            itemBuilder: (context, index) {
              return Image.network(
                html.Url.createObjectUrl(_selectedImages![
                    index]), // Use object URL for displaying images
                fit: BoxFit.cover,
              );
            },
          )
        else
          const Text(
            'No images selected.',
            style: TextStyle(color: Colors.white),
          ),
      ],
    );
  }

  // Widget to display video picker and selected videos
  Widget _buildVideoPicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ElevatedButton(
          onPressed: _pickVideo,
          style: ElevatedButton.styleFrom(
            backgroundColor: const Color(0xff7768ff),
          ),
          child: const Text('Select Videos'),
        ),
        const SizedBox(height: 10),
        if (_selectedVideos != null && _selectedVideos!.isNotEmpty)
          ListView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: _selectedVideos!.length,
            itemBuilder: (context, index) {
              return Text(
                'Selected video: ${_selectedVideos![index].name}',
                style: const TextStyle(color: Colors.white),
              );
            },
          )
        else
          const Text(
            'No videos selected.',
            style: TextStyle(color: Colors.white),
          ),
      ],
    );
  }
}
