// lib/screens/tabs/rewards_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../config/api_config.dart';
import '../../utils/theme.dart';
import '../../utils/responsive.dart';
import '../../services/api_service.dart';

class RewardsTabContent extends StatefulWidget {
  const RewardsTabContent({super.key});

  @override
  State<RewardsTabContent> createState() => _RewardsTabContentState();
}

class _RewardsTabContentState extends State<RewardsTabContent> {
  final ApiService _apiService = ApiService.create(
    baseUrl: ApiConfig.baseUrl,
  );
  final TextEditingController _amountController = TextEditingController(
    text: '75',
  );
  String? _selectedAmount;
  String? _selectedStore;
  bool _isGeneratingCode = false;
  final List<String> _amountOptions = ['10', '20', '50', '75', '100', '125'];
  final List<String> _storeOptions = [
    'Downtown',
    'Westside',
    'Northside',
    'Southside',
    'Harbor',
  ];
  final int pointsBalance = 1250; // Available points

  @override
  void initState() {
    super.initState();
    _selectedAmount = '75';
    _selectedStore = 'Westside';
  }

  @override
  void dispose() {
    _amountController.dispose();
    super.dispose();
  }

  String _formatNumber(int number) {
    return number.toString().replaceAllMapped(
      RegExp(r'(\d{1,3})(?=(\d{3})+(?!\d))'),
      (Match m) => '${m[1]},',
    );
  }

