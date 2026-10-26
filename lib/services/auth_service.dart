import 'package:flutter/foundation.dart';
import '../models/profile_model.dart';
import 'supabase_service.dart';

class AuthService {
  static final AuthService instance = AuthService._internal();
  AuthService._internal();

  ProfileModel? _currentProfile;
  ProfileModel? get currentProfile => _currentProfile;

  // Demo accounts for fast testing & presentation
  final List<ProfileModel> _demoStaffList = [
    ProfileModel(
      id: 'admin_1',
      fullName: 'Ronald (Owner)',
      role: 'admin',
      email: 'admin@coffi.com',
      phone: '081234567890',
      isActive: true,
    ),
    ProfileModel(
      id: 'kasir_1',
      fullName: 'Siti Rahma',
      role: 'kasir',
      email: 'kasir@coffi.com',
      phone: '081234567891',
      isActive: true,
    ),
    ProfileModel(
      id: 'dapur_1',
      fullName: 'Budi Santoso (Barista)',
      role: 'dapur',
      email: 'dapur@coffi.com',
      phone: '081234567892',
      isActive: true,
    ),
    ProfileModel(
      id: 'user_1',
      fullName: 'Aviona (Pelanggan)',
      role: 'user',
      email: 'user@coffi.com',
      phone: '081298765432',
      isActive: true,
    ),
  ];

  List<ProfileModel> get demoStaffList => List.unmodifiable(_demoStaffList);

  void addOrUpdateStaff({
    required String fullName,
    required String role,
    required String email,
  }) {
    final lower = email.toLowerCase();
    final existingIndex =
        _demoStaffList.indexWhere((s) => s.email?.toLowerCase() == lower);
    if (existingIndex != -1) {
      _demoStaffList[existingIndex] = _demoStaffList[existingIndex].copyWith(
        fullName: fullName,
        role: role,
        email: email,
      );
    } else {
      _demoStaffList.add(
        ProfileModel(
          id: 'staff_${DateTime.now().millisecondsSinceEpoch}',
          fullName: fullName,
          role: role,
          email: email,
          isActive: true,
        ),
      );
    }
  }

  /// Login via Supabase Auth (Email & Password)
  Future<ProfileModel?> signInWithEmail({
    required String email,
    required String password,
  }) async {
    final sb = SupabaseService.instance;
    if (sb.isConnected) {
      try {
        final res = await sb.client.auth.signInWithPassword(
          email: email,
          password: password,
        );
        if (res.user != null) {
          final profileData = await sb.client
              .from('profiles')
              .select()
              .eq('id', res.user!.id)
              .maybeSingle();

          if (profileData != null) {
            _currentProfile = ProfileModel.fromMap(profileData);
            return _currentProfile;
          } else {
            // Default profile from metadata
            _currentProfile = ProfileModel(
              id: res.user!.id,
              fullName: res.user!.userMetadata?['full_name'] ?? email,
              role: res.user!.userMetadata?['role'] ?? 'admin',
            );
            return _currentProfile;
          }
        }
      } catch (e) {
        debugPrint('Auth signInWithEmail error: $e');
        rethrow;
      }
    }

    // Demo email login fallback: match registered demo staff by email
    final lower = email.toLowerCase();
    final matched = _demoStaffList
        .where((u) => u.isActive && u.email?.toLowerCase() == lower)
        .toList();
    if (matched.isNotEmpty) {
      _currentProfile = matched.first;
      return _currentProfile;
    }

    // Otherwise pick role by keyword in the email
    if (lower.contains('admin')) {
      _currentProfile = _demoStaffList[0];
    } else if (lower.contains('dapur') || lower.contains('barista')) {
      _currentProfile = _demoStaffList[2];
    } else if (lower.contains('user') || lower.contains('pelanggan') || lower.contains('customer')) {
      _currentProfile = _demoStaffList[3];
    } else {
      _currentProfile = _demoStaffList[1];
    }
    return _currentProfile;
  }


  /// Admin: Fetch all staff profiles
  Future<List<ProfileModel>> fetchStaffList() async {
    final sb = SupabaseService.instance;
    if (sb.isConnected) {
      try {
        final data = await sb.client.from('profiles').select().order('full_name');
        return (data as List).map((e) => ProfileModel.fromMap(e)).toList();
      } catch (e) {
        debugPrint('Error fetchStaffList: $e');
      }
    }
    return List.from(_demoStaffList);
  }

  /// Admin: Add or update staff
  Future<bool> saveStaff(ProfileModel staff) async {
    final sb = SupabaseService.instance;
    if (sb.isConnected) {
      try {
        await sb.client.from('profiles').upsert(staff.toMap());
        return true;
      } catch (e) {
        debugPrint('Error saveStaff: $e');
      }
    }

    final index = _demoStaffList.indexWhere((s) => s.id == staff.id);
    if (index != -1) {
      _demoStaffList[index] = staff;
    } else {
      _demoStaffList.add(staff);
    }
    return true;
  }

  Future<void> signOut() async {
    final sb = SupabaseService.instance;
    if (sb.isConnected) {
      try {
        await sb.client.auth.signOut();
      } catch (_) {}
    }
    _currentProfile = null;
  }
}
