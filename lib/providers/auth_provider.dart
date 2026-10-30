import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import '../services/auth_service.dart';

class AuthProvider extends ChangeNotifier {
  final AuthService _authService = AuthService.instance;

  ProfileModel? _currentProfile;
  bool _isLoading = false;
  String? _errorMessage;

  ProfileModel? get currentProfile => _currentProfile;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _currentProfile != null;

  List<ProfileModel> get demoStaff => _authService.demoStaffList;

  Future<bool> loginWithEmail(String email, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.signInWithEmail(email: email, password: password);
      _currentProfile = profile;
      _isLoading = false;
      notifyListeners();
      return profile != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> registerWithEmail({
    required String email,
    required String password,
    String? fullName,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.signUpWithEmail(
        email: email,
        password: password,
        fullName: fullName,
      );
      _currentProfile = profile;
      _isLoading = false;
      notifyListeners();
      return profile != null;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  Future<bool> loginAsGuest() async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.signInAsGuest();
      _currentProfile = profile;
      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void addStaff({
    required String fullName,
    required String role,
    required String email,
  }) {
    _authService.addOrUpdateStaff(
      fullName: fullName,
      role: role,
      email: email,
    );
    notifyListeners();
  }
  
  void deleteStaff(String staffId) {
    _authService.deleteStaff(staffId);
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentProfile = null;
    notifyListeners();
  }
}
