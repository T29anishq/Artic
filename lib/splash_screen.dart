import 'package:flutter/material.dart';
import 'login.dart'; // Navigate to the login page

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _navigateToLogin();

    // Animation setup
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0.0, end: 1.0).animate(_controller)
      ..addListener(() {
        setState(() {});
      });

    _controller.forward();
  }

  // Method to navigate to the Login page
  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3)); // Splash screen delay
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(
          builder: (context) => LoginPage()), // Navigate to LoginPage
    );
  }

  @override
  void dispose() {
    _controller.dispose(); // Clean up the controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [
              Color(0xff2f4255),
              Color(0xff000000)
            ], // Darker blue gradient
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _buildLogo(), // Method to build logo
              SizedBox(height: 20), // Space between logo and text
              _buildTitle(), // Method to build title
            ],
          ),
        ),
      ),
    );
  }

  // Method to build logo with fade-in animation
  Widget _buildLogo() {
    return Opacity(
      opacity: _animation.value, // Use animation for opacity
      child: Container(
        decoration: BoxDecoration(
          color: Colors.white, // Background color for the logo container
          borderRadius: BorderRadius.circular(20), // Rounded corners
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3), // Slightly darker shadow
              blurRadius: 12,
              offset: Offset(0, 6),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(20), // Smooth edges
          child: Image.asset(
            'assets/logo.png', // Path to your logo image
            width: 200, // Adjust width
            height: 200, // Adjust height
            fit: BoxFit.contain, // Maintain aspect ratio
          ),
        ),
      ),
    );
  }

  // Method to build title with gradient color and animation
  Widget _buildTitle() {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        return Transform.scale(
          scale: 1 + 0.1 * _animation.value, // Scale effect
          child: Stack(
            alignment: Alignment.center,
            children: [
              // Darker shadow text for better visibility
              Text(
                'Artic',
                style: TextStyle(
                  fontSize: 50, // Slightly larger font size
                  fontFamily: 'Roboto',
                  fontWeight: FontWeight.bold,
                  //   color: Colors.black.withOpacity(0.7), // Darker shadow color
                ),
              ),
              // Gradient text on top
              ShaderMask(
                shaderCallback: (bounds) => LinearGradient(
                  colors: [
                    Color(0xffd47ef9),
                    Color(0xff8300cf)
                  ], // Bright gradient colors for text
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ).createShader(bounds),
                child: Text(
                  'Artic', // Text to display
                  style: TextStyle(
                    fontSize: 50, // Font size
                    fontFamily: 'Times New Roman', // Font family
                    fontWeight: FontWeight.bold, // Bold text
                    color: Colors.white, // Text color
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
