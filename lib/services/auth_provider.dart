import 'package:flutter/foundation.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:bcrypt/bcrypt.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final _supabase = Supabase.instance.client;

  AppUser? _currentUser;
  bool _isLoading = false;
  bool _isInitializing = true;
  String? _error;

  AppUser? get currentUser => _currentUser;
  bool get isLoading => _isLoading;
  bool get isInitializing => _isInitializing;
  bool get isLoggedIn => _currentUser != null;
  String? get error => _error;

  Future<void> tryAutoLogin() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final savedEmail = prefs.getString('saved_email');
      if (savedEmail == null) {
        _isInitializing = false;
        notifyListeners();
        return;
      }

      final response = await _supabase
          .from('users')
          .select()
          .eq('email', savedEmail)
          .single();

      _currentUser = AppUser.fromJson(response);
    } catch (_) {
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('saved_email');
    } finally {
      _isInitializing = false;
      notifyListeners();
    }
  }

  Future<bool> signUp(String name, String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final hashedPassword = BCrypt.hashpw(password, BCrypt.gensalt());
      final response = await _supabase.from('users').insert({
        'name': name,
        'email': email,
        'password': hashedPassword,
        'phone_number': null,
        'home_address': null,
      }).select().single();

      _currentUser = AppUser.fromJson(response);
      await _saveSession(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<bool> signIn(String email, String password) async {
    _isLoading = true;
    _error = null;
    notifyListeners();

    try {
      final response = await _supabase
          .from('users')
          .select()
          .eq('email', email)
          .single();

      final storedHash = response['password'] as String;
      if (!BCrypt.checkpw(password, storedHash)) {
        throw Exception('Invalid password');
      }

      _currentUser = AppUser.fromJson(response);
      await _saveSession(email);
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _error = 'Invalid email or password';
      _isLoading = false;
      notifyListeners();
      return false;
    }
  }

  Future<void> signOut() async {
    _currentUser = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('saved_email');
    notifyListeners();
  }

  Future<bool> updateProfile({
    String? name,
    String? profilePic,
    String? phoneNumber,
    String? homeAddress,
  }) async {
    if (_currentUser == null) return false;

    try {
      final kathmanduNow = DateTime.now()
          .toUtc()
          .add(const Duration(hours: 5, minutes: 45));
      final updates = <String, dynamic>{
        'updated_at': kathmanduNow.toIso8601String(),
      };
      if (name != null) updates['name'] = name;
      if (profilePic != null) updates['profile_pic'] = profilePic;
      if (phoneNumber != null) updates['phone_number'] = phoneNumber;
      if (homeAddress != null) updates['home_address'] = homeAddress;

      await _supabase.from('users').update(updates).eq('id', _currentUser!.id);

      _currentUser = _currentUser!.copyWith(
        name: name,
        profilePic: profilePic,
        phoneNumber: phoneNumber,
        homeAddress: homeAddress,
        updatedAt: kathmanduNow,
      );
      notifyListeners();
      return true;
    } catch (e) {
      _error = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<void> _saveSession(String email) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString('saved_email', email);
  }

  void clearError() {
    _error = null;
    notifyListeners();
  }
}
