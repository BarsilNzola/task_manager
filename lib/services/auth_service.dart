import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  bool _isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }

  Future<void> sendEmailVerification() async {
    await _auth.currentUser?.sendEmailVerification();
  }

  bool isEmailVerified() {
    return _auth.currentUser?.emailVerified ?? false;
  }

  // Email/Password Sign-Up
  Future<User?> signUpWithEmail(String email, String password) async {
    if (!_isValidEmail(email)) throw 'Invalid email format';
    if (password.length < 6) throw 'Password must be 6+ characters';

    try {
      UserCredential cred = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );
      await sendEmailVerification(); // Auto-send verification email
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // Email/Password Sign-In
  Future<User?> signInWithEmail(String email, String password) async {
    try {
      UserCredential cred = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      return cred.user;
    } on FirebaseAuthException catch (e) {
      throw _authError(e.code);
    }
  }

  // Google Sign-In
  Future<User?> signInWithGoogle() async {
    try {
      final GoogleSignInAccount? googleUser = await GoogleSignIn().signIn();
      final GoogleSignInAuthentication googleAuth = await googleUser!.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      UserCredential cred = await _auth.signInWithCredential(credential);
      return cred.user;
    } catch (e) {
      throw "Google sign-in failed";
    }
  }

  // Error Handling
  String _authError(String code) {
    switch (code) {
      case 'invalid-email': return 'Invalid email format';
      case 'user-not-found': return 'No user found';
      case 'wrong-password': return 'Incorrect password';
      case 'email-already-in-use': return 'Email already registered';
      default: return 'Login failed';
    }
  }

  // Sign Out
  Future<void> signOut() async {
    await _auth.signOut();
    await GoogleSignIn().signOut();
  }
}