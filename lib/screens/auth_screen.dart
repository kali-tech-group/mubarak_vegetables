import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:mubarak_vegetables/screens/LocationUpdateScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:mubarak_vegetables/screens/BottomNavigationScreen.dart';
import 'package:mubarak_vegetables/screens/shared_prefs_helper.dart';

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
  bool _isCheckingAuth = true;

  @override
  void initState() {
    super.initState();
    _checkSavedUser();
  }

  void _checkSavedUser() async {
    // Check if user data exists in shared preferences
    String? savedPhone = await SharedPrefsHelper.getUserPhone();
    String? savedName = await SharedPrefsHelper.getUserName();

    if (savedPhone != null && savedName != null) {
      // Verify the user exists in Firebase
      final snapshot = await databaseRef.child(savedPhone).get();
      if (snapshot.exists) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => BottomNavigationScreen()),
        );
      } else {
        // Clear invalid saved data
        await SharedPrefsHelper.clearUserData();
      }
    }

    setState(() {
      _isCheckingAuth = false;
    });
  }

  void _submitForm() async {
    if (_formKey.currentState!.validate()) {
      final name = _nameController.text.trim();
      final phone = _phoneController.text.trim();
      final password = _passwordController.text.trim();

      if (_isLogin) {
        // Login logic
        final snapshot = await databaseRef.child(phone).get();
        if (snapshot.exists) {
          final userData = Map<String, dynamic>.from(
            snapshot.value as Map<Object?, Object?>,
          );
          if (userData['password'] == password) {
            // Save user data locally
            await SharedPrefsHelper.setUserPhone(phone);
            await SharedPrefsHelper.setUserName(userData['name']);

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
        // Signup logic
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

          // Save user data locally
          await SharedPrefsHelper.setUserPhone(phone);
          await SharedPrefsHelper.setUserName(name);

          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Account created successfully'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (_) => LocationUpdateScreen(userPhone: phone.trim()),
            ),
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
    // Show loading screen while checking auth status
    if (_isCheckingAuth) {
      return Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: Stack(
        children: [
          Positioned.fill(
            child: Image.asset('assets/images/bg.png', fit: BoxFit.cover),
          ),
          Positioned.fill(
            child: Container(color: Colors.black.withOpacity(0.3)),
          ),
          Center(
            child: SingleChildScrollView(
              child: Container(
                margin: EdgeInsets.symmetric(horizontal: 20),
                padding: EdgeInsets.all(25),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.95),
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
                      Image.asset(
                        'assets/images/Frame.png',
                        height: 100,
                        width: 200,
                      ),
                      SizedBox(height: 20),
                      Text(
                        _isLogin ? 'Login' : 'Sign Up',
                        style: TextStyle(
                          fontSize: 28,
                          fontWeight: FontWeight.bold,
                          color: Colors.green[900],
                        ),
                      ),
                      SizedBox(height: 20),
                      if (!_isLogin)
                        TextFormField(
                          controller: _nameController,
                          decoration: _inputDecoration('Name', Icons.person),
                          validator:
                              (value) =>
                                  value!.isEmpty ? 'Enter your name' : null,
                        ),
                      if (!_isLogin) SizedBox(height: 15),
                      TextFormField(
                        controller: _phoneController,
                        decoration: _inputDecoration(
                          'Phone Number',
                          Icons.phone,
                        ),
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
        ],
      ),
    );
  }
}