  Future<void> _generateRedemptionCode() async {
    if (_selectedAmount == null || _selectedStore == null) {
      _showErrorDialog('Please select an amount and store');
      return;
    }

    setState(() {
      _isGeneratingCode = true;
    });

    try {
      final response = await _apiService.generateRedemptionCode(
        amount: _selectedAmount!,
        store: _selectedStore!,
      );

      if (mounted) {
        setState(() {
          _isGeneratingCode = false;
        });

        if (response['success'] == true) {
          _showSuccessDialog(
            code: response['code'] as String,
            amount: response['amount'] as String,
            store: response['store'] as String,
          );
        } else {
          _showErrorDialog(
            response['message'] as String? ??
                'Failed to generate redemption code',
          );
        }
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isGeneratingCode = false;
        });

        String errorMessage = 'An error occurred';
        if (e.toString().contains('SocketException') ||
            e.toString().contains('Network') ||
            e.toString().contains('connection') ||
            e.toString().contains('timeout')) {
          errorMessage =
              'Network error. Please check your internet connection and try again.';
        } else if (e.toString().contains('DioException') ||
            e.toString().contains('DioError')) {
          errorMessage = 'Network request failed. Please try again.';
        } else {
          errorMessage = e.toString();
        }

        _showErrorDialog(errorMessage);
      }
    }
  }

  void _showSuccessDialog({
    required String code,
    required String amount,
    required String store,
  }) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, 16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(Responsive.padding(context, 24)),
                constraints: BoxConstraints(
                  maxWidth: Responsive.dialogWidth(context),
                  maxHeight: Responsive.dialogMaxHeight(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Success icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: AppTheme.darkGreen.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.check_circle,
                        color: AppTheme.darkGreen,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Success title
                    const Text(
                      'Redemption Code Generated!',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'Roboto Flex',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Code display
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.lightPink,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: AppTheme.primary, width: 2),
                      ),
                      child: Column(
                        children: [
                          const Text(
                            'Your Redemption Code',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                              color: AppTheme.unselected_tab_color,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            code,
                            style: const TextStyle(
                              fontSize: 24,
                              fontWeight: FontWeight.w700,
                              color: AppTheme.primary,
                              fontFamily: 'Roboto Flex',
                              letterSpacing: 2,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Details
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(12),
                      decoration: BoxDecoration(
                        color: AppTheme.lightGray,
                        borderRadius: BorderRadius.circular(8),
                      ),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          _buildDetailRow('Amount:', '\$$amount'),
                          const SizedBox(height: 8),
                          _buildDetailRow('Store:', store),
                        ],
                      ),
                    ),
                    const SizedBox(height: 24),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildDetailRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          label,
          style: TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w500,
            color: AppTheme.unselected_tab_color,
            fontFamily: 'Roboto Flex',
          ),
        ),
        Text(
          value,
          style: const TextStyle(
            fontSize: 12,
            fontWeight: FontWeight.w600,
            color: Colors.black,
            fontFamily: 'Roboto Flex',
          ),
        ),
      ],
    );
  }

  void _showErrorDialog(String message) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext dialogContext) {
        return Dialog(
          backgroundColor: Colors.transparent,
          elevation: 0,
          insetPadding: EdgeInsets.symmetric(
            horizontal: Responsive.padding(context, 16),
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.circular(12),
            child: Material(
              color: Colors.white,
              child: Container(
                padding: EdgeInsets.all(Responsive.padding(context, 24)),
                constraints: BoxConstraints(
                  maxWidth: Responsive.dialogWidth(context),
                  maxHeight: Responsive.dialogMaxHeight(context),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    // Error icon
                    Container(
                      width: 64,
                      height: 64,
                      decoration: BoxDecoration(
                        color: Colors.red.withOpacity(0.1),
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.error_outline,
                        color: Colors.red,
                        size: 40,
                      ),
                    ),
                    const SizedBox(height: 20),
                    // Error title
                    const Text(
                      'Error',
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: Colors.black,
                        fontFamily: 'Roboto Flex',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 16),
                    // Error message
                    Text(
                      message,
                      style: TextStyle(
                        fontSize: 14,
                        fontWeight: FontWeight.w400,
                        color: AppTheme.unselected_tab_color,
                        fontFamily: 'Roboto Flex',
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 24),
                    // Close button
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: () => Navigator.of(dialogContext).pop(),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: AppTheme.primary,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: const Text(
                          'Close',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w600,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: const SystemUiOverlayStyle(
        statusBarColor: AppTheme.primary,
        statusBarIconBrightness: Brightness.light,
        statusBarBrightness: Brightness.dark,
      ),
      child: Container(
        color: AppTheme.primaryDark,
        child: SafeArea(
          child: Column(
            children: [
              // Stack for Banner with Title Bar on top
              Stack(
                children: [
                  // Points Balance Banner with SVG background
                  Container(
                    width: double.infinity,
                    height: 200,
                    child: Stack(
                      children: [
                        // SVG Background
                        Positioned.fill(
                          child: SvgPicture.asset(
                            'assets/images/reactangle_red.svg',
                            fit: BoxFit.cover,
                          ),
                        ),
                        // Points Balance Text
                        Positioned(
                          bottom: 10,
                          left: 15,
                          right: 15,
                          child: Padding(
                            padding: const EdgeInsets.only(bottom: 10),
                            child: Container(
                              decoration: BoxDecoration(
                                gradient: const LinearGradient(
                                  begin: Alignment.centerLeft,
                                  end: Alignment.centerRight,
                                  colors: [
                                    Color(0x35FFFFFF),
                                    Color(0x35FFFFFF),
                                  ],
                                ),
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: Color(0xFFFFFFFF),
                                  width: .5,
                                ),
                              ),
                              child: Material(
                                color: Colors.transparent,
                                child: InkWell(
                                  onTap: () {
                                    // Handle redeem points
                                  },
                                  borderRadius: BorderRadius.circular(8),
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                      horizontal: 10,
                                      vertical: 15,
                                    ),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              'Available Points:',
                                              style: TextStyle(
                                                color: Colors.white,
                                                fontSize: 16,
                                                fontWeight: FontWeight.w700,
                                                fontFamily: 'Roboto Flex',
                                              ),
                                            ),
                                            const SizedBox(height: 12),
                                            Text(
                                              '1 Point = \$1',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.bg,
                                                fontFamily: 'Roboto Flex',
                                              ),
                                            ),

                                            Text(
                                              'Max \$125 per redemption',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: AppTheme.bg,
                                                fontFamily: 'Roboto Flex',
                                              ),
                                            ),
                                          ],
                                        ),

                                        Text(
                                          '$pointsBalance pts',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 16,
                                            fontWeight: FontWeight.w600,
                                            fontFamily: 'Roboto Flex',
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  // Transparent Title Bar on top
                  Positioned(
                    top: 0,
                    left: 0,
                    right: 0,
                    child: Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 2,
                        vertical: 12,
                      ),
                      decoration: const BoxDecoration(
                        color: Colors.transparent,
                      ),
                      child: Row(
                        children: [
                          // White Back Button
                          IconButton(
                            icon: const Icon(
                              Icons.arrow_back,
                              color: Colors.white,
                            ),
                            onPressed: () {
                              // Navigate back if needed
                            },
                          ),
                          // Center Title
                          const Expanded(
                            child: Text(
                              'Redeem Points',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Flex',
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                          // Spacer for balance
                          const SizedBox(width: 48),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              // Content
              Expanded(
                child: ClipRRect(
                  borderRadius: const BorderRadius.only(
                    topLeft: Radius.circular(30),
                    topRight: Radius.circular(30),
                  ),
                  child: Container(
                    decoration: const BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(30),
                        topRight: Radius.circular(30),
                      ),
                    ),
                    child: SingleChildScrollView(
                      padding: EdgeInsets.all(Responsive.padding(context, 16)),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Available Points Card
                          const SizedBox(height: 5),
                          // Enter Amount
                          Container(
                            width: double.infinity,
                            padding: const EdgeInsets.all(4),

                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Enter Amount',
                                  style: TextStyle(
                                    fontSize: 15,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: 'Roboto Flex',
                                  ),
                                ),
                                const SizedBox(height: 14),
                                TextField(
                                  controller: _amountController,
                                  keyboardType: TextInputType.number,
                                  textAlign: TextAlign.center,
                                  decoration: InputDecoration(
                                    prefixText: '\$',
                                    prefixStyle: const TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                    border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    focusedBorder: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(8),
                                      borderSide: const BorderSide(
                                        color: AppTheme.primary,
                                        width: 1,
                                      ),
                                    ),
                                    hintText: '0',
                                    hintStyle: TextStyle(
                                      fontSize: 16,
                                      color: Colors.grey[400],
                                      fontFamily: 'Roboto Flex',
                                    ),
                                    contentPadding: const EdgeInsets.symmetric(
                                      horizontal: 16,
                                      vertical: 12,
                                    ),
                                  ),
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.black,
                                    fontFamily: 'Roboto Flex',
                                  ),
                                  onChanged: (value) {
                                    setState(() {
                                      _selectedAmount = value;
                                    });
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          // Select Redemption Amount
                          const Text(
                            'Select Redemption Amount',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                          const SizedBox(height: 14),
                          Wrap(
                            spacing: 14,
                            runSpacing: 12,
                            children: _amountOptions.map((amount) {
                              final isSelected = _selectedAmount == amount;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedAmount = amount;
                                    _amountController.text = amount;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 40,
                                    vertical: 8,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.primary
                                        : Colors.white,
                                    borderRadius: BorderRadius.circular(24),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : AppTheme.darkRed2,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    '\$$amount',
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.w600,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 24),
                          // Select Store
                          const Text(
                            'Select Store',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w600,
                              color: Colors.black,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Wrap(
                            spacing: 12,
                            runSpacing: 12,
                            children: _storeOptions.map((store) {
                              final isSelected = _selectedStore == store;
                              return GestureDetector(
                                onTap: () {
                                  setState(() {
                                    _selectedStore = store;
                                  });
                                },
                                child: Container(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 20,
                                    vertical: 12,
                                  ),
                                  decoration: BoxDecoration(
                                    color: isSelected
                                        ? AppTheme.darkRed
                                        : AppTheme.doubleLightGray,
                                    borderRadius: BorderRadius.circular(4),
                                    border: Border.all(
                                      color: isSelected
                                          ? AppTheme.primary
                                          : AppTheme.bg,
                                      width: 1,
                                    ),
                                  ),
                                  child: Text(
                                    store,
                                    style: TextStyle(
                                      fontSize: 13,
                                      fontWeight: FontWeight.w500,
                                      color: isSelected
                                          ? Colors.white
                                          : Colors.black,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                  ),
                                ),
                              );
                            }).toList(),
                          ),
                          const SizedBox(height: 32),
                          // Generate Redemption Code Button
                          SizedBox(
                            width: double.infinity,
                            child: ElevatedButton(
                              onPressed: _isGeneratingCode
                                  ? null
                                  : _generateRedemptionCode,
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                disabledBackgroundColor: AppTheme.primary
                                    .withOpacity(0.6),
                              ),
                              child: _isGeneratingCode
                                  ? const SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: CircularProgressIndicator(
                                        strokeWidth: 2,
                                        valueColor:
                                            AlwaysStoppedAnimation<Color>(
                                              Colors.white,
                                            ),
                                      ),
                                    )
                                  : const Text(
                                      'Generate Redemption Code',
                                      style: TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        fontFamily: 'Roboto Flex',
                                      ),
                                    ),
                            ),
                          ),
                          const SizedBox(height: 16),
                          // Information text
                          Container(
                            padding: const EdgeInsets.all(14),
                            decoration: BoxDecoration(
                              color: AppTheme.primary.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Row(
                              children: [
                                SvgPicture.asset(
                                  'assets/images/imp.svg',
                                  width: 18,
                                  height: 18,
                                ),
                                const SizedBox(width: 8),
                                Expanded(
                                  child: Text(
                                    'Present this code at checkout to redeem your points',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w500,
                                      color: Colors.black,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
