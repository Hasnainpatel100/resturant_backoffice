import 'package:equatable/equatable.dart';

// ✅ NO CHANGE: Enum is correct and complete
enum TableStatus { available, occupied, reserved, blocked }

class TableModel extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String roomTypeId;
  final String tableNumber;
  final String displayName;
  final int capacity;
  final String? description;
  final String status;
  final bool isActive;
  final String? currentOrderId;
  final String? positionX;
  final String? positionY;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const TableModel({
    required this.id,
    required this.brandId,
    required this.branchId,
    required this.roomTypeId,
    required this.tableNumber,
    this.displayName = '',
    this.capacity = 0,
    this.description,
    this.status = 'available',
    this.isActive = true,
    this.currentOrderId,
    this.positionX,
    this.positionY,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  // ✅ FIX: Added safe cast for 'capacity' field.
  // API can return capacity as num (int or double). Using (json['capacity'] as num?)?.toInt()
  // prevents a runtime type-cast crash when the server returns e.g. 4.0 instead of 4.
  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      roomTypeId: json['roomTypeId'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      displayName: json['displayName'] as String? ?? '',
      capacity: (json['capacity'] as num?)?.toInt() ?? 0,   // ✅ FIXED: safe num cast
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'available',
      isActive: json['isActive'] as bool? ?? true,
      currentOrderId: json['currentOrderId'] as String?,
      positionX: json['positionX'] as String?,
      positionY: json['positionY'] as String?,
      createdAt: (json['createdAt'] as num?)?.toInt() ?? 0, // ✅ FIXED: safe num cast
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: (json['updatedAt'] as num?)?.toInt(),      // ✅ FIXED: safe num cast
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brandId': brandId,
    'branchId': branchId,
    'roomTypeId': roomTypeId,
    'tableNumber': tableNumber,
    'displayName': displayName,
    'capacity': capacity,
    'description': description,
    'status': status,
    'isActive': isActive,
    'currentOrderId': currentOrderId,
    'positionX': positionX,
    'positionY': positionY,
    'createdAt': createdAt,
    'createdBy': createdBy,
    'updatedAt': updatedAt,
    'updatedBy': updatedBy,
  };

  // ✅ NO CHANGE: Getters are correct
  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';
  bool get isBlocked => status == 'blocked';

  TableStatus get tableStatus {
    switch (status) {
      case 'occupied':
        return TableStatus.occupied;
      case 'reserved':
        return TableStatus.reserved;
      case 'blocked':
        return TableStatus.blocked;
      default:
        return TableStatus.available;
    }
  }

  @override
  List<Object?> get props => [id, branchId, roomTypeId, tableNumber, capacity, status];
}
