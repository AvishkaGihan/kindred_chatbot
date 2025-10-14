import 'package:flutter/foundation.dart';
import '../services/auth_service.dart';
import '../models/user_model.dart';

class AuthProvider with ChangeNotifier {
  final AuthService _authService = AuthService();
  UserModel? _user;
  bool _isLoading = false;
  bool _isInitializing = true;

  UserModel? get user => _user;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;

  AuthProvider() {
    _authService.user.listen((user) {
      if (_isInitializing) {
        _isInitializing = false;
      }
      _user = user;
      notifyListeners();
    });
  }

  Future<bool> signInWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.signInWithEmail(email, password);

    _isLoading = false;
    notifyListeners();

    return user != null;
  }

  Future<bool> signUpWithEmail(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    final user = await _authService.signUpWithEmail(email, password);

    _isLoading = false;
    notifyListeners();

    return user != null;
  }

  Future<bool> signInWithGoogle() async {
    final user = await _authService.signInWithGoogle();
    return user != null;
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
