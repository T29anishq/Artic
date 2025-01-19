import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home.dart';
import 'signin.dart';
import 'login.dart';
import 'firebase_options.dart';
import 'splash_screen.dart';
import 'refresh.dart'; // Import RefreshWidget

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Artic',
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
      routes: {
        '/home': (context) => RefreshWidget(
              onRefresh: _refreshHomeContent, // Add refresh logic here
              child: HomePage(),
            ),
        '/signin': (context) => SignInPage(),
        '/login': (context) => LoginPage(),
      },
    );
  }

  // Example refresh logic
  Future<void> _refreshHomeContent() async {
    print("Refreshing home content...");
    await Future.delayed(Duration(seconds: 1)); // Simulate a refresh task
  }
}
