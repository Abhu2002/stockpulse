import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../models/user_profile.dart';

class SessionService {
  static const _isLoggedInKey = 'isLoggedIn';
  static const _profileKey = 'profile';

  Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getBool(_isLoggedInKey) ?? false;
  }

  Future<UserProfile> loadProfile() async {
    final prefs = await SharedPreferences.getInstance();
    final rawProfile = prefs.getString(_profileKey);
    if (rawProfile == null) return UserProfile.demo;
    return UserProfile.fromJson(jsonDecode(rawProfile) as Map<String, dynamic>);
  }

  Future<UserProfile> login({
    required String email,
    required String password,
  }) async {
    await Future<void>.delayed(const Duration(milliseconds: 800));
    if (password.toLowerCase() == 'fail123') {
      throw const AuthException('Login failed. Please check your credentials.');
    }

    final existingProfile = await loadProfile();
    final profile = existingProfile.copyWith(email: email.trim());
    await saveSession(profile);
    return profile;
  }

  Future<void> saveSession(UserProfile profile) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, true);
    await prefs.setString(_profileKey, jsonEncode(profile.toJson()));
  }

  Future<void> logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool(_isLoggedInKey, false);
  }
}

class AuthException implements Exception {
  const AuthException(this.message);

  final String message;
}
