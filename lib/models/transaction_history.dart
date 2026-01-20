class TransactionHistoryItem {
  final String txnId;
  final double netPayable;
  final double taxTotal;
  final double subtotal;
  final double discount;
  final String txnDate;
  final double previousPoints;
  final double collectedPoint;
  final double totalPoint;

  TransactionHistoryItem({
    required this.txnId,
    required this.netPayable,
    required this.taxTotal,
    required this.subtotal,
    required this.discount,
    required this.txnDate,
    required this.previousPoints,
    required this.collectedPoint,
    required this.totalPoint,
  });

  factory TransactionHistoryItem.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryItem(
      txnId: json['txn_id']?.toString() ?? '',
      netPayable: (json['netpayable'] as num?)?.toDouble() ?? 0.0,
      taxTotal: (json['taxtotal'] as num?)?.toDouble() ?? 0.0,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      discount: (json['discount'] as num?)?.toDouble() ?? 0.0,
      txnDate: json['txndate']?.toString() ?? '',
      previousPoints: (json['previouspoints'] as num?)?.toDouble() ?? 0.0,
      collectedPoint: (json['collectedpoint'] as num?)?.toDouble() ?? 0.0,
      totalPoint: (json['totalpoint'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class TransactionHistoryResponse {
  final bool result;
  final int status;
  final String msg;
  final String id;
  final List<TransactionHistoryItem> data;

  TransactionHistoryResponse({
    required this.result,
    required this.status,
    required this.msg,
    required this.id,
    required this.data,
  });

  factory TransactionHistoryResponse.fromJson(Map<String, dynamic> json) {
    return TransactionHistoryResponse(
      result: json['Result'] ?? false,
      status: json['Status'] ?? 0,
      msg: json['Msg'] ?? '',
      id: json['ID'] ?? '',
      data:
          (json['Data'] as List?)
              ?.map((item) => TransactionHistoryItem.fromJson(item))
              .toList() ??
          [],
    );
  }
}
