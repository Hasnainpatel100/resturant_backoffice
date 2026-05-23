import 'package:equatable/equatable.dart';

class BranchPlanModel extends Equatable {
  final int maxUsers;
  final int maxPosDevices;
  final String expiryAt; // milliseconds as string
  final String note;
  final int? createdAt;
  final String? id;

  const BranchPlanModel({
    required this.maxUsers,
    required this.maxPosDevices,
    required this.expiryAt,
    required this.note,
    this.createdAt,
    this.id,
  });

  factory BranchPlanModel.fromJson(Map<String, dynamic> json) {
    return BranchPlanModel(
      maxUsers: json['maxUsers'] as int? ?? 0,
      maxPosDevices: json['maxPosDevices'] as int? ?? 0,
      expiryAt: json['expiryAt']?.toString() ?? '',
      note: json['note'] as String? ?? '',
      createdAt: json['createdAt'] as int?,
      id: json['id'] as String? ?? json['_id'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'maxUsers': maxUsers,
      'maxPosDevices': maxPosDevices,
      'expiryAt': expiryAt,
      'note': note,
    };
  }

  @override
  List<Object?> get props => [maxUsers, maxPosDevices, expiryAt, note, createdAt, id];
}
