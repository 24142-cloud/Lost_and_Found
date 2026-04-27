import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:lost_and_found/core/services/auth_service.dart';
import 'package:lost_and_found/models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();

  bool _isLoading = false;
  String? _errorMessage;
  UserModel? _appUser;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  UserModel? get appUser => _appUser;
  User? get firebaseUser => _authService.currentUser;
  bool get isLoggedIn => firebaseUser != null;

  Future<bool> register({
    required String name,
    required String email,
    required String password,
    String phone = '',
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.register(
        name: name,
        email: email,
        password: password,
        phone: phone,
      );
      _appUser = await _authService.getCurrentUserData();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Registration failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<bool> login({
    required String email,
    required String password,
  }) async {
    _setLoading(true);
    _clearError();

    try {
      await _authService.login(
        email: email,
        password: password,
      );
      _appUser = await _authService.getCurrentUserData();
      notifyListeners();
      return true;
    } on FirebaseAuthException catch (e) {
      _errorMessage = e.message ?? 'Login failed';
      notifyListeners();
      return false;
    } catch (e) {
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    } finally {
      _setLoading(false);
    }
  }

  Future<void> loadCurrentUser() async {
    _setLoading(true);
    try {
      _appUser = await _authService.getCurrentUserData();
      notifyListeners();
    } catch (_) {
      // تجاهل مؤقتًا
    } finally {
      _setLoading(false);
    }
  }

  Future<void> logout() async {
    _setLoading(true);
    try {
      await _authService.logout();
      _appUser = null;
      notifyListeners();
    } finally {
      _setLoading(false);
    }
  }

  void _setLoading(bool value) {
    _isLoading = value;
    notifyListeners();
  }

  void _clearError() {
    _errorMessage = null;
  }
}