// auth_service.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  // Sign up with email/password
  Future<UserCredential> signUp(String email, String password, String name) async {
    // 1. Create the auth account
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );

    // 2. Immediately create the Firestore profile document under their UID
    // This is what "unlocks" their private collections
    await _db.collection('users').doc(credential.user!.uid).set({
      'displayName': name,
      'email': email,
      'createdAt': FieldValue.serverTimestamp(),
      'onboardingComplete': false,
    });

    return credential;
  }

  // Sign in
  Future<UserCredential> signIn(String email, String password) async {
    return await _auth.signInWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async => await _auth.signOut();

  // Auth state stream — listen to this in your app's root widget
  Stream<User?> get authStateChanges => _auth.authStateChanges();
}