import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';

class FirebaseService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final DatabaseReference _dbRef = FirebaseDatabase.instance.ref();

  // User authentication methods
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return result.user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  // Database methods
  Future<void> saveUserData(String userId, Map<String, dynamic> data) async {
    await _dbRef.child('users').child(userId).set(data);
  }

  Future<Map<String, dynamic>?> getUserData(String userId) async {
    final snapshot = await _dbRef.child('users').child(userId).get();
    if (snapshot.exists) {
      return Map<String, dynamic>.from(snapshot.value as Map);
    }
    return null;
  }

  static validatePromo(String promoCode) {}
}
