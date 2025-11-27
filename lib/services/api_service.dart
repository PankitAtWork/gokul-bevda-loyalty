// lib/services/api_service.dart
import 'dart:async';
import 'package:dio/dio.dart';
import '../models/points_data.dart';
import '../models/special_offer.dart';
import '../models/recent_activity.dart';
import '../models/purchase_history.dart';
import '../models/store.dart';

class ApiService {
  final Dio dio;

  ApiService._(this.dio);

  /// Create an ApiService with sensible defaults.
  /// Replace baseUrl with your server base URL.
  factory ApiService.create({required String baseUrl}) {
    final dio = Dio(
      BaseOptions(
        baseUrl: baseUrl,
        connectTimeout: const Duration(seconds: 10),
        receiveTimeout: const Duration(seconds: 10),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    // Simple logging interceptor (optional)
    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) {
          // print('→ ${options.method} ${options.uri}');
          handler.next(options);
        },
        onResponse: (response, handler) {
          // print('← ${response.statusCode} ${response.requestOptions.uri}');
          handler.next(response);
        },
        onError: (err, handler) {
          // print('✖ ${err.message}');
          handler.next(err);
        },
      ),
    );

    return ApiService._(dio);
  }

  /// Mock API: Get user points data
  /// Simulates API call with delay
  Future<PointsData> getUserPoints() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return PointsData(points: 1200, completedMissions: 4, totalMissions: 8);
  }

  /// Mock API: Get special offers
  /// Simulates API call with delay
  Future<List<SpecialOffer>> getSpecialOffers({String? type}) async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data matching the Figma design
    final mockStores = [
      Store(
        id: '1',
        name: 'Downtown Cellars',
        address: '123 Main Street, India, NY 10001',
        hours: '9AM-9PM',
        stock: 'In stock: 15 bottles',
      ),
      Store(
        id: '2',
        name: 'Downtown Cellars',
        address: '123 Main Street, India, NY 10001',
        hours: '9AM-9PM',
        stock: 'In stock: 15 bottles',
      ),
      Store(
        id: '3',
        name: 'Downtown Cellars',
        address: '123 Main Street, India, NY 10001',
        hours: '9AM-9PM',
        stock: 'In stock: 15 bottles',
      ),
    ];

    final allOffers = [
      SpecialOffer(
        id: '1',
        title: 'Buy 1 Get 1 Free',
        description:
            'Select premium spirits and wines. Limited to in-store purchases only.',
        category: 'Spirits & Wines',
        availability: 'All Stores',
        expires: 'Oct 11, 2025',
        tag: 'Limited Time',
        type: 'buy1get1',
        iconType: 'bottle',
        stores: mockStores,
      ),
      SpecialOffer(
        id: '2',
        title: '20% Off Premium Wines',
        description:
            'Get 20% off on all premium wine selections from our exclusive collection.',
        category: 'Wines',
        availability: 'Selected Stores',
        expires: 'Oct 11, 2025',
        tag: 'Popular',
        type: 'discounts',
        iconType: 'percentage',
        stores: mockStores,
      ),
      SpecialOffer(
        id: '3',
        title: 'Buy 1 Get 1 Free',
        description:
            'Select premium spirits and wines. Limited to in-store purchases only.',
        category: 'Spirits & Wines',
        availability: 'All Stores',
        expires: 'Oct 11, 2025',
        tag: 'Limited Time',
        type: 'buy1get1',
        iconType: 'bottle',
        stores: mockStores,
      ),
      SpecialOffer(
        id: '4',
        title: '20% Off Premium Wines',
        description:
            'Get 20% off on all premium wine selections from our exclusive collection.',
        category: 'Wines',
        availability: 'Selected Stores',
        expires: 'Oct 11, 2025',
        tag: 'Popular',
        type: 'discounts',
        iconType: 'percentage',
        stores: mockStores,
      ),
    ];

    // Filter by type if provided
    if (type != null && type != 'all') {
      return allOffers.where((offer) => offer.type == type).toList();
    }

    return allOffers;
  }

  /// Legacy method for home tab compatibility
  /// Returns simplified offers for home screen
  Future<List<SpecialOffer>> getSpecialOffersForHome() async {
    final offers = await getSpecialOffers();
    // Return first 3 offers for home screen
    return offers.take(3).toList();
  }

  /// Mock API: Get recent activity
  /// Simulates API call with delay
  Future<List<RecentActivity>> getRecentActivity() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data
    return [
      RecentActivity(
        id: '1',
        type: 'Points Earned',
        description: 'Purchase at Downtown Spirits',
        date: 'Jul 28, 2023',
        time: '6:42 PM',
        points: 150,
        isPositive: true,
      ),
      RecentActivity(
        id: '2',
        type: 'Points Earned',
        description: 'Purchase at Downtown Spirits',
        date: 'Jul 28, 2023',
        time: '6:42 PM',
        points: 150,
        isPositive: true,
      ),
      RecentActivity(
        id: '3',
        type: 'Points Earned',
        description: 'Purchase at Downtown Spirits',
        date: 'Jul 28, 2023',
        time: '6:42 PM',
        points: 150,
        isPositive: true,
      ),
    ];
  }

  /// Mock API: Get user QR code data
  /// Simulates API call with delay
  Future<Map<String, dynamic>> getUserQrData() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data matching the Figma design
    return {
      'name': 'John Smith',
      'memberNumber': 'SP-984752',
      'points': 1250,
      'memberType': 'VIP Member',
    };
  }

  /// Mock API: Get purchase history summary
  /// Simulates API call with delay
  Future<PurchaseHistorySummary> getPurchaseHistory() async {
    // Simulate network delay
    await Future.delayed(const Duration(seconds: 1));

    // Return mock data matching the Figma design
    final transactions = [
      PurchaseHistory(
        id: '1',
        type: 'reward',
        description: 'Reward Redeemed: Premium Whiskey',
        date: 'Aug 15, 2023',
        time: '2:30 PM',
        points: 500,
        isPositive: false,
      ),
      PurchaseHistory(
        id: '2',
        type: 'purchase',
        description: 'Purchase at Downtown Spirits',
        date: 'Aug 12, 2023',
        time: '6:42 PM',
        points: 90,
        isPositive: true,
      ),
      PurchaseHistory(
        id: '3',
        type: 'purchase',
        description: 'Purchase at Downtown Spirits',
        date: 'Aug 12, 2023',
        time: '6:42 PM',
        points: 90,
        isPositive: true,
      ),
      PurchaseHistory(
        id: '4',
        type: 'purchase',
        description: 'Purchase at Wine & More',
        date: 'Aug 8, 2023',
        time: '3:15 PM',
        points: 90,
        isPositive: true,
      ),
      PurchaseHistory(
        id: '5',
        type: 'reward',
        description: 'Reward Redeemed: Premium Whiskey',
        date: 'Aug 15, 2023',
        time: '2:30 PM',
        points: 750,
        isPositive: false,
      ),
      PurchaseHistory(
        id: '6',
        type: 'purchase',
        description: 'Purchase at Wine & More',
        date: 'Aug 8, 2023',
        time: '3:15 PM',
        points: 30,
        isPositive: true,
      ),
      PurchaseHistory(
        id: '7',
        type: 'reward',
        description: 'Reward Redeemed: Premium Whiskey',
        date: 'Aug 15, 2023',
        time: '2:30 PM',
        points: 500,
        isPositive: false,
      ),
      PurchaseHistory(
        id: '8',
        type: 'purchase',
        description: 'Purchase at Downtown Spirits',
        date: 'Aug 12, 2023',
        time: '6:42 PM',
        points: 50,
        isPositive: true,
      ),
      PurchaseHistory(
        id: '9',
        type: 'purchase',
        description: 'Purchase at Wine & More',
        date: 'Aug 8, 2023',
        time: '3:15 PM',
        points: 46,
        isPositive: true,
      ),
    ];

    final earnedTransactions = transactions.where((t) => t.isPositive).toList();
    final redeemedTransactions = transactions
        .where((t) => !t.isPositive)
        .toList();

    return PurchaseHistorySummary(
      pointsBalance: 1250,
      pointsEarned: earnedTransactions.fold(0, (sum, t) => sum + t.points),
      pointsRedeemed: redeemedTransactions.fold(0, (sum, t) => sum + t.points),
      earnedTransactionsCount: earnedTransactions.length,
      redeemedTransactionsCount: redeemedTransactions.length,
      allTransactions: transactions,
    );
  }
}
