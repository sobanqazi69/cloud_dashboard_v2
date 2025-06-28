import 'package:firebase_auth/firebase_auth.dart';
import 'dart:developer' as developer;

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Get current user
  User? get currentUser => _auth.currentUser;

  // Auth state changes stream
  Stream<User?> get authStateChanges => _auth.authStateChanges();

  // Sign in with email and password
  Future<UserCredential> signInWithEmailAndPassword({
    required String email,
    required String password,
  }) async {
    try {
      developer.log('Attempting to sign in with email: $email');
      final result = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );
      developer.log('Sign in successful for user: ${result.user?.uid}');
      return result;
    } catch (e) {
      developer.log(
        'Sign in failed',
        error: e,
        stackTrace: StackTrace.current,
      );
      throw _handleAuthException(e);
    }
  }

  // Sign out
  Future<void> signOut() async {
    try {
      await _auth.signOut();
      developer.log('User signed out successfully');
    } catch (e) {
      developer.log('Sign out failed', error: e);
      rethrow;
    }
  }

  // Handle Firebase Auth exceptions
  String _handleAuthException(dynamic e) {
    if (e is FirebaseAuthException) {
      developer.log('FirebaseAuthException - Code: ${e.code}, Message: ${e.message}');
      switch (e.code) {
        case 'user-not-found':
          return 'No user found with this email address.';
        case 'wrong-password':
          return 'Incorrect password. Please try again.';
        case 'invalid-email':
          return 'The email address is not valid.';
        case 'user-disabled':
          return 'This user account has been disabled.';
        case 'too-many-requests':
          return 'Too many failed attempts. Please try again later.';
        case 'operation-not-allowed':
          return 'Email/password sign-in is not enabled.';
        case 'invalid-credential':
          return 'The provided credentials are invalid.';
        case 'network-request-failed':
          return 'Network error. Please check your connection and try again.';
        case 'weak-password':
          return 'The password is too weak.';
        case 'email-already-in-use':
          return 'An account already exists with this email address.';
        default:
          return 'Authentication failed: ${e.message ?? 'Unknown error'}';
      }
    }
    developer.log('Non-FirebaseAuth exception: $e');
    return 'An unexpected error occurred: ${e.toString()}';
  }
} 