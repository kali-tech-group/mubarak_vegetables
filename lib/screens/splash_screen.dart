import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mubarak_vegetables/screens/auth_screen.dart';
import 'package:mubarak_vegetables/screens/BottomNavigationScreen.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 3),
      vsync: this,
    )..forward();

    _navigateAfterDelay();
  }

  Future<void> _navigateAfterDelay() async {
    await Future.delayed(Duration(seconds: 3));

    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? savedPhone = prefs.getString('phone_number');

    if (savedPhone != null && savedPhone.isNotEmpty) {
      print("Saved phone number: $savedPhone");

      // Check if this phone exists in Firebase Realtime DB
      final ref = FirebaseDatabase.instance.ref("users/$savedPhone");
      final snapshot = await ref.get();

      if (snapshot.exists) {
        print("Phone number exists in Firebase. Navigating to HomePage.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
        );
      } else {
        print("Phone not found in Firebase. Going to AuthScreen.");
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => AuthScreen()),
        );
      }
    } else {
      print("No saved phone number found. Redirecting to AuthScreen.");
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => AuthScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: ScaleTransition(
          scale: Tween(begin: 0.5, end: 1.0).animate(
            CurvedAnimation(parent: _controller, curve: Curves.elasticOut),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              SizedBox(height: 280),
              Image.asset('assets/images/Frame.png', width: 150, height: 150),
              SizedBox(height: 20),
              SizedBox(height: 270),
              Text(
                'MADE BY',
                style: TextStyle(
                  fontSize: 10,
                  fontWeight: FontWeight.bold,
                  color: Colors.green[800],
                ),
              ),
              SizedBox(height: 2),
              Text(
                'Kali Nuxus',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: const Color.fromARGB(255, 85, 125, 255),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
