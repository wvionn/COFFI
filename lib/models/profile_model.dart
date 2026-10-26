class ProfileModel {
  final String id;
  final String fullName;
  final String role; // 'admin', 'kasir', 'dapur'
  final String? email;
  final String? phone;
  final bool isActive;

  ProfileModel({
    required this.id,
    required this.fullName,
    required this.role,
    this.email,
    this.phone,
    this.isActive = true,
  });

  bool get isAdmin => role == 'admin';
  bool get isKasir => role == 'kasir';
  bool get isDapur => role == 'dapur';
  bool get isUser => role == 'user' || role == 'customer' || role == 'pelanggan';

  factory ProfileModel.fromMap(Map<String, dynamic> map) {
    return ProfileModel(
      id: map['id']?.toString() ?? '',
      fullName: map['full_name']?.toString() ?? 'Staf',
      role: map['role']?.toString().toLowerCase() ?? 'kasir',
      email: map['email']?.toString(),
      phone: map['phone']?.toString(),
      isActive: map['is_active'] == null ? true : (map['is_active'] as bool),
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'full_name': fullName,
      'role': role,
      'phone': phone,
      'is_active': isActive,
    };
  }

  ProfileModel copyWith({
    String? id,
    String? fullName,
    String? role,
    String? email,
    String? phone,
    bool? isActive,
  }) {
    return ProfileModel(
      id: id ?? this.id,
      fullName: fullName ?? this.fullName,
      role: role ?? this.role,
      email: email ?? this.email,
      phone: phone ?? this.phone,
      isActive: isActive ?? this.isActive,
    );
  }
}
