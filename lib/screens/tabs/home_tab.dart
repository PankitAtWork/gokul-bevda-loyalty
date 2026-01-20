import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:provider/provider.dart';
import '../../providers/auth_provider.dart';
import '../../config/api_config.dart';
import '../../utils/theme.dart';
import '../../models/points_data.dart';
import '../../models/special_offer.dart';
import '../../models/recent_activity.dart';
import '../../services/api_service.dart';
import 'package:intl/intl.dart';

class HomeTabContent extends StatefulWidget {
  final Function(int)? onNavigateToTab;

  const HomeTabContent({super.key, this.onNavigateToTab});

  @override
  State<HomeTabContent> createState() => _HomeTabContentState();
}

class _HomeTabContentState extends State<HomeTabContent> {
  final ApiService _apiService = ApiService.create(baseUrl: ApiConfig.baseUrl);

  PointsData? _pointsData;
  List<RecentActivity> _activities = [];

  @override
  void initState() {
    super.initState();
    _loadData();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<AuthProvider>(context, listen: false).fetchDashboard(context);
    });
  }

  Future<void> _loadData() async {
    // Load points
    _apiService.getUserPoints().then((data) {
      if (mounted) {
        setState(() {
          _pointsData = data;
        });
      }
    });

    // Load activity
    _apiService.getRecentActivity().then((activities) {
      if (mounted) {
        setState(() {
          _activities = activities;
        });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final dashboardData = auth.dashboardData;
    final isLoadingDashboard = auth.loadingDashboard;

    // Use dashboard points if available, otherwise fallback to _pointsData
    final displayPoints =
        dashboardData?.customerPoints ?? _pointsData?.points ?? 0;

    return Container(
      color: AppTheme.bg,
      child: SafeArea(
        child: RefreshIndicator(
          onRefresh: () async {
            await auth.fetchDashboard(context);
            await _loadData();
          },
          child: SingleChildScrollView(
            physics: const AlwaysScrollableScrollPhysics(),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Your Points Section
                _buildPointsSection(displayPoints, isLoadingDashboard),

                const SizedBox(height: 20),

                // Special Offers Section
                _buildSpecialOffersSection(auth),

                const SizedBox(height: 20),

                // Recent Activity Section
                _buildRecentActivitySection(auth),

                const SizedBox(height: 20),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPointsSection(int points, bool loading) {
    return Container(
      margin: const EdgeInsets.all(0),
      decoration: BoxDecoration(
        color: Colors.black,
        borderRadius: BorderRadius.circular(0),
      ),
      child: Stack(
        children: [
          // Red gradient overlay
          Positioned(
            top: 0,
            left: 0,
            right: 0,
            height: 120,
            child: SvgPicture.asset(
              'assets/images/intersect.svg',
              width: double.infinity,
              height: 80,
              fit: BoxFit.cover,
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      width: 60,
                      height: 60,
                      child: Stack(
                        clipBehavior: Clip.none,
                        children: [
                          Positioned.fill(
                            child: Opacity(
                              opacity: 0.3,
                              child: SvgPicture.asset(
                                'assets/images/trans_points_bg.svg',
                                fit: BoxFit.contain,
                              ),
                            ),
                          ),
                          Positioned(
                            top: 25,
                            left: 0,
                            right: 0,
                            child: Center(
                              child: SvgPicture.asset(
                                'assets/images/points_icn.svg',
                                width: 50,
                                height: 50,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Padding(
                            padding: const EdgeInsets.only(top: 25),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const Text(
                                  'Your Points',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    fontFamily: 'Roboto Flex',
                                  ),
                                ),
                                if (!loading)
                                  Container(
                                    decoration: BoxDecoration(
                                      gradient: const LinearGradient(
                                        begin: Alignment.centerLeft,
                                        end: Alignment.centerRight,
                                        colors: [
                                          Color(0x26FFFFFF),
                                          Color(0x26FFFFFF),
                                        ],
                                      ),
                                      borderRadius: BorderRadius.circular(12),
                                    ),
                                    child: Material(
                                      color: Colors.transparent,
                                      child: InkWell(
                                        onTap: () {},
                                        borderRadius: BorderRadius.circular(8),
                                        child: Container(
                                          padding: const EdgeInsets.symmetric(
                                            horizontal: 10,
                                            vertical: 5,
                                          ),
                                          child: const Text(
                                            'Redeem points',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontSize: 12,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: 'Roboto Flex',
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                if (loading)
                                  const SizedBox(
                                    width: 20,
                                    height: 20,
                                    child: CircularProgressIndicator(
                                      strokeWidth: 2,
                                      valueColor: AlwaysStoppedAnimation<Color>(
                                        Colors.white,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                          if (!loading)
                            Text(
                              '$points Points >',
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                                fontWeight: FontWeight.bold,
                                fontFamily: 'Roboto Flex',
                              ),
                            ),
                        ],
                      ),
                    ),
                  ],
                ),
                if (loading)
                  const SizedBox(
                    height: 40,
                    child: Center(
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                      ),
                    ),
                  )
                else if (_pointsData != null) ...[
                  const SizedBox(height: 40),
                  Center(
                    child: IntrinsicWidth(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Text(
                                'Complete ${_pointsData!.totalMissions} missions to become Platinum member',
                                textAlign: TextAlign.center,
                                style: const TextStyle(
                                  color: Color(0xFFFFF3D1),
                                  fontSize: 12,
                                  fontFamily: 'Roboto Flex',
                                ),
                              ),
                              const SizedBox(width: 8),
                              SvgPicture.asset(
                                'assets/images/gray_badgee.svg',
                                width: 20,
                                height: 20,
                              ),
                            ],
                          ),
                          const SizedBox(height: 4),
                          Text(
                            'You\'ve completed ${_pointsData!.completedMissions} missions',
                            textAlign: TextAlign.start,
                            style: const TextStyle(
                              color: Color(0xFFFFF3D1),
                              fontSize: 10,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSpecialOffersSection(AuthProvider auth) {
    final dashboardOffers = auth.dashboardData?.offers ?? [];
    final isLoading = auth.loadingDashboard;

    // Map DashboardOffer to SpecialOffer
    final offers = dashboardOffers
        .map(
          (o) => SpecialOffer(
            id: o.saleId.toString(),
            title: o.saleName,
            description: o.note ?? o.promoTargetName ?? '',
            category: o.targetTypeDesc ?? 'Special Offer',
            availability: 'All Stores',
            expires: o.endDate?.split('T').first ?? 'N/A',
            tag: 'Limited Time',
            type: 'all',
            iconType: 'bottle',
            stores: [],
          ),
        )
        .toList();

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lightRed, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/flash_sale.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Special Offers',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkRed,
                      fontFamily: 'Roboto Flex',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onNavigateToTab != null) {
                            widget.onNavigateToTab!(2);
                          }
                        },
                        child: const Text(
                          'View All Offers',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading && offers.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            )
          else if (offers.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No offers available',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
            )
          else
            ...offers.map((offer) => _buildOfferCard(offer)),
        ],
      ),
    );
  }

  Widget _buildOfferCard(SpecialOffer offer) {
    return Container(
      margin: const EdgeInsets.only(bottom: 12),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lightRed, width: 1),
      ),
      child: Row(
        children: [
          Container(
            width: 43,
            height: 43,
            child: Stack(
              children: [
                Positioned.fill(
                  child: SvgPicture.asset(
                    'assets/images/red_round.svg',
                    fit: BoxFit.cover,
                  ),
                ),
                Center(
                  child: offer.iconType == 'percentage'
                      ? SvgPicture.asset(
                          'assets/images/percentage.svg',
                          width: 15,
                          height: 15,
                        )
                      : SvgPicture.asset(
                          'assets/images/celebration.svg',
                          width: 20,
                          height: 20,
                        ),
                ),
              ],
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  offer.title,
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w700,
                    color: AppTheme.darkRed,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  offer.description.isNotEmpty
                      ? offer.description
                      : offer.category,
                  style: TextStyle(
                    fontSize: 11,
                    color: AppTheme.unselected_tab_color,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentActivitySection(AuthProvider auth) {
    final dashboardTxns = auth.dashboardData?.transactions ?? [];
    final isLoading = auth.loadingDashboard;

    // Map DashboardTransaction to RecentActivity
    final activities = dashboardTxns.map((t) {
      final pointsValue = (t.collectedPoint ?? 0);
      final isEarned = pointsValue > 0;

      // Format date: "July 28, 2023 • 6:42 PM"
      String formattedDate = '';
      try {
        final date = DateTime.parse(t.txnDate);
        formattedDate = DateFormat("MMMM d, yyyy '•' h:mm a").format(date);
      } catch (e) {
        formattedDate = t.txnDate; // Fallback to raw string if parsing fails
      }

      return RecentActivity(
        id: t.txnId,
        type: isEarned ? 'Points Earned' : 'Points Redeemed',
        description: 'Purchase at NO DATA FOUND',
        date: formattedDate,
        time: '', // Time is now included in the formattedDate string
        points: pointsValue.abs().toInt(),
        isPositive: isEarned,
      );
    }).toList();

    // If dashboard activities empty but we have mock activities, use those for visual filler if desired,
    // but better to show real data.
    final displayActivities = activities.isNotEmpty ? activities : _activities;

    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 16),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: AppTheme.lightRed, width: 1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  SvgPicture.asset(
                    'assets/images/recent.svg',
                    width: 20,
                    height: 20,
                  ),
                  const SizedBox(width: 8),
                  const Text(
                    'Recent Activity',
                    style: TextStyle(
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                      color: AppTheme.darkRed,
                      fontFamily: 'Roboto Flex',
                    ),
                  ),
                ],
              ),
              Row(
                children: [
                  if (isLoading)
                    const SizedBox(
                      width: 16,
                      height: 16,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        valueColor: AlwaysStoppedAnimation<Color>(
                          AppTheme.primary,
                        ),
                      ),
                    )
                  else
                    Container(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 6,
                      ),
                      decoration: BoxDecoration(
                        color: AppTheme.darkRed,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: GestureDetector(
                        onTap: () {
                          if (widget.onNavigateToTab != null) {
                            widget.onNavigateToTab!(3);
                          }
                        },
                        child: const Text(
                          'View All Activity',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 10,
                            fontWeight: FontWeight.w500,
                            fontFamily: 'Roboto Flex',
                          ),
                        ),
                      ),
                    ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 16),
          if (isLoading && displayActivities.isEmpty)
            const SizedBox(
              height: 100,
              child: Center(
                child: CircularProgressIndicator(
                  valueColor: AlwaysStoppedAnimation<Color>(AppTheme.primary),
                ),
              ),
            )
          else if (displayActivities.isEmpty)
            const Center(
              child: Padding(
                padding: EdgeInsets.all(20),
                child: Text(
                  'No recent activity',
                  style: TextStyle(
                    color: Colors.grey,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
              ),
            )
          else
            ...displayActivities.asMap().entries.map((entry) {
              final index = entry.key;
              final activity = entry.value;
              return Column(
                children: [
                  _buildActivityItem(activity),
                  if (index < displayActivities.length - 1)
                    Divider(color: AppTheme.lightRed, thickness: 1, height: 1),
                ],
              );
            }),
        ],
      ),
    );
  }

  Widget _buildActivityItem(RecentActivity activity) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  activity.type,
                  style: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    color: AppTheme.darkRed2,
                    fontFamily: 'Roboto Flex',
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  activity.description,
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.unselected_tab_color,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w400,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${activity.date}${activity.time.isNotEmpty ? ' • ${activity.time}' : ''}',
                  style: TextStyle(
                    fontSize: 13,
                    color: AppTheme.unselected_tab_color,
                    fontFamily: 'Roboto Flex',
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ],
            ),
          ),
          Text(
            '${activity.isPositive ? '+' : '-'}${activity.points} pts',
            style: TextStyle(
              fontSize: 15,
              fontWeight: FontWeight.w900,
              color: activity.isPositive
                  ? AppTheme.darkGreen
                  : AppTheme.primary,
              fontFamily: 'Roboto Flex',
            ),
          ),
        ],
      ),
    );
  }
}
