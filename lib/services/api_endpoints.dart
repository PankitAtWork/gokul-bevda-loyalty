/// API endpoint constants
class ApiEndpoints {
  static const String login = '/login';
  static const String sendOtp = '/SendOtpSms';
  static const String verifyOtp = '/Verifyotp';
  static const String createAccount = '/create-account';

  // Home screen endpoints
  static const String getUserPoints = '/user/points';
  static const String getSpecialOffers = '/special-offers';
  static const String getRecentActivity = '/recent-activity';

  // Purchase history endpoints
  static const String getPurchaseHistory = '/purchase-history';

  // Barcode/QR code endpoints
  static const String getUserQrData = '/user/qr-data';

  // Rewards/Redemption endpoints
  static const String generateRedemptionCode = '/rewards/generate-code';
  static const String dashboard = '/dashboard';
  static const String transactionHistory = '/GetCustomerTransactionHistory';
}
