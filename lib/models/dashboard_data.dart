// lib/models/dashboard_data.dart

class DashboardOffer {
  final int saleId;
  final String saleName;
  final String? note;
  final String? startDate;
  final String? endDate;
  final String? targetTypeDesc;
  final String? promoTargetName;
  final String? coupon;
  final String? commonSale;
  final String? stores;

  DashboardOffer({
    required this.saleId,
    required this.saleName,
    this.note,
    this.startDate,
    this.endDate,
    this.targetTypeDesc,
    this.promoTargetName,
    this.coupon,
    this.commonSale,
    this.stores,
  });

  factory DashboardOffer.fromJson(Map<String, dynamic> json) {
    return DashboardOffer(
      saleId: json['sale_id'] ?? 0,
      saleName: json['salename'] ?? '',
      note: json['note'],
      startDate: json['startdate'],
      endDate: json['enddate'],
      targetTypeDesc: json['targettypedesc'],
      promoTargetName: json['promotargetname'],
      coupon: json['coupon'],
      commonSale: json['commonsale'],
      stores: json['stores'],
    );
  }
}

class DashboardTransaction {
  final String txnId;
  final double netPayable;
  final double taxTotal;
  final double subtotal;
  final double discount;
  final String txnDate;
  final double? previousPoints;
  final double? collectedPoint;
  final double? totalPoint;

  DashboardTransaction({
    required this.txnId,
    required this.netPayable,
    required this.taxTotal,
    required this.subtotal,
    required this.discount,
    required this.txnDate,
    this.previousPoints,
    this.collectedPoint,
    this.totalPoint,
  });

  factory DashboardTransaction.fromJson(Map<String, dynamic> json) {
    return DashboardTransaction(
      txnId: json['txn_id'] ?? '',
      netPayable: (json['netpayable'] as num?)?.toDouble() ?? 0.0,
      taxTotal: (json['taxtotal'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      txnDate: json['txndate'] ?? '',
      previousPoints: (json['previouspoints'] as num?)?.toDouble(),
      collectedPoint: (json['collectedpoint'] as num?)?.toDouble(),
      totalPoint: (json['totalpoint'] as num?)?.toDouble(),
    );
  }
}

class DashboardData {
  final List<DashboardOffer> offers;
  final List<DashboardTransaction> transactions;
  final int customerPoints;

  DashboardData({
    required this.offers,
    required this.transactions,
    required this.customerPoints,
  });

  factory DashboardData.fromJson(Map<String, dynamic> json) {
    final offerList =
        (json['Offer'] as List?)
            ?.map((e) => DashboardOffer.fromJson(e))
            .toList() ??
        [];
    final txList =
        (json['CustomerTansactionHistory'] as List?)
            ?.map((e) => DashboardTransaction.fromJson(e))
            .toList() ??
        [];

    return DashboardData(
      offers: offerList,
      transactions: txList,
      customerPoints: json['Custmoerpoints'] ?? 0,
    );
  }
}
