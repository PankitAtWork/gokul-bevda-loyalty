// lib/models/dashboard_data.dart
import 'special_offer.dart';
import 'store.dart';

class DashboardOffer {
  final int saleId;
  final String saleName;
  final String? note;
  final String? startDate;
  final String? endDate;
  final String? discountType;
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
    this.discountType,
    this.targetTypeDesc,
    this.promoTargetName,
    this.coupon,
    this.commonSale,
    this.stores,
  });

  factory DashboardOffer.fromJson(Map<String, dynamic> json) {
    return DashboardOffer(
      saleId: json['sale_id'] ?? 0,
      saleName: json['promodescription'] ?? '',
      note: json['note'],
      startDate: json['startdate'],
      endDate: json['enddate'],
      discountType: json['discounttype'],
      targetTypeDesc: json['targettypedesc'],
      promoTargetName: json['promotargetname'],
      coupon: json['coupon'],
      commonSale: json['commonsale'],
      stores: json['stores'],
    );
  }

  SpecialOffer toSpecialOffer() {
    // Helper to format date
    String formatExpires(String? dateStr) {
      if (dateStr == null || dateStr.isEmpty) return '';
      try {
        final date = DateTime.parse(dateStr);
        // format like 'Oct 11, 2025'
        final months = [
          'Jan',
          'Feb',
          'Mar',
          'Apr',
          'May',
          'Jun',
          'Jul',
          'Aug',
          'Sep',
          'Oct',
          'Nov',
          'Dec',
        ];
        return '${months[date.month - 1]} ${date.day}, ${date.year}';
      } catch (e) {
        return dateStr;
      }
    }

    // Helper to parse type
    String parseType(String? dt) {
      if (dt == 'Exact') return 'discounts';
      if (dt == 'BOGO') return 'buy1get1';
      return 'all';
    }

    // Helper to parse icon type
    String parseIconType(String? dt) {
      if (dt == 'Exact') return 'percentage';
      if (dt == 'BOGO') return 'bottle';
      return 'percentage';
    }

    final rawStores = stores ?? '';
    final storeList = rawStores
        .split(',')
        .map((s) => s.trim())
        .where((s) => s.isNotEmpty)
        .toList();

    // Create Store objects from simple names
    final storeObjects = storeList
        .map(
          (name) => Store(
            id: '', // No ID from this API
            name: name,
            address: '', // No address from this API
            hours: 'Check in store', // Default
            phone: 'Check in store', // Default
            stock: 'Check availability', // Default
          ),
        )
        .toList();

    return SpecialOffer(
      id: saleId.toString(),
      title: saleName,
      description: (note ?? '').isEmpty ? 'No description available' : note!,
      categoryTitle: targetTypeDesc ?? '',
      category: promoTargetName ?? '',
      availability: rawStores,
      expires: formatExpires(endDate),
      tag: (endDate != null && endDate!.isNotEmpty) ? 'Limited Time' : '',
      type: parseType(discountType),
      iconType: parseIconType(discountType),
      stores: storeObjects,
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
  final String storeName;

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
    required this.storeName,
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
      storeName: json['storename']?.toString() ?? '',
    );
  }
}

class DashboardData {
  final List<DashboardOffer> offers;
  final List<DashboardTransaction> transactions;
  final int customerPoints;
  final int completedMissions;
  final int totalMissions;
  final String customerType;

  DashboardData({
    required this.offers,
    required this.transactions,
    required this.customerPoints,
    required this.completedMissions,
    required this.totalMissions,
    required this.customerType,
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
      completedMissions: json['completed_missions'] ?? 0,
      totalMissions: json['total_missions'] ?? 0,
      customerType: json['customerType']?.toString() ?? 'Platinum',
    );
  }
}
