import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart' as sb;

class AppAuthException implements Exception {
  final String message;
  final String? code;

  AppAuthException({required this.message, this.code});

  @override
  String toString() => message;
}

class AuthService {
  AuthService() : _client = sb.Supabase.instance.client;

  final sb.SupabaseClient _client;

  sb.User? get currentUser => _client.auth.currentUser;
  Stream<sb.AuthState> get authChanges => _client.auth.onAuthStateChange;
  sb.Session? get currentSession => _client.auth.currentSession;

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

  Future<sb.AuthResponse> signIn({
    required String email,
    required String password,
  }) async {
    try {
      final response = await _client.auth.signInWithPassword(
        email: email.trim().toLowerCase(),
        password: password,
      );
      return response;
    } on sb.AuthException catch (e) {
      throw AppAuthException(message: _mapAuthError(e.message), code: e.code);
    } catch (e) {
      throw AppAuthException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  Future<sb.AuthResponse> signUp({
    required String email,
    required String password,
    required String fullName,
  }) async {
    try {
      if (email.isEmpty || !email.contains('@')) {
        throw AppAuthException(message: 'Please enter a valid email address.');
      }
      if (password.length < 6) {
        throw AppAuthException(message: 'Password must be at least 6 characters.');
      }
      if (fullName.trim().isEmpty) {
        throw AppAuthException(message: 'Please enter your full name.');
      }

      final response = await _client.auth.signUp(
        email: email.trim().toLowerCase(),
        password: password,
        data: {'full_name': fullName.trim()},
      );
      return response;
    } on sb.AuthException catch (e) {
      throw AppAuthException(message: _mapAuthError(e.message), code: e.code);
    } catch (e) {
      throw AppAuthException(message: 'An unexpected error occurred. Please try again.');
    }
  }

  Future<void> signInWithGoogle() async {
    try {
      final redirectUrl = _getRedirectUrl();
      await _client.auth.signInWithOAuth(
        sb.OAuthProvider.google,
        redirectTo: redirectUrl,
        scopes: 'email profile',
      );
    } catch (e) {
      throw AppAuthException(message: 'Failed to sign in with Google. Please try again.');
    }
  }

  Future<void> signInWithGitHub() async {
    try {
      final redirectUrl = _getRedirectUrl();
      await _client.auth.signInWithOAuth(
        sb.OAuthProvider.github,
        redirectTo: redirectUrl,
        scopes: 'read:user user:email',
      );
    } catch (e) {
      throw AppAuthException(message: 'Failed to sign in with GitHub. Please try again.');
    }
  }

  Future<void> signOut() async {
    try {
      await _client.auth.signOut();
    } catch (e) {
      throw AppAuthException(message: 'Failed to sign out. Please try again.');
    }
  }

  Future<void> updatePassword(String newPassword) async {
    try {
      await _client.auth.updateUser(sb.UserAttributes(password: newPassword));
    } catch (e) {
      throw AppAuthException(message: 'Failed to update password. Please try again.');
    }
  }

  Future<void> resetPassword(String email) async {
    try {
      await _client.auth.resetPasswordForEmail(
        email.trim().toLowerCase(),
        redirectTo: _getRedirectUrl(),
      );
    } catch (e) {
      throw AppAuthException(message: 'Failed to send reset email. Please try again.');
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
      return 'invalid-credentials';
    }
    if (lower.contains('email not confirmed')) {
      return 'email-not-confirmed';
    }
    if (lower.contains('user already registered') || lower.contains('already registered')) {
      return 'user-already-exists';
    }
    if (lower.contains('rate limit') || lower.contains('too many requests')) {
      return 'rate-limit-exceeded';
    }
    if (lower.contains('network') || lower.contains('timeout')) {
      return 'network-error';
    }
    if (lower.contains('oauth')) {
      return 'oauth-error';
    }
    return message;
  }
}
