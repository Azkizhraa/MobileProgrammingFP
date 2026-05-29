import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService();
  User? _user;

  User? get user => _user;
  bool get isLoggedIn => _user != null;

  AuthProvider() {
    _initAuthState();
  }

  void _initAuthState() {
    _authService.authStateChanges.listen((User? user) {
      _user = user;
      notifyListeners();
    });
  }

  Future<void> signOut() async {
    await _authService.signOut();
  }
}
