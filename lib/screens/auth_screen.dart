// lib/screens/auth_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/theme.dart';
import '../../providers/auth_provider.dart';
import '../../screens/login_tab/login_with_pass.dart';
import '../../screens/login_tab/login_with_otp.dart';
import '../../screens/signup_tab/signup_details.dart';
import '../../screens/signup_tab/signup_password.dart';
import 'package:flutter_svg/flutter_svg.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({Key? key}) : super(key: key);

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  int _loginModeIndex = 0;
  final PageController _signupPageController = PageController(initialPage: 0);

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkAgeVerification();
    });
  }

  Future<void> _checkAgeVerification() async {
    final prefs = await SharedPreferences.getInstance();
    final isVerified = prefs.getBool('isAgeVerified') ?? false;
    if (!isVerified) {
      if (mounted) {
        _showAgeVerificationDialog();
      }
    }
  }

  void _showAgeVerificationDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        return PopScope(
          canPop: false,
          child: AlertDialog(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(16),
            ),
            title: const Text(
              'Age Verification',
              style: TextStyle(fontWeight: FontWeight.bold),
            ),
            content: const Text(
              'You must be 21 years or older to use this app and purchase alcohol.\n\n'
              'By continuing, you confirm that you are at least 21 years old and legally allowed to consume alcohol in your region.',
              style: TextStyle(fontSize: 16),
            ),
            actions: [
              TextButton(
                onPressed: () {
                  SystemNavigator.pop();
                },
                child: const Text(
                  'Exit',
                  style: TextStyle(color: Colors.red, fontSize: 16),
                ),
              ),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppTheme.primary,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                ),
                onPressed: () async {
                  final prefs = await SharedPreferences.getInstance();
                  await prefs.setBool('isAgeVerified', true);
                  if (mounted) {
                    Navigator.of(context).pop();
                  }
                },
                child: const Text(
                  'Yes, I am 21+',
                  style: TextStyle(color: Colors.white, fontSize: 16),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  @override
  void dispose() {
    _tabController.dispose();
    _signupPageController.dispose();
    super.dispose();
  }

  void _goToSignupPasswordPage() {
    _signupPageController.animateToPage(
      1,
      duration: const Duration(milliseconds: 320),
      curve: Curves.easeInOut,
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);
    final uiBlocked = auth.uiBlocked;

    return Scaffold(
      resizeToAvoidBottomInset: true, // shift when keyboard opens
      backgroundColor: AppTheme.primary,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                // Top red header with illustration placeholder
                SizedBox(
                  height: 250,
                  child: Stack(
                    children: [
                      // Illustration placeholder aligned top-right
                      Positioned(
                        child: SizedBox(
                          width: 250,
                          height: 250,
                          child: SvgPicture.asset(
                            'assets/images/login_logo.svg',
                            height: 250,
                            width: 250,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                const SizedBox(height: 12),

                // Expanded white card area — fills remaining screen height
                Expanded(
                  child: Container(
                    decoration: const BoxDecoration(
                      color: AppTheme.bg,
                      borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(38),
                        topRight: Radius.circular(38),
                      ),
                    ),
                    child: Column(
                      children: [
                        // Title
                        const SizedBox(height: 8),
                        const Padding(
                          padding: EdgeInsets.all(16),
                          child: Text(
                            'Login in to your account',
                            style: TextStyle(
                              fontSize: 25,
                              fontWeight: FontWeight.w500,
                              color: Colors.black,
                              fontFamily: 'Roboto Flex',
                            ),
                          ),
                        ),

                        // Tab bar
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 30),
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 20),
                            color: Colors.transparent,
                            child: Container(
                              color: Colors.transparent,
                              child: TabBar(
                                controller: _tabController,
                                labelColor: AppTheme.bg,
                                unselectedLabelColor:
                                    AppTheme.unselected_tab_color,
                                indicatorColor: Colors.transparent,
                                dividerColor: Colors.transparent,
                                dividerHeight: 0,
                                indicator: BoxDecoration(
                                  color: AppTheme.primary,
                                  borderRadius: BorderRadius.circular(18),
                                ),
                                indicatorPadding: const EdgeInsets.symmetric(
                                  horizontal: -40,
                                  vertical: 5,
                                ),
                                tabs: const [
                                  Tab(text: 'Login'),
                                  Tab(text: 'Sign Up'),
                                ],
                              ),
                            ),
                          ),
                        ),

                        const SizedBox(height: 15),

                        // Tab content fills remaining area of the white card
                        Expanded(
                          child: TabBarView(
                            controller: _tabController,
                            children: [
                              // LOGIN tab
                              // Use SingleChildScrollView so small screens / keyboard can scroll content
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    // ensure keyboard padding prevents overflow
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          24,
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    child: ConstrainedBox(
                                      // make the scrollable area take at least the available height so Expanded effects remain
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: IntrinsicHeight(
                                        child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.stretch,
                                          children: [
                                            const SizedBox(height: 8),
                                            Padding(
                                              padding:
                                                  const EdgeInsets.symmetric(
                                                    horizontal: 10,
                                                  ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.symmetric(
                                                      vertical: 18.0,
                                                      horizontal: 16,
                                                    ),
                                                child: Column(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    // Login mode toggle
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: () => setState(
                                                              () =>
                                                                  _loginModeIndex =
                                                                      0,
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 8,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: AppTheme
                                                                    .grayColor,
                                                                border: Border.all(
                                                                  color:
                                                                      _loginModeIndex ==
                                                                          0
                                                                      ? AppTheme
                                                                            .primary
                                                                      : Colors
                                                                            .transparent,
                                                                  width: 1.2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                              child: Center(
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(
                                                                        right:
                                                                            12,
                                                                        left:
                                                                            25,
                                                                      ), // <-- your padding
                                                                      child: SvgPicture.asset(
                                                                        _loginModeIndex ==
                                                                                0
                                                                            ? 'assets/images/lock_red.svg'
                                                                            : 'assets/images/lock_black.svg',
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20,
                                                                        colorFilter: ColorFilter.mode(
                                                                          _loginModeIndex ==
                                                                                  0
                                                                              ? AppTheme.primary
                                                                              : Colors.black,
                                                                          BlendMode
                                                                              .srcIn,
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    Text(
                                                                      'Password',
                                                                      style: TextStyle(
                                                                        color:
                                                                            _loginModeIndex ==
                                                                                0
                                                                            ? AppTheme.primary
                                                                            : Colors.black,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w400,
                                                                        fontFamily:
                                                                            'Roboto Flex',
                                                                      ),
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                        const SizedBox(
                                                          width: 6,
                                                        ),
                                                        Expanded(
                                                          child: GestureDetector(
                                                            onTap: () => setState(
                                                              () =>
                                                                  _loginModeIndex =
                                                                      1,
                                                            ),
                                                            child: Container(
                                                              padding:
                                                                  const EdgeInsets.symmetric(
                                                                    vertical: 8,
                                                                  ),
                                                              decoration: BoxDecoration(
                                                                color: AppTheme
                                                                    .grayColor,
                                                                border: Border.all(
                                                                  color:
                                                                      _loginModeIndex ==
                                                                          1
                                                                      ? AppTheme
                                                                            .primary
                                                                      : Colors
                                                                            .transparent,
                                                                  width: 1.2,
                                                                ),
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                      10,
                                                                    ),
                                                              ),
                                                              child: Center(
                                                                child: Row(
                                                                  children: [
                                                                    Padding(
                                                                      padding: const EdgeInsets.only(
                                                                        right:
                                                                            12,
                                                                        left:
                                                                            40,
                                                                      ), // <-- your padding
                                                                      child: SvgPicture.asset(
                                                                        _loginModeIndex ==
                                                                                1
                                                                            ? 'assets/images/phone_red.svg'
                                                                            : 'assets/images/phone_black.svg',
                                                                        width:
                                                                            20,
                                                                        height:
                                                                            20,
                                                                        colorFilter: ColorFilter.mode(
                                                                          _loginModeIndex ==
                                                                                  1
                                                                              ? AppTheme.primary
                                                                              : Colors.black,
                                                                          BlendMode
                                                                              .srcIn,
                                                                        ),
                                                                      ),
                                                                    ),

                                                                    Text(
                                                                      'OTP',
                                                                      style: TextStyle(
                                                                        color:
                                                                            _loginModeIndex ==
                                                                                1
                                                                            ? AppTheme.primary
                                                                            : Colors.black,
                                                                        fontSize:
                                                                            18,
                                                                        fontWeight:
                                                                            FontWeight.w500,
                                                                        fontFamily:
                                                                            'Roboto Flex',
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
                                                    const SizedBox(height: 16),

                                                    if (_loginModeIndex == 0)
                                                      const LoginPasswordWidget(),
                                                    if (_loginModeIndex == 1)
                                                      const LoginOtpWidget(),
                                                  ],
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),

                              // SIGN UP tab
                              // Let PageView expand to available height
                              LayoutBuilder(
                                builder: (context, constraints) {
                                  return SingleChildScrollView(
                                    padding: EdgeInsets.only(
                                      bottom:
                                          MediaQuery.of(
                                            context,
                                          ).viewInsets.bottom +
                                          24,
                                      left: 0,
                                      right: 0,
                                      top: 0,
                                    ),
                                    physics: const BouncingScrollPhysics(),
                                    child: ConstrainedBox(
                                      constraints: BoxConstraints(
                                        minHeight: constraints.maxHeight,
                                      ),
                                      child: SizedBox(
                                        // give PageView a bounded height so it can expand
                                        height: constraints.maxHeight,
                                        child: PageView(
                                          controller: _signupPageController,
                                          physics:
                                              const NeverScrollableScrollPhysics(),
                                          children: [
                                            SignupDetailWidget(
                                              onOtpVerified:
                                                  _goToSignupPasswordPage,
                                            ),
                                            SignupPasswordWidget(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  );
                                },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),

            // Global blocking overlay when UI is blocked
            if (uiBlocked)
              Positioned.fill(
                child: Container(
                  color: Colors.black26,
                  child: const Center(child: CircularProgressIndicator()),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
