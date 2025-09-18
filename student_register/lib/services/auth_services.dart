// lib/services/auth_services.dart
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart' show kIsWeb;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Email/Password - unchanged
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  Future<UserCredential> registerWithEmail(String email, String password) async {
    final credential = await _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
    if (!credential.user!.emailVerified) {
      await credential.user!.sendEmailVerification();
    }
    return credential;
  }

  /// ✅ Google Sign-In for **Web** (creates account if not exists; signs in if exists)
  Future<UserCredential> signInWithGoogle() async {
    if (!kIsWeb) {
      // We're focusing on Web now; you can add mobile later
      throw UnimplementedError('Google sign-in here is implemented for Web only.');
    }

    final provider = GoogleAuthProvider();
    provider.addScope('email');
    // Show the account chooser every time (so user can pick an existing Gmail)
    provider.setCustomParameters({'prompt': 'select_account'});

    // Popup is simplest for Flutter Web dev; you can also use signInWithRedirect
    return await _auth.signInWithPopup(provider);
  }

  Future<void> signOut() async => _auth.signOut();

  Stream<User?> get userChanges => _auth.authStateChanges();
}
