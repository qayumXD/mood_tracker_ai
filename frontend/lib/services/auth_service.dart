import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/user_model.dart';

class AuthService {
  static final AuthService _instance = AuthService._internal();
  factory AuthService() => _instance;
  AuthService._internal();

  static const String _tokenKey = 'auth_token';
  static const String _userKey = 'user_data';

  late SharedPreferences _prefs;
  User? _currentUser;

  Future<void> init() async {
    _prefs = await SharedPreferences.getInstance();
    _loadUserFromCache();
  }

  void _loadUserFromCache() {
    final userJson = _prefs.getString(_userKey);
    if (userJson != null && userJson.isNotEmpty) {
      try {
        final Map<String, dynamic> map =
            json.decode(userJson) as Map<String, dynamic>;
        _currentUser = User.fromJson(map);
      } catch (e) {
        _currentUser = null;
      }
    }
  }

  String? get token => _prefs.getString(_tokenKey);
  User? get currentUser => _currentUser;
  bool get isAuthenticated => token != null && _currentUser != null;

  Future<void> saveToken(String token) async {
    await _prefs.setString(_tokenKey, token);
  }

  Future<void> saveUser(User user) async {
    _currentUser = user;
    await _prefs.setString(_userKey, json.encode(user.toJson()));
  }

  Future<void> logout() async {
    _currentUser = null;
    await _prefs.remove(_tokenKey);
    await _prefs.remove(_userKey);
  }

  Future<void> clearCache() async {
    await _prefs.clear();
    _currentUser = null;
  }
}
