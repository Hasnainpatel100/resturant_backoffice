import 'package:equatable/equatable.dart';

class PhoneData extends Equatable {
  final String? countryCode;
  final String? number;
  final bool isVerified;

  const PhoneData({
    this.countryCode,
    this.number,
    this.isVerified = false,
  });

  factory PhoneData.fromJson(Map<String, dynamic> json) {
    return PhoneData(
      countryCode: json['countryCode'] as String?,
      number: json['number'] as String?,
      isVerified: json['isVerified'] as bool? ?? false,
    );
  }

  Map<String, dynamic> toJson() => {
        'countryCode': countryCode,
        'number': number,
        'isVerified': isVerified,
      };

  String get fullNumber => '${countryCode ?? ''}${number ?? ''}'.trim();

  @override
  List<Object?> get props => [countryCode, number, isVerified];
}

class AddressData extends Equatable {
  final String street;
  final String city;
  final String state;
  final String country;
  final String postalCode;
  final double latitude;
  final double longitude;
  final String gMapUrl;

  const AddressData({
    this.street = '',
    this.city = '',
    this.state = '',
    this.country = '',
    this.postalCode = '',
    this.latitude = 0.0,
    this.longitude = 0.0,
    this.gMapUrl = '',
  });

  factory AddressData.fromJson(Map<String, dynamic> json) {
    return AddressData(
      street: json['street'] as String? ?? '',
      city: json['city'] as String? ?? '',
      state: json['state'] as String? ?? '',
      country: json['country'] as String? ?? '',
      postalCode: json['postalCode'] as String? ?? '',
      latitude: (json['latitude'] as num?)?.toDouble() ?? 0.0,
      longitude: (json['longitude'] as num?)?.toDouble() ?? 0.0,
      gMapUrl: json['gMapUrl'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'street': street,
        'city': city,
        'state': state,
        'country': country,
        'postalCode': postalCode,
        'latitude': latitude,
        'longitude': longitude,
        'gMapUrl': gMapUrl,
      };

  String get fullAddress {
    final parts = [street, city, state, postalCode, country].where((p) => p.isNotEmpty);
    return parts.join(', ');
  }

  @override
  List<Object?> get props => [street, city, state, country, postalCode, latitude, longitude];
}

class EmergencyContactData extends Equatable {
  final String name;
  final String phone;
  final String relationship;

  const EmergencyContactData({
    this.name = '',
    this.phone = '',
    this.relationship = '',
  });

  factory EmergencyContactData.fromJson(Map<String, dynamic> json) {
    return EmergencyContactData(
      name: json['name'] as String? ?? '',
      phone: json['phone'] as String? ?? '',
      relationship: json['relationship'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'name': name,
        'phone': phone,
        'relationship': relationship,
      };

  @override
  List<Object?> get props => [name, phone, relationship];
}

class BankDetailsData extends Equatable {
  final String? bankName;
  final String? accountNumber;
  final String? ifscCode;
  final String? accountHolderName;
  final String? branchName;

  const BankDetailsData({
    this.bankName,
    this.accountNumber,
    this.ifscCode,
    this.accountHolderName,
    this.branchName,
  });

  factory BankDetailsData.fromJson(Map<String, dynamic> json) {
    return BankDetailsData(
      bankName: json['bankName'] as String?,
      accountNumber: json['accountNumber'] as String?,
      ifscCode: json['ifscCode'] as String?,
      accountHolderName: json['accountHolderName'] as String?,
      branchName: json['branchName'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'bankName': bankName,
        'accountNumber': accountNumber,
        'ifscCode': ifscCode,
        'accountHolderName': accountHolderName,
        'branchName': branchName,
      };

  @override
  List<Object?> get props => [bankName, accountNumber, ifscCode, accountHolderName, branchName];
}

class UserDetailsData extends Equatable {
  final String id;
  final String userId;
  final String brandId;
  final String firstName;
  final String lastName;
  final String? fatherName;
  final String? dateOfBirth;
  final String? gender;
  final PhoneData? phone;
  final String? email;
  final AddressData? address;
  final EmergencyContactData? emergencyContact;
  final String? designation;
  final String? department;
  final String? joinDate;
  final String? shift;
  final String? employeeId;
  final BankDetailsData? bankDetails;
  final int createdAt;
  final int? updatedAt;

  const UserDetailsData({
    required this.id,
    required this.userId,
    required this.brandId,
    required this.firstName,
    required this.lastName,
    this.fatherName,
    this.dateOfBirth,
    this.gender,
    this.phone,
    this.email,
    this.address,
    this.emergencyContact,
    this.designation,
    this.department,
    this.joinDate,
    this.shift,
    this.employeeId,
    this.bankDetails,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserDetailsData.fromJson(Map<String, dynamic> json) {
    return UserDetailsData(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      userId: json['userId'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      fatherName: json['fatherName'] as String?,
      dateOfBirth: json['dateOfBirth'] as String?,
      gender: json['gender'] as String?,
      phone: json['phone'] != null ? PhoneData.fromJson(json['phone']) : null,
      email: json['email'] as String?,
      address: json['address'] != null ? AddressData.fromJson(json['address']) : null,
      emergencyContact: json['emergencyContact'] != null ? EmergencyContactData.fromJson(json['emergencyContact']) : null,
      designation: json['designation'] as String?,
      department: json['department'] as String?,
      joinDate: json['joinDate'] as String?,
      shift: json['shift'] as String?,
      employeeId: json['employeeId'] as String?,
      bankDetails: json['bankDetails'] != null ? BankDetailsData.fromJson(json['bankDetails']) : null,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'userId': userId,
        'brandId': brandId,
        'firstName': firstName,
        'lastName': lastName,
        'fatherName': fatherName,
        'dateOfBirth': dateOfBirth,
        'gender': gender,
        'phone': phone?.toJson(),
        'email': email,
        'address': address?.toJson(),
        'emergencyContact': emergencyContact?.toJson(),
        'designation': designation,
        'department': department,
        'joinDate': joinDate,
        'shift': shift,
        'employeeId': employeeId,
        'bankDetails': bankDetails?.toJson(),
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  @override
  List<Object?> get props => [id, userId, brandId, firstName, lastName];
}

class UserData extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String firstName;
  final String lastName;
  final String username;
  final String email;
  final String phoneNumber;
  final String userType;
  final String role;
  final List<String> permissions;
  final bool isActive;
  final bool isLocked;
  final int failedLoginAttempts;
  final int? lastSeenAt;
  final int createdAt;
  final int? updatedAt;

  const UserData({
    required this.id,
    required this.brandId,
    required this.branchId,
    required this.firstName,
    required this.lastName,
    required this.username,
    required this.email,
    required this.phoneNumber,
    required this.userType,
    required this.role,
    this.permissions = const [],
    this.isActive = true,
    this.isLocked = false,
    this.failedLoginAttempts = 0,
    this.lastSeenAt,
    required this.createdAt,
    this.updatedAt,
  });

  factory UserData.fromJson(Map<String, dynamic> json) {
    return UserData(
      id: json['id'] as String? ?? json['_id'] as String? ?? json['userId'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      firstName: json['firstName'] as String? ?? '',
      lastName: json['lastName'] as String? ?? '',
      username: json['username'] as String? ?? '',
      email: json['email'] as String? ?? '',
      phoneNumber: json['phoneNumber'] as String? ?? '',
      userType: json['userType'] as String? ?? '',
      role: json['role'] as String? ?? '',
      permissions: (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
      isActive: json['isActive'] as bool? ?? true,
      isLocked: json['isLocked'] as bool? ?? false,
      failedLoginAttempts: json['failedLoginAttempts'] as int? ?? 0,
      lastSeenAt: json['lastSeenAt'] as int?,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'branchId': branchId,
        'firstName': firstName,
        'lastName': lastName,
        'username': username,
        'email': email,
        'phoneNumber': phoneNumber,
        'userType': userType,
        'role': role,
        'permissions': permissions,
        'isActive': isActive,
        'isLocked': isLocked,
        'failedLoginAttempts': failedLoginAttempts,
        'lastSeenAt': lastSeenAt,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  String get fullName => '$firstName $lastName'.trim();
  String get initials {
    final first = firstName.isNotEmpty ? firstName[0].toUpperCase() : '';
    final last = lastName.isNotEmpty ? lastName[0].toUpperCase() : '';
    return '$first$last';
  }

  @override
  List<Object?> get props => [id, brandId, branchId, firstName, lastName, username, email, role];
}

class UserProfileModel extends Equatable {
  final UserData user;
  final UserDetailsData? userDetails;
  final List<String> permissions;

  const UserProfileModel({
    required this.user,
    this.userDetails,
    this.permissions = const [],
  });

  factory UserProfileModel.fromJson(Map<String, dynamic> json) {
    return UserProfileModel(
      user: json['user'] != null ? UserData.fromJson(json['user']) : UserData.fromJson(json),
      userDetails: json['userDetails'] != null ? UserDetailsData.fromJson(json['userDetails']) : null,
      permissions: (json['permissions'] as List<dynamic>?)?.cast<String>() ?? [],
    );
  }

  String get displayName => user.fullName;
  String get initials => user.initials;

  @override
  List<Object?> get props => [user, userDetails, permissions];
}
