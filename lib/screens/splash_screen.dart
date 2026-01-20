import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'package:provider/provider.dart';

import '../providers/auth_provider.dart';
import '../utils/theme.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    SystemChrome.setEnabledSystemUIMode(SystemUiMode.immersive);
    _goNext();
  }

  Future<void> _goNext() async {
    // Show splash for 4 seconds
    await Future.delayed(const Duration(seconds: 3));

    if (!mounted) return;

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final token = await auth.loadToken();

    if (!mounted) return;

    SystemChrome.setEnabledSystemUIMode(SystemUiMode.edgeToEdge);

    if (token != null && token.isNotEmpty) {
      Navigator.pushReplacementNamed(context, '/home');
    } else {
      Navigator.pushReplacementNamed(context, '/auth');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.splashColor,
      body: Center(
        child: Image.asset(
          'assets/images/splash_logo.png', // Converted from SVG
          width: 180,
          fit: BoxFit.contain,
        ),
      ),
    );
  }
}
