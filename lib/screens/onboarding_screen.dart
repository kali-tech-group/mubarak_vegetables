import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';
import 'package:mubarak_vegetables/screens/auth_screen.dart';

class OnboardingScreen extends StatefulWidget {
  @override
  _OnboardingScreenState createState() => _OnboardingScreenState();
}

class _OnboardingScreenState extends State<OnboardingScreen> {
  final PageController _pageController = PageController();
  int _currentPage = 0;

  final List<Map<String, dynamic>> _pages = [
    {
      'image': 'assets/lotties/vegi.json',
      'title': 'Farm Fresh Vegetables',
      'description': 'Direct from local farms to your kitchen',
      'color': Color(0xFFF5F9F4),
    },
    {
      'image': 'assets/lotties/dele.json',
      'title': 'Fast Delivery',
      'description': 'Delivered quickly to your doorstep',
      'color': Color(0xFFF5F9F4),
    },
    {
      'image': 'assets/lotties/mony.json',
      'title': 'Affordable Prices',
      'description': 'Best deals for healthy eating',
      'color': Color(0xFFF5F9F4),
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          PageView.builder(
            controller: _pageController,
            itemCount: _pages.length,
            onPageChanged: (index) {
              setState(() => _currentPage = index);
            },
            itemBuilder: (_, index) {
              return Container(
                color: _pages[index]['color'],
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 80),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Lottie.asset(
                      _pages[index]['image'],
                      height: 300,
                      fit: BoxFit.contain,
                    ),
                    SizedBox(height: 40),
                    Text(
                      _pages[index]['title'],
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: Colors.green[800],
                      ),
                    ),
                    SizedBox(height: 20),
                    Text(
                      _pages[index]['description'],
                      textAlign: TextAlign.center,
                      style: TextStyle(fontSize: 16, color: Colors.grey[800]),
                    ),
                  ],
                ),
              );
            },
          ),

          // Page indicator & Get Started button
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
                // Page dots
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: List.generate(
                    _pages.length,
                    (index) => AnimatedContainer(
                      duration: Duration(milliseconds: 300),
                      margin: EdgeInsets.symmetric(horizontal: 4),
                      width: _currentPage == index ? 20 : 8,
                      height: 8,
                      decoration: BoxDecoration(
                        color:
                            _currentPage == index ? Colors.green : Colors.grey,
                        borderRadius: BorderRadius.circular(4),
                      ),
                    ),
                  ),
                ),
                SizedBox(height: 20),
                // Get Started Button
                if (_currentPage == _pages.length - 1)
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green[700],
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(30),
                      ),
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 14,
                      ),
                    ),
                    onPressed: () {
                      Navigator.pushReplacement(
                        context,
                        MaterialPageRoute(builder: (_) => AuthScreen()),
                      );
                    },
                    child: Text('Get Started', style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
          ),

          // Optional Skip Button
          // if (_currentPage != _pages.length - 1)
          //   Positioned(
          //     top: 40,
          //     right: 20,
          //     child: TextButton(
          //       onPressed: () {
          //         _pageController.animateToPage(
          //           _pages.length - 1,
          //           duration: Duration(milliseconds: 500),
          //           curve: Curves.easeInOut,
          //         );
          //       },
          //       child: Text(
          //         'Skip',
          //         style: TextStyle(
          //           color: Colors.green[700],
          //           fontWeight: FontWeight.bold,
          //         ),
          //       ),
          //     ),
          //   ),
        ],
      ),
    );
  }
}
