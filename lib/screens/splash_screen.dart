import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mubarak_vegetables/screens/auth_screen.dart';
import 'package:mubarak_vegetables/screens/BottomNavigationScreen.dart';
import 'package:mubarak_vegetables/screens/shared_prefs_helper.dart';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(seconds: 2),
      vsync: this,
    )..forward();

    _checkAuthStatus();
  }

  Future<void> _checkAuthStatus() async {
    // Check if user data exists in shared preferences
    String? savedPhone = await SharedPrefsHelper.getUserPhone();
    String? savedName = await SharedPrefsHelper.getUserName();

    if (savedPhone != null && savedName != null) {
      // Verify the user exists in Firebase
      final ref = FirebaseDatabase.instance.ref("users/$savedPhone");
      final snapshot = await ref.get();

      if (snapshot.exists) {
        // User is authenticated and exists in Firebase
        print("User authenticated. Phone: $savedPhone, Name: $savedName");
        _navigateToHome();
      } else {
        // User data in shared prefs doesn't match Firebase
        print("User data not found in Firebase. Clearing local data.");
        await SharedPrefsHelper.clearUserData();
        _navigateToAuth();
      }
    } else {
      // No saved user data found
      print("No saved user data found.");
      _navigateToAuth();
    }
  }

  void _navigateToHome() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
    );
  }

  void _navigateToAuth() {
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => AuthScreen()),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Expanded(
              child: ScaleTransition(
                scale: Tween(begin: 0.5, end: 1.0).animate(
                  CurvedAnimation(
                    parent: _controller,
                    curve: Curves.elasticOut,
                  ),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      'assets/images/Frame.png',
                      width: 150,
                      height: 150,
                    ),
                    SizedBox(height: 20),
                    if (_isCheckingAuth)
                      CircularProgressIndicator(
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.green),
                      ),
                  ],
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 20),
              child: Column(
                children: [
                  // Text(
                  //   'MADE BY',
                  //   style: TextStyle(
                  //     fontSize: 10,
                  //     fontWeight: FontWeight.bold,
                  //     color: Colors.green[800],
                  //   ),
                  // ),
                  // SizedBox(height: 2),
                  // Text(
                  //   'Kali Nuxus',
                  //   style: TextStyle(
                  //     fontSize: 16,
                  //     fontWeight: FontWeight.bold,
                  //     color: const Color.fromARGB(255, 85, 125, 255),
                  //   ),
                  // ),
                ],
              ),
            ),
          ],
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
