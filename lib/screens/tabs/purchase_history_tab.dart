// lib/screens/tabs/purchase_history_tab.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../../utils/theme.dart';
import '../../models/purchase_history.dart';
import '../../services/api_service.dart';

class PurchaseHistoryTabContent extends StatefulWidget {
  const PurchaseHistoryTabContent({super.key});

  @override
  State<PurchaseHistoryTabContent> createState() =>
      _PurchaseHistoryTabContentState();
}

class _PurchaseHistoryTabContentState extends State<PurchaseHistoryTabContent>
    with SingleTickerProviderStateMixin {
  final ApiService _apiService = ApiService.create(
    baseUrl: 'https://api.example.com',
  );

  late TabController _tabController;
  bool _isLoading = true;
  String? _error;
  PurchaseHistorySummary? _summary;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() {
      setState(() {});
    });
    _loadPurchaseHistory();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _loadPurchaseHistory() async {
    setState(() {
      _isLoading = true;
      _error = null;
    });

    try {
      final summary = await _apiService.getPurchaseHistory();
      if (mounted) {
        setState(() {
          _summary = summary;
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _error = e.toString();
          _isLoading = false;
        });
      }
    }
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
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, size: 64, color: Colors.red),
            const SizedBox(height: 16),
            Text(
              'Error',
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
              onPressed: _loadPurchaseHistory,
              child: const Text('Retry'),
            ),
          ],
        ),
      );
    }

    if (_summary == null) {
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

    return Column(
      children: [
        // Stack for Banner with Title Bar on top
        Stack(
          children: [
            // Points Balance Banner with SVG background
            Container(
              width: double.infinity,
              height: 170,
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
                            colors: [Color(0x40FFFFFF), Color(0x40FFFFFF)],
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
                                  Text(
                                    'Your Points Balance:',
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                  ),
                                  Text(
                                    '${_summary!.pointsBalance} pts',
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
                decoration: const BoxDecoration(color: Colors.transparent),
                child: Row(
                  children: [
                    // White Back Button
                    IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.white),
                      onPressed: () {
                        // Navigate back if needed
                      },
                    ),
                    // Center Title
                    const Expanded(
                      child: Text(
                        'Purchase History',
                        style: TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          fontFamily: 'Roboto Flex',
                        ),
                        textAlign: TextAlign.center,
                      ),
                    ),
                    // Filter Icon
                    Material(
                      color: Colors.transparent,
                      child: InkWell(
                        onTap: () {
                          print('Filter button tapped');
                          _showFilterPopup(context);
                        },
                        borderRadius: BorderRadius.circular(6),
                        child: Container(
                          width: 32,
                          height: 32,
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(6),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: SvgPicture.asset(
                              'assets/images/filter.svg',
                              width: 20,
                              height: 20,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),

        // Tabs
        Container(
          color: Color(0xFFCC0000),
          child: Stack(
            children: [
              // Background containers with border radius for each tab
              Row(
                children: [
                  // Left tab - left top radius
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _tabController.index == 0
                            ? Colors.white
                            : AppTheme.lightPink,
                        borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                  // Middle tab - no radius
                  Expanded(
                    child: Container(
                      height: 50,
                      color: _tabController.index == 1
                          ? Colors.white
                          : const Color(0xFFFFF5F5),
                    ),
                  ),
                  // Right tab - right top radius
                  Expanded(
                    child: Container(
                      height: 50,
                      decoration: BoxDecoration(
                        color: _tabController.index == 2
                            ? Colors.white
                            : AppTheme.lightPink,
                        borderRadius: const BorderRadius.only(
                          topRight: Radius.circular(30),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              // TabBar on top
              Container(
                height: 50,
                decoration: const BoxDecoration(color: Colors.transparent),
                child: TabBar(
                  controller: _tabController,
                  labelColor: AppTheme.primary,
                  unselectedLabelColor: AppTheme.primary,
                  indicator: BoxDecoration(
                    color: Colors.white,
                    borderRadius: _tabController.index == 0
                        ? const BorderRadius.only(topLeft: Radius.circular(30))
                        : _tabController.index == 2
                        ? const BorderRadius.only(topRight: Radius.circular(30))
                        : null,
                    border: const Border(
                      bottom: BorderSide(color: AppTheme.primary, width: 1.5),
                    ),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerColor: Colors.transparent,
                  labelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto Flex',
                  ),
                  unselectedLabelStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w700,
                    fontFamily: 'Roboto Flex',
                  ),
                  onTap: (index) {
                    setState(() {});
                  },
                  tabs: const [
                    Tab(text: 'All'),
                    Tab(text: 'Earned'),
                    Tab(text: 'Redeemed'),
                  ],
                ),
              ),
            ],
          ),
        ),

        // Tab Content
        Expanded(
          child: TabBarView(
            controller: _tabController,
            children: [_buildAllTab(), _buildEarnedTab(), _buildRedeemedTab()],
          ),
        ),
      ],
    );
  }

  Widget _buildAllTab() {
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 16, right: 16),
            child: Center(
              child: Text(
                'All Points Activity',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontFamily: 'Roboto Flex',
                ),
              ),
            ),
          ),
          // Summary Boxes
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    '+${_summary!.pointsEarned}',
                    'Points Earned',
                    AppTheme.lightPink,
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _buildSummaryBox(
                    '-${_summary!.pointsRedeemed}',
                    'Points Redeemed',
                    AppTheme.lightPink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Transaction List
          ..._summary!.allTransactions.map(
            (transaction) => _buildTransactionItem(transaction),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildEarnedTab() {
    final earnedTransactions = _summary!.earnedTransactions;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 16, right: 16),
            child: Center(
              child: Text(
                'Points Earned',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontFamily: 'Roboto Flex',
                ),
              ),
            ),
          ),
          // Summary Boxes
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    '+${_summary!.pointsEarned}',
                    'Points Earned',
                    AppTheme.lightPink, // Light pink
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _buildSummaryBox(
                    '${_summary!.earnedTransactionsCount}',
                    'Transactions',
                    AppTheme.lightPink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Transaction List
          if (earnedTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No earned transactions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
            )
          else
            ...earnedTransactions.map(
              (transaction) => _buildTransactionItem(transaction),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildRedeemedTab() {
    final redeemedTransactions = _summary!.redeemedTransactions;
    return SingleChildScrollView(
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Padding(
            padding: EdgeInsets.only(top: 30, bottom: 30, left: 16, right: 16),
            child: Center(
              child: Text(
                'Points Redeemed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: AppTheme.primary,
                  fontFamily: 'Roboto Flex',
                ),
              ),
            ),
          ),
          // Summary Boxes
          Padding(
            padding: const EdgeInsets.only(left: 50, right: 50),
            child: Row(
              children: [
                Expanded(
                  child: _buildSummaryBox(
                    '-${_summary!.pointsRedeemed}',
                    'Points Redeemed',
                    AppTheme.lightPink, // Light pink
                  ),
                ),
                const SizedBox(width: 40),
                Expanded(
                  child: _buildSummaryBox(
                    '${_summary!.redeemedTransactionsCount}',
                    'Rewards',
                    AppTheme.lightPink,
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          // Transaction List
          if (redeemedTransactions.isEmpty)
            const Padding(
              padding: EdgeInsets.all(32),
              child: Center(
                child: Text(
                  'No redeemed transactions',
                  style: TextStyle(
                    fontSize: 14,
                    color: Colors.grey,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
            )
          else
            ...redeemedTransactions.map(
              (transaction) => _buildTransactionItem(transaction),
            ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildSummaryBox(String value, String label, Color backgroundColor) {
    final isPink = backgroundColor == AppTheme.lightPink;
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
      decoration: BoxDecoration(
        color: backgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: isPink
            ? Border.all(
                color: AppTheme.darkPink, // Dark pink border
                width: 1,
              )
            : null,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            value,
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: AppTheme.primary,
              fontFamily: 'Roboto Flex',
            ),
            textAlign: TextAlign.center,
          ),
          if (label.isNotEmpty) ...[
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 10,
                fontWeight: FontWeight.w500,
                color: Colors.grey[700],
                fontFamily: 'Roboto Flex',
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ],
      ),
    );
  }

  Widget _buildTransactionItem(PurchaseHistory transaction) {
    final isPurchase = transaction.type == 'purchase';
    final iconAsset = isPurchase
        ? 'assets/images/bag.svg'
        : 'assets/images/prize.svg';

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          child: Row(
            children: [
              // Icon
              Container(
                width: 50,
                height: 50,
                child: Stack(
                  children: [
                    // Background image
                    Positioned.fill(
                      child: SvgPicture.asset(
                        isPurchase
                            ? 'assets/images/green_round.svg'
                            : 'assets/images/pink_round.svg',
                        fit: BoxFit.cover,
                      ),
                    ),
                    // Icon on top
                    Center(
                      child: SvgPicture.asset(iconAsset, width: 20, height: 20),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: 12),
              // Transaction Details
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      transaction.description,
                      style: const TextStyle(
                        fontSize: 12,
                        fontWeight: FontWeight.w500,
                        color: Colors.black,
                        fontFamily: 'Roboto Flex',
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      '${transaction.date} • ${transaction.time}',
                      style: TextStyle(
                        fontSize: 10,
                        color: AppTheme.unselected_tab_color,
                        fontFamily: 'Roboto Flex',
                        fontWeight: FontWeight.w500,
                      ),
                    ),
                  ],
                ),
              ),
              // Points
              Text(
                '${transaction.isPositive ? '+' : '-'}${transaction.points} pts',
                style: TextStyle(
                  fontSize: 13,
                  fontWeight: FontWeight.bold,
                  color: transaction.isPositive
                      ? AppTheme.lightGreen
                      : AppTheme.primary,
                  fontFamily: 'Roboto Flex',
                ),
              ),
            ],
          ),
        ),
        // Separator
        Divider(
          height: 1,
          thickness: 1,
          color: Colors.grey.shade200,
          indent: 16,
          endIndent: 16,
        ),
      ],
    );
  }

  void _showFilterPopup(BuildContext context) {
    print('_showFilterPopup called');
    final selectedTabIndex = _tabController.index;

    // Filter state
    String selectedTransactionType = 'All';
    String selectedCategory = 'All';
    String startDate = '';
    String endDate = '';

    showDialog(
      context: context,
      barrierDismissible: true,
      barrierColor: Colors.black54,
      builder: (BuildContext dialogContext) {
        return StatefulBuilder(
          builder: (context, setState) {
            return Dialog(
              backgroundColor: Colors.transparent,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(20),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Material(
                  color: Colors.white,
                  child: Container(
                    constraints: const BoxConstraints(
                      maxWidth: 400,
                      maxHeight: 600,
                    ),
                    color: Colors.white,
                    padding: const EdgeInsets.all(20),
                    child: SingleChildScrollView(
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          // Header with title and close button
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Text(
                                'Filter Transactions',
                                style: TextStyle(
                                  fontSize: 20,
                                  fontWeight: FontWeight.w500,
                                  color: Colors.black,
                                  fontFamily: 'Roboto Flex',
                                ),
                              ),
                              IconButton(
                                icon: SvgPicture.asset(
                                  'assets/images/close.svg',
                                  width: 17,
                                  height: 17,
                                ),
                                onPressed: () =>
                                    Navigator.of(dialogContext).pop(),
                                padding: EdgeInsets.zero,
                                constraints: const BoxConstraints(),
                              ),
                            ],
                          ),
                          const SizedBox(height: 24),
                          // Transaction Type Section
                          _buildFilterSection(
                            'Transaction Type',
                            ['All', 'Earned', 'Redeemed'],
                            selectedTransactionType,
                            (value) {
                              setState(() {
                                selectedTransactionType = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Category Section
                          _buildFilterSection(
                            'Category',
                            ['All', 'Purchase', 'Reward'],
                            selectedCategory,
                            (value) {
                              setState(() {
                                selectedCategory = value;
                              });
                            },
                          ),
                          const SizedBox(height: 20),
                          // Date Range Section
                          const Text(
                            'Date Range',
                            style: TextStyle(
                              fontSize: 14,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: _buildDateField(
                                  'mm/dd/yyyy',
                                  startDate,
                                  () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        startDate =
                                            '${date.day}/${date.month}/${date.year}';
                                      });
                                    }
                                  },
                                ),
                              ),
                              const SizedBox(width: 12),
                              Expanded(
                                child: _buildDateField(
                                  'mm/dd/yyyy',
                                  endDate,
                                  () async {
                                    final date = await showDatePicker(
                                      context: context,
                                      initialDate: DateTime.now(),
                                      firstDate: DateTime(2020),
                                      lastDate: DateTime.now(),
                                    );
                                    if (date != null) {
                                      setState(() {
                                        endDate =
                                            '${date.day}/${date.month}/${date.year}';
                                      });
                                    }
                                  },
                                ),
                              ),
                            ],
                          ),
                          const SizedBox(height: 30),
                          // Reset and Apply Buttons
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              SizedBox(
                                width: 80,
                                child: OutlinedButton(
                                  onPressed: () {
                                    setState(() {
                                      selectedTransactionType = 'All';
                                      selectedCategory = 'All';
                                      startDate = '';
                                      endDate = '';
                                    });
                                  },
                                  style: OutlinedButton.styleFrom(
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    minimumSize: const Size(0, 32),
                                    backgroundColor: AppTheme.resetButtonColor,
                                    side: BorderSide.none,
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Reset',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      color: Colors.black,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 12),
                              SizedBox(
                                width: 80,
                                child: ElevatedButton(
                                  onPressed: () {
                                    // Apply filters here
                                    Navigator.of(dialogContext).pop();
                                    // TODO: Apply filters to the transaction list
                                  },
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.primary,
                                    foregroundColor: Colors.white,
                                    padding: const EdgeInsets.symmetric(
                                      vertical: 8,
                                      horizontal: 8,
                                    ),
                                    minimumSize: const Size(0, 32),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(6),
                                    ),
                                  ),
                                  child: const Text(
                                    'Apply',
                                    style: TextStyle(
                                      fontSize: 12,
                                      fontWeight: FontWeight.w600,
                                      fontFamily: 'Roboto Flex',
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _buildFilterSection(
    String title,
    List<String> options,
    String selectedValue,
    Function(String) onSelect,
  ) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.w500,
            color: Colors.black,
            fontFamily: 'Roboto Flex',
          ),
        ),
        const SizedBox(height: 12),
        Wrap(
          spacing: 8,
          runSpacing: 8,
          children: options.map((option) {
            final isSelected = option == selectedValue;
            return GestureDetector(
              onTap: () => onSelect(option),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: 16,
                  vertical: 10,
                ),
                decoration: BoxDecoration(
                  color: isSelected ? AppTheme.primary : AppTheme.lightPink,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(
                    color: isSelected ? AppTheme.primary : AppTheme.lightPink!,
                    width: 1.5,
                  ),
                ),
                child: Padding(
                  padding: const EdgeInsets.only(left: 6, right: 6),
                  child: Text(
                    option,
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.w500,
                      color: isSelected ? Colors.white : Colors.black,
                      fontFamily: 'Roboto Flex',
                    ),
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ],
    );
  }

  Widget _buildDateField(String label, String value, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 12),
        decoration: BoxDecoration(
          color: AppTheme.bg,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(color: AppTheme.borderCalendarColor, width: 1.5),
        ),
        child: Row(
          children: [
            Expanded(
              child: Text(
                value.isEmpty ? label : value,
                style: TextStyle(
                  fontSize: 12,
                  color: value.isEmpty ? Colors.grey[600] : Colors.black,
                  fontFamily: 'Roboto Flex',
                ),
              ),
            ),
            SvgPicture.asset(
              'assets/images/calendar.svg',
              width: 18,
              height: 18,
            ),
          ],
        ),
      ),
    );
  }
}
