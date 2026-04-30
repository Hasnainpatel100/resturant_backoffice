import 'package:equatable/equatable.dart';

class RoomTypeModel extends Equatable {
  final String id;
  final String brandId;
  final String name;
  final String? description;
  final int minTables;
  final int maxTables;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const RoomTypeModel({
    required this.id,
    required this.brandId,
    required this.name,
    this.description,
    this.minTables = 0,
    this.maxTables = 0,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      minTables: json['minTables'] as int? ?? 0,
      maxTables: json['maxTables'] as int? ?? 0,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'brandId': brandId,
        'name': name,
        'description': description,
        'minTables': minTables,
        'maxTables': maxTables,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  @override
  List<Object?> get props => [id, brandId, name, minTables, maxTables];
}

enum TableStatus { available, occupied, reserved, blocked }

class TableModel extends Equatable {
  final String id;
  final String branchId;
  final String roomTypeId;
  final String tableNumber;
  final int capacity;
  final String? description;
  final String status;
  final String? currentOrderId;
  final String? positionX;
  final String? positionY;
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const TableModel({
    required this.id,
    required this.branchId,
    required this.roomTypeId,
    required this.tableNumber,
    this.capacity = 0,
    this.description,
    this.status = 'available',
    this.currentOrderId,
    this.positionX,
    this.positionY,
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory TableModel.fromJson(Map<String, dynamic> json) {
    return TableModel(
      id: json['id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      roomTypeId: json['roomTypeId'] as String? ?? '',
      tableNumber: json['tableNumber'] as String? ?? '',
      capacity: json['capacity'] as int? ?? 0,
      description: json['description'] as String?,
      status: json['status'] as String? ?? 'available',
      currentOrderId: json['currentOrderId'] as String?,
      positionX: json['positionX'] as String?,
      positionY: json['positionY'] as String?,
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        'roomTypeId': roomTypeId,
        'tableNumber': tableNumber,
        'capacity': capacity,
        'description': description,
        'status': status,
        'currentOrderId': currentOrderId,
        'positionX': positionX,
        'positionY': positionY,
        'createdAt': createdAt,
        'createdBy': createdBy,
        'updatedAt': updatedAt,
        'updatedBy': updatedBy,
      };

  bool get isAvailable => status == 'available';
  bool get isOccupied => status == 'occupied';
  bool get isReserved => status == 'reserved';
  bool get isBlocked => status == 'blocked';

  @override
  List<Object?> get props => [id, branchId, roomTypeId, tableNumber, capacity, status];
}
