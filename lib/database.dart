import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/foundation.dart'; // Import this for debugPrint
import 'firebase_options.dart';

class DatabaseService {
  static final DatabaseService _instance = DatabaseService._internal();
  final DatabaseReference _dbRef;

  DatabaseService._internal()
      : _dbRef = FirebaseDatabase.instanceFor(
                app: Firebase.app(), // Use the Firebase app instance
                databaseURL: 'https://artic-7d7ff-default-rtdb.firebaseio.com/')
            .ref(); // Use ref() method

  factory DatabaseService() {
    return _instance;
  }

  static Future<void> initializeFirebase() async {
    try {
      await Firebase.initializeApp(
        options: DefaultFirebaseOptions.currentPlatform,
      );
      debugPrint("Firebase initialized successfully.");
    } catch (e) {
      debugPrint("Error initializing Firebase: $e");
    }
  }

  // Method to write data to the Realtime Database
  Future<void> writeData(String path, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(path).set(data);
      debugPrint("Data written successfully.");
    } catch (e) {
      debugPrint("Error writing data: $e");
    }
  }

  // Method to read data from the Realtime Database
  Future<DataSnapshot> readData(String path) async {
    try {
      return await _dbRef.child(path).get();
    } catch (e) {
      debugPrint("Error reading data: $e");
      rethrow;
    }
  }

  // Method to update data in the Realtime Database
  Future<void> updateData(String path, Map<String, dynamic> data) async {
    try {
      await _dbRef.child(path).update(data);
      debugPrint("Data updated successfully.");
    } catch (e) {
      debugPrint("Error updating data: $e");
    }
  }

  // Method to delete data from the Realtime Database
  Future<void> deleteData(String path) async {
    try {
      await _dbRef.child(path).remove();
      debugPrint("Data deleted successfully.");
    } catch (e) {
      debugPrint("Error deleting data: $e");
    }
  }
}
