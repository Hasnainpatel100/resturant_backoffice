import '../../imports/imports.dart';

class RoomTypeModel extends Equatable {
  final String id;
  final String brandId;
  final String branchId;
  final String name;
  final String? description;
  final bool isActive;
  final int displayOrder; // ✅ add this
  final int createdAt;
  final String createdBy;
  final int? updatedAt;
  final String? updatedBy;

  const RoomTypeModel({
    required this.id,
    required this.brandId,
    required this.branchId,
    required this.name,
    this.description,
    this.isActive = true,
    this.displayOrder = 0, // ✅ add this
    required this.createdAt,
    required this.createdBy,
    this.updatedAt,
    this.updatedBy,
  });

  factory RoomTypeModel.fromJson(Map<String, dynamic> json) {
    return RoomTypeModel(
      id: json['id'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String?,
      isActive: json['isActive'] as bool? ?? true,
      displayOrder: json['displayOrder'] as int? ?? 0, // ✅ add this
      createdAt: json['createdAt'] as int? ?? 0,
      createdBy: json['createdBy'] as String? ?? '',
      updatedAt: json['updatedAt'] as int?,
      updatedBy: json['updatedBy'] as String?,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'brandId': brandId,
    'branchId': branchId,
    'name': name,
    'description': description,
    'isActive': isActive,
    'displayOrder': displayOrder, // ✅ add this
    'createdAt': createdAt,
    'createdBy': createdBy,
    'updatedAt': updatedAt,
    'updatedBy': updatedBy,
  };

  @override
  List<Object?> get props => [id, brandId, branchId, name, isActive, displayOrder];
}