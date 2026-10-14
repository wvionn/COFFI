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

  Future<bool> loginWithPin(String pin) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    try {
      final profile = await _authService.signInWithPin(pin);
      if (profile != null) {
        _currentProfile = profile;
        _isLoading = false;
        notifyListeners();
        return true;
      } else {
        _isLoading = false;
        _errorMessage = 'PIN tidak valid atau akun tidak aktif';
        notifyListeners();
        return false;
      }
    } catch (e) {
      _isLoading = false;
      _errorMessage = e.toString();
      notifyListeners();
      return false;
    }
  }

  void switchDemoUser(ProfileModel profile) {
    _currentProfile = profile;
    _authService.setSessionProfile(profile);
    notifyListeners();
  }

  void addStaff({
    required String fullName,
    required String role,
    required String pinCode,
  }) {
    _authService.addOrUpdateStaff(
      fullName: fullName,
      role: role,
      pinCode: pinCode,
    );
    notifyListeners();
  }

  Future<void> logout() async {
    await _authService.signOut();
    _currentProfile = null;
    notifyListeners();
  }
}
