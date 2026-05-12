import 'package:equatable/equatable.dart';

/// Available feature keys for plan access control.
abstract final class PlanFeatures {
  PlanFeatures._();

  static const String billing = 'billing';
  static const String inventory = 'inventory';
  static const String analytics = 'analytics';
  static const String multiBranch = 'multi_branch';
  static const String onlineOrders = 'online_orders';
  static const String reports = 'reports';
  static const String loyaltyProgram = 'loyalty_program';
  static const String tableMgmt = 'table_management';
  static const String staffMgmt = 'staff_management';
  static const String paymentGateway = 'payment_gateway';

  static const List<String> all = [
    billing,
    inventory,
    analytics,
    multiBranch,
    onlineOrders,
    reports,
    loyaltyProgram,
    tableMgmt,
    staffMgmt,
    paymentGateway,
  ];

  static String label(String key) {
    switch (key) {
      case billing:
        return 'Billing';
      case inventory:
        return 'Inventory';
      case analytics:
        return 'Analytics';
      case multiBranch:
        return 'Multi-Branch';
      case onlineOrders:
        return 'Online Orders';
      case reports:
        return 'Reports';
      case loyaltyProgram:
        return 'Loyalty Program';
      case tableMgmt:
        return 'Table Management';
      case staffMgmt:
        return 'Staff Management';
      case paymentGateway:
        return 'Payment Gateway';
      default:
        return key;
    }
  }
}

/// Represents a subscription plan (master plan) stored in the `plans` collection.
class PlanModel extends Equatable {
  final String id;
  final String name;
  final String description;
  final double monthlyPrice;
  final double yearlyPrice;
  final List<String> features;
  final int maxUsers;
  final int maxPosDevices;
  final int maxBranches;
  final bool isPopular;
  final bool isActive;
  final int createdAt;
  final int? updatedAt;

  const PlanModel({
    required this.id,
    required this.name,
    this.description = '',
    this.monthlyPrice = 0,
    this.yearlyPrice = 0,
    this.features = const [],
    this.maxUsers = 0,
    this.maxPosDevices = 0,
    this.maxBranches = 0,
    this.isPopular = false,
    this.isActive = true,
    required this.createdAt,
    this.updatedAt,
  });

  factory PlanModel.fromJson(Map<String, dynamic> json) {
    return PlanModel(
      id: json['id'] as String? ?? json['_id'] as String? ?? '',
      name: json['name'] as String? ?? '',
      description: json['description'] as String? ?? '',
      monthlyPrice: (json['monthlyPrice'] as num?)?.toDouble() ?? 0,
      yearlyPrice: (json['yearlyPrice'] as num?)?.toDouble() ?? 0,
      features: (json['features'] as List<dynamic>?)?.cast<String>() ?? [],
      maxUsers: json['maxUsers'] as int? ?? 0,
      maxPosDevices: json['maxPosDevices'] as int? ?? 0,
      maxBranches: json['maxBranches'] as int? ?? 0,
      isPopular: json['isPopular'] as bool? ?? false,
      isActive: json['isActive'] as bool? ?? true,
      createdAt: json['createdAt'] as int? ?? 0,
      updatedAt: json['updatedAt'] as int?,
    );
  }

  Map<String, dynamic> toJson() => {
        'id': id,
        'name': name,
        'description': description,
        'monthlyPrice': monthlyPrice,
        'yearlyPrice': yearlyPrice,
        'features': features,
        'maxUsers': maxUsers,
        'maxPosDevices': maxPosDevices,
        'maxBranches': maxBranches,
        'isPopular': isPopular,
        'isActive': isActive,
        'createdAt': createdAt,
        'updatedAt': updatedAt,
      };

  PlanModel copyWith({
    String? id,
    String? name,
    String? description,
    double? monthlyPrice,
    double? yearlyPrice,
    List<String>? features,
    int? maxUsers,
    int? maxPosDevices,
    int? maxBranches,
    bool? isPopular,
    bool? isActive,
    int? createdAt,
    int? updatedAt,
  }) {
    return PlanModel(
      id: id ?? this.id,
      name: name ?? this.name,
      description: description ?? this.description,
      monthlyPrice: monthlyPrice ?? this.monthlyPrice,
      yearlyPrice: yearlyPrice ?? this.yearlyPrice,
      features: features ?? this.features,
      maxUsers: maxUsers ?? this.maxUsers,
      maxPosDevices: maxPosDevices ?? this.maxPosDevices,
      maxBranches: maxBranches ?? this.maxBranches,
      isPopular: isPopular ?? this.isPopular,
      isActive: isActive ?? this.isActive,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
    );
  }

  bool hasFeature(String featureKey) => features.contains(featureKey);

  @override
  List<Object?> get props => [
        id,
        name,
        description,
        monthlyPrice,
        yearlyPrice,
        features,
        maxUsers,
        maxPosDevices,
        maxBranches,
        isPopular,
        isActive,
        createdAt,
        updatedAt,
      ];
}
