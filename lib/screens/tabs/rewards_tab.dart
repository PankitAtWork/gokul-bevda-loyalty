// lib/screens/tabs/rewards_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/theme.dart';

class RewardsTabContent extends StatefulWidget {
  const RewardsTabContent({super.key});

  @override
  State<RewardsTabContent> createState() => _RewardsTabContentState();
}

class _RewardsTabContentState extends State<RewardsTabContent> {
  final TextEditingController _amountController = TextEditingController(
    text: '75',
  );
  String? _selectedAmount;
  String? _selectedStore;
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
                      padding: const EdgeInsets.all(16),
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
                              onPressed: () {
                                // Generate redemption code
                              },
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppTheme.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  vertical: 16,
                                ),
                                shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(12),
                                ),
                              ),
                              child: const Text(
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
