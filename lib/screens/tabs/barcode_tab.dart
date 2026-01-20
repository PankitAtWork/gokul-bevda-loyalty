// lib/screens/tabs/barcode_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/api_config.dart';
import '../../utils/theme.dart';
import '../../services/api_service.dart';

class BarcodeTabContent extends StatefulWidget {
  const BarcodeTabContent({super.key});

  @override
  State<BarcodeTabContent> createState() => _BarcodeTabContentState();
}

class _BarcodeTabContentState extends State<BarcodeTabContent> {
  final ApiService _apiService = ApiService.create(
    baseUrl: ApiConfig.baseUrl,
  );

  bool _isLoading = true;
  String? _error;
  Map<String, dynamic>? _qrData;

  @override
  void initState() {
    super.initState();
    _loadQrData();
  }

  Future<void> _loadQrData() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final data = await _apiService.getUserQrData();
      if (mounted) {
        setState(() {
          _qrData = data;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        String errorMessage = 'An error occurred';

        // Check for network errors
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Network') ||
            e.toString().contains('connection') ||
            e.toString().contains('timeout') ||
            e.toString().contains('Failed host lookup')) {
          errorMessage =
              'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('DioException') ||
            e.toString().contains('DioError')) {
          errorMessage = 'Network request failed. Please try again.';
        } else {
          errorMessage = e.toString();
        }

        setState(() {
          _error = errorMessage;
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _shareQrCode() async {
    // Share functionality - placeholder for now
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Share functionality will be implemented'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  Future<void> _saveQrCode() async {
    // Save functionality - placeholder for now
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('QR code saved to gallery'),
          backgroundColor: AppTheme.primary,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
      ),
      child: Container(
        color: Colors.white,
        child: SafeArea(child: _buildBody()),
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(
          valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
        ),
      );
    }

    if (_error != null) {
      final isNetworkError =
          _error!.toLowerCase().contains('network') ||
          _error!.toLowerCase().contains('connection') ||
          _error!.toLowerCase().contains('timeout');

      return Center(
        child: Padding(
          padding: const EdgeInsets.all(32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                isNetworkError ? Icons.wifi_off : Icons.error_outline,
                size: 64,
                color: Colors.red,
              ),
              const SizedBox(height: 16),
              Text(
                isNetworkError ? 'Network Error' : 'Error',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: Colors.grey[800],
                  fontFamily: 'Roboto Flex',
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32),
                child: Text(
                  _error!,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey[600],
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loadQrData,
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Retry'),
              ),
            ],
          ),
        ),
      );
    }

    if (_qrData == null) {
      return const Center(
        child: Text(
          'No data available',
          style: TextStyle(
            fontSize: 16,
            color: Colors.grey,
            fontFamily: 'Roboto Flex',
          ),
        ),
      );
    }

    return SingleChildScrollView(
      child: Column(
        children: [
          // Header
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            child: Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.arrow_back, color: Colors.black),
                  onPressed: () {
                    // Navigate back if needed
                  },
                ),
                const Expanded(
                  child: Text(
                    'Your Rewards QR Code',
                    style: TextStyle(
                      color: Colors.black,
                      fontSize: 18,
                      fontWeight: FontWeight.w600,
                      fontFamily: 'Roboto Flex',
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
                const SizedBox(width: 48), // Balance space for back button
              ],
            ),
          ),

          // Instruction text
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 0),
            child: Text(
              'Scan at checkout to earn or redeem points',
              style: TextStyle(
                fontSize: 14,
                color: Colors.black,
                fontFamily: 'Roboto Flex',
              ),
              textAlign: TextAlign.center,
            ),
          ),

          const SizedBox(height: 40),

          // QR Code
          Center(
            child: SvgPicture.asset(
              'assets/images/barcode_full.svg',
              width: 180,
              height: 180,
            ),
          ),

          const SizedBox(height: 40),

          // User Info Card with red shadow rectangle
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 20),
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(7),
                boxShadow: [
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.15),
                    blurRadius: 15,
                    spreadRadius: 2,
                    offset: const Offset(0, 4),
                  ),
                  BoxShadow(
                    color: AppTheme.primary.withOpacity(0.1),
                    blurRadius: 25,
                    spreadRadius: 5,
                    offset: const Offset(0, 6),
                  ),
                ],
              ),
              child: SizedBox(
                width: double.infinity,
                height: 160, // Match SVG height
                child: Stack(
                  children: [
                    // Background shadow rectangle
                    SvgPicture.asset(
                      'assets/images/red_shadow_rectangle.svg',
                      width: double.infinity,
                      height: 177,
                      fit: BoxFit.fill,
                    ),
                    // Content
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.all(20),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              _qrData!['name'] ?? 'User Name',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 20,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                            const SizedBox(height: 24),
                            Text(
                              '${_qrData!['memberType'] ?? 'VIP Member'} #${_qrData!['memberNumber'] ?? 'SP-000000'}',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '${_qrData!['points'] ?? 0} Points Available',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 14,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Action Buttons
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 50, vertical: 10),
            child: Row(
              children: [
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _shareQrCode,
                    icon: SvgPicture.asset(
                      'assets/images/share.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      'Share',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto Flex',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,

                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: AppTheme.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: ElevatedButton.icon(
                    onPressed: _saveQrCode,
                    icon: SvgPicture.asset(
                      'assets/images/download.svg',
                      width: 20,
                      height: 20,
                      colorFilter: const ColorFilter.mode(
                        AppTheme.primary,
                        BlendMode.srcIn,
                      ),
                    ),
                    label: const Text(
                      'Save',
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'Roboto Flex',
                      ),
                    ),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.white,
                      foregroundColor: AppTheme.primary,
                      elevation: 0,
                      padding: const EdgeInsets.symmetric(vertical: 12),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(25),
                        side: const BorderSide(
                          color: AppTheme.primary,
                          width: 1,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }
}
