import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:lottie/lottie.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mubarak_vegetables/screens/BottomNavigationScreen.dart';

class AuthScreen extends StatefulWidget {
  @override
  _AuthScreenState createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> {
  bool _isLogin = true;
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _passwordController = TextEditingController();

  final DatabaseReference databaseRef = FirebaseDatabase.instance.ref().child(
    "users",
  );

  // Method to handle sign up or login
  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        final snapshot = await databaseRef.child(phone).get();
        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(
            snapshot.value as Map<Object?, Object?>,
          );
          if (userData['password'] == password) {
            SharedPreferences prefs = await SharedPreferences.getInstance();
            await prefs.setString('phone_number', phone);

            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                content: Text('Login successful'),
                backgroundColor: Colors.green,
              ),
            );

            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
            );
          } else {
            _showError('Incorrect password');
          }
        } else {
          _showError('Phone number not found');
        }
      } else {
        final snapshot = await databaseRef.child(phone).get();
        if (snapshot.exists) {
          _showError('This phone number is already registered');
        } else {
          await databaseRef.child(phone).set({
            'name': name,
            'phone_number': phone,
            'password': password,
            'signup_time': DateTime.now().toIso8601String(),
          });

          SharedPreferences prefs = await SharedPreferences.getInstance();
          await prefs.setString('phone_number', phone);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully'),
              backgroundColor: Colors.green,
            ),
          );

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => OnboardingScreen()),
          );
        }
      }
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  InputDecoration _inputDecoration(String label, IconData icon) {
    return InputDecoration(
      labelText: label,
      prefixIcon: Icon(icon, color: Colors.green),
      filled: true,
      fillColor: Colors.green[50],
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(15),
        borderSide: BorderSide.none,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.green.shade100,
      body: Center(
        child: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            padding: EdgeInsets.all(25),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.green.withOpacity(0.2),
                  blurRadius: 10,
                  offset: Offset(0, 5),
                ),
              ],
            ),
            child: Form(
              key: _formKey,
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text(
                    _isLogin ? 'Login' : 'Sign Up',
                    style: TextStyle(
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      color: Colors.green[800],
                    ),
                  ),
                  SizedBox(height: 20),
                  if (!_isLogin)
                    TextFormField(
                      controller: _nameController,
                      decoration: _inputDecoration('Name', Icons.person),
                      validator:
                          (value) => value!.isEmpty ? 'Enter your name' : null,
                    ),
                  if (!_isLogin) SizedBox(height: 15),
                  TextFormField(
                    controller: _phoneController,
                    decoration: _inputDecoration('Phone Number', Icons.phone),
                    keyboardType: TextInputType.phone,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 10)
                        return 'Enter a valid phone number';
                      return null;
                    },
                  ),
                  SizedBox(height: 15),
                  TextFormField(
                    controller: _passwordController,
                    decoration: _inputDecoration('Password', Icons.lock),
                    obscureText: true,
                    validator: (value) {
                      if (value!.isEmpty || value.length < 6)
                        return 'Password must be at least 6 characters';
                      return null;
                    },
                  ),
                  SizedBox(height: 25),
                  ElevatedButton(
                    onPressed: _submitForm,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.green,
                      padding: EdgeInsets.symmetric(
                        horizontal: 40,
                        vertical: 15,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                    ),
                    child: Text(
                      _isLogin ? 'Login' : 'Sign Up',
                      style: TextStyle(fontSize: 16, color: Colors.white),
                    ),
                  ),
                  TextButton(
                    onPressed: () => setState(() => _isLogin = !_isLogin),
                    child: Text(
                      _isLogin
                          ? 'Create new account'
                          : 'Already have an account? Login',
                      style: TextStyle(color: Colors.green[700]),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// obord

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
            onPageChanged: (index) => setState(() => _currentPage = index),
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
          Positioned(
            bottom: 40,
            left: 0,
            right: 0,
            child: Column(
              children: [
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
                        MaterialPageRoute(
                          builder: (_) => BottomNavigationScreen(),
                        ),
                      );
                    },
                    child: Text('Get Started', style: TextStyle(fontSize: 16)),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
