import 'package:equatable/equatable.dart';

enum DeviceType { android, ios, web, desktop, pos }

enum DeviceStatus { active, inactive, pending, blocked }

class PosDeviceModel extends Equatable {
  final String id;
  final String branchId;
  final String brandId;
  final String deviceName;
  final String deviceId;
  final String deviceType;
  final String status;
  final String? lastSeenAt;
  final String? location;
  final String? notes;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const PosDeviceModel({
    required this.id,
    required this.branchId,
    required this.brandId,
    required this.deviceName,
    required this.deviceId,
    this.deviceType = 'pos',
    this.status = 'pending',
    this.lastSeenAt,
    this.location,
    this.notes,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory PosDeviceModel.fromJson(Map<String, dynamic> json) {
    return PosDeviceModel(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      deviceName: json['deviceName'] as String? ?? '',
      deviceId: json['deviceId'] as String? ?? '',
      deviceType: json['deviceType'] as String? ?? 'pos',
      status: json['status'] as String? ?? 'pending',
      lastSeenAt: json['lastSeenAt'] as String?,
      location: json['location'] as String?,
      notes: json['notes'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        'brandId': brandId,
        'deviceName': deviceName,
        'deviceId': deviceId,
        'deviceType': deviceType,
        'status': status,
        'lastSeenAt': lastSeenAt,
        'location': location,
        'notes': notes,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  bool get isActive => status == 'active';
  bool get isInactive => status == 'inactive';
  bool get isPending => status == 'pending';
  bool get isBlocked => status == 'blocked';

  @override
  List<Object?> get props => [id, branchId, brandId, deviceName, deviceId, status];
}
