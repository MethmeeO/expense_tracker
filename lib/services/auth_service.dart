import 'package:firebase_auth/firebase_auth.dart';

/// Minimal auth layer. Signs the device in anonymously so every user's
/// expenses are private to them without requiring a login screen.
/// (Swap signInAnon() for email/password sign-in later if you want a
/// visible login flow for extra credit.)
class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<String> signInAnon() async {
    final current = _auth.currentUser;
    if (current != null) return current.uid;
    final cred = await _auth.signInAnonymously();
    return cred.user!.uid;
  }

  String? get currentUid => _auth.currentUser?.uid;
}
