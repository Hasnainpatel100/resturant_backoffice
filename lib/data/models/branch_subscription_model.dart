import 'package:equatable/equatable.dart';

/// Subscription status values stored in the `branch_subscriptions` collection.
enum SubscriptionStatus { active, expired, cancelled, pending, trial }

/// Represents a branch's active or historical plan subscription.
/// Stored in the `branch_subscriptions` MongoDB collection.
class BranchSubscriptionModel extends Equatable {
  final String id;
  final String branchId;
  final String brandId;
  final String planId;
  final String planName;
  final int startAt;
  final int expiryAt;
  final bool autoRenew;
  final SubscriptionStatus status;
  final String assignedBy;
  final int assignedAt;
  final String note;

  const BranchSubscriptionModel({
    required this.id,
    required this.branchId,
    required this.brandId,
    required this.planId,
    this.planName = '',
    required this.startAt,
    required this.expiryAt,
    this.autoRenew = false,
    this.status = SubscriptionStatus.active,
    this.assignedBy = '',
    required this.assignedAt,
    this.note = '',
  });

  // ── Computed getters ──────────────────────────────────────────────────────

  bool get isExpired =>
      expiryAt > 0 &&
      DateTime.now().isAfter(DateTime.fromMillisecondsSinceEpoch(expiryAt));

  int get remainingDays {
    if (expiryAt <= 0) return 0;
    final expiry = DateTime.fromMillisecondsSinceEpoch(expiryAt);
    final now = DateTime.now();
    if (now.isAfter(expiry)) return 0;
    return expiry.difference(now).inDays;
  }

  bool get isActive => status == SubscriptionStatus.active && !isExpired;

  DateTime get startDate => DateTime.fromMillisecondsSinceEpoch(startAt);
  DateTime get expiryDate => DateTime.fromMillisecondsSinceEpoch(expiryAt);
  DateTime get assignedDate => DateTime.fromMillisecondsSinceEpoch(assignedAt);

  // ── Serialization ─────────────────────────────────────────────────────────

  factory BranchSubscriptionModel.fromJson(Map<String, dynamic> json) {
    return BranchSubscriptionModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      branchId: json['branchId'] as String? ?? '',
      brandId: json['brandId'] as String? ?? '',
      planId: json['planId'] as String? ?? '',
      planName: json['planName'] as String? ?? '',
      startAt: json['startAt'] as int? ?? 0,
      expiryAt: json['expiryAt'] as int? ?? 0,
      autoRenew: json['autoRenew'] as bool? ?? false,
      status: SubscriptionStatus.values.firstWhere(
        (e) => e.name == (json['status'] as String? ?? 'active'),
        orElse: () => SubscriptionStatus.active,
      ),
      assignedBy: json['assignedBy'] as String? ?? '',
      assignedAt: json['assignedAt'] as int? ?? 0,
      note: json['note'] as String? ?? '',
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'branchId': branchId,
        'brandId': brandId,
        'planId': planId,
        'planName': planName,
        'startAt': startAt,
        'expiryAt': expiryAt,
        'autoRenew': autoRenew,
        'status': status.name,
        'assignedBy': assignedBy,
        'assignedAt': assignedAt,
        'note': note,
      };

  BranchSubscriptionModel copyWith({
    String? id,
    String? branchId,
    String? brandId,
    String? planId,
    String? planName,
    int? startAt,
    int? expiryAt,
    bool? autoRenew,
    SubscriptionStatus? status,
    String? assignedBy,
    int? assignedAt,
    String? note,
  }) {
    return BranchSubscriptionModel(
      id: id ?? this.id,
      branchId: branchId ?? this.branchId,
      brandId: brandId ?? this.brandId,
      planId: planId ?? this.planId,
      planName: planName ?? this.planName,
      startAt: startAt ?? this.startAt,
      expiryAt: expiryAt ?? this.expiryAt,
      autoRenew: autoRenew ?? this.autoRenew,
      status: status ?? this.status,
      assignedBy: assignedBy ?? this.assignedBy,
      assignedAt: assignedAt ?? this.assignedAt,
      note: note ?? this.note,
    );
  }

  @override
  List<Object?> get props => [
        id,
        branchId,
        brandId,
        planId,
        planName,
        startAt,
        expiryAt,
        autoRenew,
        status,
        assignedBy,
        assignedAt,
        note,
      ];
}
