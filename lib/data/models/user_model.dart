import 'package:equatable/equatable.dart';

class AppUser extends Equatable {
  final String id;
  final String email;
  final String? name;
  final String? photoUrl;
  final String brandId;
  final String branchId;
  final String role;
  final String userType;
  final List<String> permissions;

  const AppUser({
    required this.id,
    required this.email,
    this.name,
    this.photoUrl,
    this.brandId = '',
    this.branchId = '',
    this.role = '',
    this.userType = '',
    this.permissions = const [],
  });

  factory AppUser.empty() => const AppUser(id: '', email: '');

  bool get isEmpty => id.isEmpty;
  bool get isNotEmpty => id.isNotEmpty;

  bool get isAdmin => role == 'ADMIN' || role == 'SUPER_ADMIN';
  bool get isSupport => role == 'SUPPORT_TEAM';
  bool get isOwner => role == 'OWNER';
  bool get isPlatformUser => userType == 'PLATFORM';

  String get fullName {
    if (name != null && name!.isNotEmpty) return name!;
    return email;
  }

  AppUser copyWith({
    String? id,
    String? email,
    String? name,
    String? photoUrl,
    String? brandId,
    String? branchId,
    String? role,
    String? userType,
    List<String>? permissions,
  }) {
    return AppUser(
      id: id ?? this.id,
      email: email ?? this.email,
      name: name ?? this.name,
      photoUrl: photoUrl ?? this.photoUrl,
      brandId: brandId ?? this.brandId,
      branchId: branchId ?? this.branchId,
      role: role ?? this.role,
      userType: userType ?? this.userType,
      permissions: permissions ?? this.permissions,
    );
  }

  @override
  List<Object?> get props => [id, email, name, photoUrl, brandId, branchId, role, userType, permissions];
}
