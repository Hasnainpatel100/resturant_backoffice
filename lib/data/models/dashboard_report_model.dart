import 'package:equatable/equatable.dart';

class DashboardReportModel extends Equatable {
  final DashboardSummaryModel summary;
  final List<DashboardPaymentModeModel> paymentModes;
  final List<DashboardServiceTypeModel> serviceTypes;
  final List<DashboardHourlySaleModel> hourlySales;
  final List<dynamic> topWaiters;
  final List<DashboardTopItemModel> topItems;
  final List<DashboardDayWiseModel> dayWise;
  final DashboardTaxReportModel taxReport;
  final DashboardDiscountReportModel discountReport;
  final DashboardCancellationReportModel cancellationReport;

  const DashboardReportModel({
    required this.summary,
    required this.paymentModes,
    required this.serviceTypes,
    required this.hourlySales,
    required this.topWaiters,
    required this.topItems,
    required this.dayWise,
    required this.taxReport,
    required this.discountReport,
    required this.cancellationReport,
  });

  factory DashboardReportModel.fromJson(Map<String, dynamic> json) {
    return DashboardReportModel(
      summary: DashboardSummaryModel.fromJson(json['summary'] as Map<String, dynamic>? ?? {}),
      paymentModes: (json['paymentModes'] as List<dynamic>? ?? [])
          .map((e) => DashboardPaymentModeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      serviceTypes: (json['serviceTypes'] as List<dynamic>? ?? [])
          .map((e) => DashboardServiceTypeModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      hourlySales: (json['hourlySales'] as List<dynamic>? ?? [])
          .map((e) => DashboardHourlySaleModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      topWaiters: json['topWaiters'] as List<dynamic>? ?? [],
      topItems: (json['topItems'] as List<dynamic>? ?? [])
          .map((e) => DashboardTopItemModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      dayWise: (json['dayWise'] as List<dynamic>? ?? [])
          .map((e) => DashboardDayWiseModel.fromJson(e as Map<String, dynamic>))
          .toList(),
      taxReport: DashboardTaxReportModel.fromJson(json['taxReport'] as Map<String, dynamic>? ?? {}),
      discountReport: DashboardDiscountReportModel.fromJson(json['discountReport'] as Map<String, dynamic>? ?? {}),
      cancellationReport: DashboardCancellationReportModel.fromJson(json['cancellationReport'] as Map<String, dynamic>? ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        summary,
        paymentModes,
        serviceTypes,
        hourlySales,
        topWaiters,
        topItems,
        dayWise,
        taxReport,
        discountReport,
        cancellationReport,
      ];
}

class DashboardSummaryModel extends Equatable {
  final int totalBills;
  final double totalRevenue;
  final double avgOrderValue;
  final double collectionPercent;
  final double totalAmount;
  final double amountCollected;
  final double outstandingAmount;
  final double totalDiscount;
  final double totalCgst;
  final double totalSgst;
  final double totalIgst;

  const DashboardSummaryModel({
    required this.totalBills,
    required this.totalRevenue,
    required this.avgOrderValue,
    required this.collectionPercent,
    required this.totalAmount,
    required this.amountCollected,
    required this.outstandingAmount,
    required this.totalDiscount,
    required this.totalCgst,
    required this.totalSgst,
    required this.totalIgst,
  });

  factory DashboardSummaryModel.fromJson(Map<String, dynamic> json) {
    double parseDouble(dynamic value) {
      if (value == null) return 0.0;
      if (value is num) return value.toDouble();
      return double.tryParse(value.toString()) ?? 0.0;
    }

    return DashboardSummaryModel(
      totalBills: json['totalBills'] as int? ?? 0,
      totalRevenue: parseDouble(json['totalRevenue']),
      avgOrderValue: parseDouble(json['avgOrderValue']),
      collectionPercent: parseDouble(json['collectionPercent']),
      totalAmount: parseDouble(json['totalAmount']),
      amountCollected: parseDouble(json['amountCollected']),
      outstandingAmount: parseDouble(json['outstandingAmount']),
      totalDiscount: parseDouble(json['totalDiscount']),
      totalCgst: parseDouble(json['totalCgst']),
      totalSgst: parseDouble(json['totalSgst']),
      totalIgst: parseDouble(json['totalIgst']),
    );
  }

  @override
  List<Object?> get props => [
        totalBills,
        totalRevenue,
        avgOrderValue,
        collectionPercent,
        totalAmount,
        amountCollected,
        outstandingAmount,
        totalDiscount,
        totalCgst,
        totalSgst,
        totalIgst,
      ];
}

class DashboardPaymentModeModel extends Equatable {
  final String mode;
  final int count;
  final double amount;

  const DashboardPaymentModeModel({
    required this.mode,
    required this.count,
    required this.amount,
  });

  factory DashboardPaymentModeModel.fromJson(Map<String, dynamic> json) {
    return DashboardPaymentModeModel(
      mode: json['mode'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [mode, count, amount];
}

class DashboardServiceTypeModel extends Equatable {
  final String type;
  final int count;
  final double amount;

  const DashboardServiceTypeModel({
    required this.type,
    required this.count,
    required this.amount,
  });

  factory DashboardServiceTypeModel.fromJson(Map<String, dynamic> json) {
    return DashboardServiceTypeModel(
      type: json['type'] as String? ?? 'Unknown',
      count: json['count'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [type, count, amount];
}

class DashboardHourlySaleModel extends Equatable {
  final int hour;
  final int count;
  final double amount;

  const DashboardHourlySaleModel({
    required this.hour,
    required this.count,
    required this.amount,
  });

  factory DashboardHourlySaleModel.fromJson(Map<String, dynamic> json) {
    return DashboardHourlySaleModel(
      hour: json['hour'] as int? ?? 0,
      count: json['count'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [hour, count, amount];
}

class DashboardTopItemModel extends Equatable {
  final String name;
  final String category;
  final int quantity;
  final double amount;

  const DashboardTopItemModel({
    required this.name,
    required this.category,
    required this.quantity,
    required this.amount,
  });

  factory DashboardTopItemModel.fromJson(Map<String, dynamic> json) {
    return DashboardTopItemModel(
      name: json['name'] as String? ?? 'Unknown',
      category: json['category'] as String? ?? '',
      quantity: json['quantity'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [name, category, quantity, amount];
}

class DashboardDayWiseModel extends Equatable {
  final String day;
  final int count;
  final double amount;

  const DashboardDayWiseModel({
    required this.day,
    required this.count,
    required this.amount,
  });

  factory DashboardDayWiseModel.fromJson(Map<String, dynamic> json) {
    return DashboardDayWiseModel(
      day: json['day'] as String? ?? '',
      count: json['count'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [day, count, amount];
}

class DashboardTaxReportModel extends Equatable {
  final double cgst;
  final double sgst;
  final double igst;
  final double total;

  const DashboardTaxReportModel({
    required this.cgst,
    required this.sgst,
    required this.igst,
    required this.total,
  });

  factory DashboardTaxReportModel.fromJson(Map<String, dynamic> json) {
    return DashboardTaxReportModel(
      cgst: (json['cgst'] as num? ?? 0.0).toDouble(),
      sgst: (json['sgst'] as num? ?? 0.0).toDouble(),
      igst: (json['igst'] as num? ?? 0.0).toDouble(),
      total: (json['total'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [cgst, sgst, igst, total];
}

class DashboardDiscountReportModel extends Equatable {
  final double total;
  final Map<String, double> byReason;

  const DashboardDiscountReportModel({
    required this.total,
    required this.byReason,
  });

  factory DashboardDiscountReportModel.fromJson(Map<String, dynamic> json) {
    final rawByReason = json['byReason'] as Map<String, dynamic>? ?? {};
    final byReasonMap = <String, double>{};
    rawByReason.forEach((key, value) {
      byReasonMap[key] = (value as num? ?? 0.0).toDouble();
    });

    return DashboardDiscountReportModel(
      total: (json['total'] as num? ?? 0.0).toDouble(),
      byReason: byReasonMap,
    );
  }

  @override
  List<Object?> get props => [total, byReason];
}

class DashboardCancellationReportModel extends Equatable {
  final int count;
  final double amount;
  final double rate;

  const DashboardCancellationReportModel({
    required this.count,
    required this.amount,
    required this.rate,
  });

  factory DashboardCancellationReportModel.fromJson(Map<String, dynamic> json) {
    return DashboardCancellationReportModel(
      count: json['count'] as int? ?? 0,
      amount: (json['amount'] as num? ?? 0.0).toDouble(),
      rate: (json['rate'] as num? ?? 0.0).toDouble(),
    );
  }

  @override
  List<Object?> get props => [count, amount, rate];
}
