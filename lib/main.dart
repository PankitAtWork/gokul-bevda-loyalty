// lib/main.dart
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'utils/theme.dart';
import 'config/api_config.dart';
import 'services/api_service.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'screens/auth_screen.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  // Initialize ApiService + AuthService here.
  // Replace the baseUrl with your real backend URL.
  final apiService = ApiService.create(baseUrl: ApiConfig.baseUrl);
  final authService = AuthService(apiService);

  runApp(MyApp(authService: authService));
}

class MyApp extends StatelessWidget {
  final AuthService authService;
  const MyApp({Key? key, required this.authService}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<AuthProvider>(
      create: (_) => AuthProvider(authService),
      child: MaterialApp(
        title: 'Auth App',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.light(),
        // Start with a small Splash that decides where to navigate
        home: const SplashScreen(),
        routes: {
          '/auth': (_) => const AuthScreen(),
          '/home': (_) => const HomeScreen(),
        },
      ),
    );
  }
}
