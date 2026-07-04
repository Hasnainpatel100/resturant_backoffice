import 'package:mongo_dart/mongo_dart.dart' show ObjectId;

class LocationModel {
  final String id;
  final String? branchId;
  final String locationCode;
  final String locationName;
  final String locationType;
  final String? address;
  final String? contactNo;
  final String? managerName;
  final bool isActive;
  final DateTime createdAt;
  final DateTime? updatedAt;

  LocationModel({
    required this.id,
    this.branchId,
    required this.locationCode,
    required this.locationName,
    required this.locationType,
    this.address,
    this.contactNo,
    this.managerName,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory LocationModel.fromMap(Map<String, dynamic> map) {
    return LocationModel(
      id: map['_id'] is ObjectId
          ? (map['_id'] as ObjectId).toHexString()
          : map['id']?.toString() ?? map['_id']?.toString() ?? '',
      branchId: map['branch_id'] is ObjectId
          ? (map['branch_id'] as ObjectId).toHexString()
          : map['branch_id']?.toString(),
      locationCode: map['location_code']?.toString() ?? '',
      locationName: map['location_name']?.toString() ?? '',
      locationType: map['location_type']?.toString() ?? 'warehouse',
      address: map['address']?.toString(),
      contactNo: map['contact_no']?.toString(),
      managerName: map['manager_name']?.toString(),
      isActive: map['is_active'] as bool? ?? true,
      createdAt: map['created_at'] is DateTime
          ? map['created_at'] as DateTime
          : DateTime.tryParse(map['created_at']?.toString() ?? '') ?? DateTime.now(),
      updatedAt: map['updated_at'] is DateTime
          ? map['updated_at'] as DateTime
          : DateTime.tryParse(map['updated_at']?.toString() ?? ''),
    );
  }

  Map<String, dynamic> toMap() {
    final map = <String, dynamic>{
      'location_code': locationCode,
      'location_name': locationName,
      'location_type': locationType,
      'address': address,
      'contact_no': contactNo,
      'manager_name': managerName,
      'is_active': isActive,
      'created_at': createdAt,
      'updated_at': updatedAt,
    };
    if (id.isNotEmpty) {
      try {
        map['_id'] = ObjectId.fromHexString(id);
      } catch (_) {
        map['id'] = id;
      }
    }
    if (branchId != null && branchId!.isNotEmpty) {
      try {
        map['branch_id'] = ObjectId.fromHexString(branchId!);
      } catch (_) {
        map['branch_id'] = branchId;
      }
    } else {
      map['branch_id'] = null;
    }
    return map;
  }

  LocationModel copyWith({
    String? id,
    String? branchId,
    String? locationCode,
    String? locationName,
    String? locationType,
    String? address,
    String? contactNo,
    String? managerName,
    bool? isActive,
    DateTime? createdAt,
    DateTime? updatedAt,
  }) {
    return LocationModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      locationCode: locationCode ?? this.locationCode,
      locationName: locationName ?? this.locationName,
      locationType: locationType ?? this.locationType,
      address: address ?? this.address,
      contactNo: contactNo ?? this.contactNo,
      managerName: managerName ?? this.managerName,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  String get displayLabel => '$locationName ($locationCode)';
}
