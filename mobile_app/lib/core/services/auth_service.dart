import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class AuthException implements Exception {
  final String message;
  final String? code;

  AuthException({required this.message, this.code});

  @override
  String toString() => message;
}

class AuthService {
  AuthService() : _client = Supabase.instance.client;

  final SupabaseClient _client;

  User? get currentUser => _client.auth.currentUser;
  Stream<AuthState> get authChanges => _client.auth.onAuthStateChange;
  Session? get currentSession => _client.auth.currentSession;

  String? get authProvider {
    final provider = _client.auth.currentUser?.appMetadata['provider'];
    if (provider is String && provider.isNotEmpty) return provider;
    final identities = _client.auth.currentUser?.identities;
    if (identities != null && identities.isNotEmpty) {
      return identities.first.provider;
    }
    return 'email';
  }

  bool get isOAuthUser {
    final provider = authProvider;
    return provider == 'google' || provider == 'github';
  }

  Future<AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(message: _mapAuthError(e.message), code: e.code);
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  Future<AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        throw AuthException(message: 'Please enter a valid email address.');
      }
      if (password.length < 6) {
        throw AuthException(message: 'Password must be at least 6 characters.');
      }
      if (fullName.trim().isEmpty) {
        throw AuthException(message: 'Please enter your full name.');
      }

      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
      return response;
    } on AuthException catch (e) {
      throw AuthException(message: _mapAuthError(e.message), code: e.code);
    } catch (e) {
      throw AuthException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final redirectUrl = _getRedirectUrl();
      await _client.auth.signInWithOAuth(
        OAuthProvider.google,
        redirectTo: redirectUrl,
        scopes: 'email profile',
      );
    } catch (e) {
      throw AuthException(message: 'Failed to sign in with Google. Please try again.');
    }
  }

  Future<void> signInWithGitHub() async {
    try {
      final redirectUrl = _getRedirectUrl();
      await _client.auth.signInWithOAuth(
        OAuthProvider.github,
        redirectTo: redirectUrl,
        scopes: 'read:user user:email',
      );
    } catch (e) {
      throw AuthException(message: 'Failed to sign in with GitHub. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AuthException(message: 'Failed to sign out. Please try again.');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(UserAttributes(password: newPassword));
    } catch (e) {
      throw AuthException(message: 'Failed to update password. Please try again.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: _getRedirectUrl(),
      );
    } catch (e) {
      throw AuthException(message: 'Failed to send reset email. Please try again.');
    }
  }

  String _getRedirectUrl() {
    if (kIsWeb) {
      return Uri.base.origin;
    }
    return 'com.example.mobileapp://auth';
  }

  String _mapAuthError(String message) {
    final lower = message.toLowerCase();
    if (lower.contains('invalid login credentials')) {
      return 'Invalid email or password. Please check your credentials.';
    }
    if (lower.contains('email not confirmed')) {
      return 'Please verify your email address before signing in.';
    }
    if (lower.contains('user already registered') || lower.contains('already registered')) {
      return 'An account with this email already exists.';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'Too many attempts. Please try again later.';
    }
    if (lower.contains('network') || lower.contains('timeout')) {
      return 'Network error. Please check your connection.';
    }
    if (lower.contains('oauth')) {
      return 'OAuth sign-in was cancelled or failed. Please try again.';
    }
    return message;
  }
}
