import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthProvider with ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();

  User? _user;
  bool _isLoading = false;
  String? _error;
  bool _isEmailVerified = false;

  // Getters
  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get error => _error;
  bool get isEmailVerified => _isEmailVerified;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _auth.authStateChanges().listen(_onAuthStateChanged);
  }

  void _onAuthStateChanged(User? user) {
    _user = user;
    _isEmailVerified = user?.emailVerified ?? false;
    notifyListeners();
  }

  void _clearError() {
    if (_error != null) {
      _error = null;
      notifyListeners();
    }
  }

  // Email/Password Signup
  Future<User?> signUpWithEmail({
    required String email,
    required String password,
    required String name,
    required String phone,
  }) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      await _sendEmailVerification();
      await _saveUserData(
        uid: credential.user!.uid,
        email: email,
        name: name,
        phone: phone,
      );

      return credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      if (kDebugMode) print('Signup Error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Email/Password Login
  Future<User?> loginWithEmail({
    required String email,
    required String password,
  }) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final credential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      _isEmailVerified = credential.user?.emailVerified ?? false;
      return credential.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _error = 'An unexpected error occurred';
      if (kDebugMode) print('Login Error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final googleUser = await _googleSignIn.signIn();
      if (googleUser == null) return null;

      final googleAuth = await googleUser.authentication;
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      final authResult = await _auth.signInWithCredential(credential);
      await _saveUserData(
        uid: authResult.user!.uid,
        email: authResult.user!.email!,
        name: authResult.user!.displayName ?? googleUser.displayName ?? 'User',
        phone: authResult.user!.phoneNumber ?? '',
      );

      return authResult.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _error = 'Google sign-in failed';
      if (kDebugMode) print('Google SignIn Error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Phone Authentication
  Future<void> verifyPhoneNumber({
    required String phoneNumber,
    required Function(String) onCodeSent,
    required Function(PhoneAuthCredential) onAutoVerify,
    required Function(FirebaseAuthException) onFailed,
  }) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      await _auth.verifyPhoneNumber(
        phoneNumber: phoneNumber,
        verificationCompleted: (credential) async {
          await _auth.signInWithCredential(credential);
          onAutoVerify(credential);
        },
        verificationFailed: onFailed,
        codeSent: (verificationId, forceResendingToken) {
          onCodeSent(verificationId);
        },
        codeAutoRetrievalTimeout: (verificationId) {},
      );
    } catch (e) {
      _error = 'Phone verification failed';
      if (kDebugMode) print('Phone Auth Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Verify OTP
  Future<User?> verifyOTP({
    required String verificationId,
    required String smsCode,
  }) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      final credential = PhoneAuthProvider.credential(
        verificationId: verificationId,
        smsCode: smsCode,
      );

      final authResult = await _auth.signInWithCredential(credential);
      return authResult.user;
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
      return null;
    } catch (e) {
      _error = 'OTP verification failed';
      if (kDebugMode) print('OTP Error: $e');
      return null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Save user data to Firestore
  Future<void> _saveUserData({
    required String uid,
    required String email,
    required String name,
    required String phone,
  }) async {
    try {
      await _firestore.collection('users').doc(uid).set({
        'uid': uid,
        'email': email,
        'name': name,
        'phone': phone,
        'createdAt': FieldValue.serverTimestamp(),
        'updatedAt': FieldValue.serverTimestamp(),
      }, SetOptions(merge: true));
    } catch (e) {
      if (kDebugMode) print('Save User Error: $e');
    }
  }

  // Send email verification
  Future<void> _sendEmailVerification() async {
    try {
      await _user?.sendEmailVerification();
    } catch (e) {
      if (kDebugMode) print('Email Verification Error: $e');
    }
  }

  // Check email verification status
  Future<void> checkEmailVerification() async {
    try {
      await _user?.reload();
      _isEmailVerified = _user?.emailVerified ?? false;
      notifyListeners();
    } catch (e) {
      if (kDebugMode) print('Email Check Error: $e');
    }
  }

  // Password reset
  Future<void> sendPasswordResetEmail(String email) async {
    try {
      _clearError();
      _isLoading = true;
      notifyListeners();

      await _auth.sendPasswordResetEmail(email: email);
    } on FirebaseAuthException catch (e) {
      _handleAuthError(e);
    } catch (e) {
      _error = 'Password reset failed';
      if (kDebugMode) print('Password Reset Error: $e');
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Logout
  Future<void> logout() async {
    try {
      await _auth.signOut();
      await _googleSignIn.signOut();
      _user = null;
      notifyListeners();
    } catch (e) {
      _error = 'Logout failed';
      if (kDebugMode) print('Logout Error: $e');
    }
  }

  // Handle auth errors
  void _handleAuthError(FirebaseAuthException e) {
    switch (e.code) {
      case 'email-already-in-use':
        _error = 'Email already in use';
        break;
      case 'invalid-email':
        _error = 'Invalid email address';
        break;
      case 'operation-not-allowed':
        _error = 'Account creation disabled';
        break;
      case 'weak-password':
        _error = 'Password is too weak';
        break;
      case 'user-disabled':
        _error = 'Account disabled';
        break;
      case 'user-not-found':
        _error = 'No account found';
        break;
      case 'wrong-password':
        _error = 'Incorrect password';
        break;
      case 'too-many-requests':
        _error = 'Too many attempts. Try again later';
        break;
      default:
        _error = 'Authentication failed';
    }
    if (kDebugMode) print('Auth Error: ${e.code}');
  }
}
