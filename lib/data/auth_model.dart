import 'package:flutter/foundation.dart';

/// Lightweight local authentication model for the MVP.
///
/// This gives the app a real login/register flow without requiring
/// Firebase, Supabase, or a custom backend yet. It is intentionally
/// simple and should be replaced with secure authentication before launch.
class AuthModel extends ChangeNotifier {
  String? _name;
  String? _email;
  String? _password;
  bool _isLoggedIn = false;

  String? get name => _name;
  String? get email => _email;
  bool get isLoggedIn => _isLoggedIn;
  bool get hasAccount => _email != null && _password != null;

  /// Creates a local demo account and signs the user in.
  bool register({
    required String name,
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();
    final trimmedName = name.trim();

    if (trimmedName.isEmpty || normalizedEmail.isEmpty || password.length < 6) {
      return false;
    }

    _name = trimmedName;
    _email = normalizedEmail;
    _password = password;
    _isLoggedIn = true;
    notifyListeners();
    return true;
  }

  /// Signs in with the local demo account.
  bool login({
    required String email,
    required String password,
  }) {
    final normalizedEmail = email.trim().toLowerCase();

    if (_email == normalizedEmail && _password == password) {
      _isLoggedIn = true;
      notifyListeners();
      return true;
    }

    return false;
  }

  /// Demo helper so first-time users can enter the app quickly.
  void continueAsGuest() {
    _name = 'Guest';
    _email = null;
    _isLoggedIn = true;
    notifyListeners();
  }

  void logout() {
    _isLoggedIn = false;
    notifyListeners();
  }
}
