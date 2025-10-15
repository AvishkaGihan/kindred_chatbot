import 'package:flutter/foundation.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../services/auth_service.dart';
import '../services/analytics_service.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  final AnalyticsService _analytics = AnalyticsService();
  User? _user;
  bool _isLoading = false;
  String? _errorMessage;

  User? get user => _user;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  AuthProvider() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  // Sign in with email
  Future<bool> signInWithEmail(String email, String password) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signInWithEmail(email, password);
      await _analytics.logLogin('email');
      if (_user != null) {
        await _analytics.setUserId(_user!.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      await _analytics.recordError(e, StackTrace.current);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Register with email
  Future<bool> registerWithEmail(
    String email,
    String password,
    String displayName,
  ) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.registerWithEmail(email, password, displayName);
      await _analytics.logSignUp('email');
      if (_user != null) {
        await _analytics.setUserId(_user!.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      await _analytics.recordError(e, StackTrace.current);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign in with Google
  Future<bool> signInWithGoogle() async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.signInWithGoogle();
      await _analytics.logLogin('google');
      if (_user != null) {
        await _analytics.setUserId(_user!.uid);
      }
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      await _analytics.recordError(e, StackTrace.current);
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  // Sign out
  Future<void> signOut() async {
    _setLoading(true);
    await _authService.signOut();
    _user = null;
    _setLoading(false);
    notifyListeners();
  }

  // Reset password
  Future<bool> resetPassword(String email) async {
    _setLoading(true);
    _errorMessage = null;

    try {
      await _authService.resetPassword(email);
      _setLoading(false);
      return true;
    } catch (e) {
      _errorMessage = e.toString();
      _setLoading(false);
      notifyListeners();
      return false;
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }
}
