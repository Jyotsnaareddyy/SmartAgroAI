import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'theme/app_theme.dart';
import 'screens/login_screen.dart';
import 'screens/main_navigation.dart';

import 'services/mock_api_service.dart';
import 'services/auth_service.dart';
import 'providers/auth_provider.dart';
import 'providers/farm_provider.dart';
import 'providers/device_provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Mock Services
  final mockApiService = MockApiService();
  final authService = AuthService();

  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider(authService)),
        ChangeNotifierProvider(create: (_) => FarmProvider(mockApiService)),
        ChangeNotifierProvider(create: (_) => DeviceProvider(mockApiService)),
      ],
      child: const SmartAgroApp(),
    ),
  );
}

class SmartAgroApp extends StatelessWidget {
  const SmartAgroApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'SmartAgro AI',
      theme: AppTheme.lightTheme,
      darkTheme: AppTheme.darkTheme,
      themeMode: ThemeMode.system,
      home: Consumer<AuthProvider>(
        builder: (context, auth, _) {
          return auth.isAuthenticated ? const MainNavigationScreen() : const LoginScreen();
        }
      ),
      debugShowCheckedModeBanner: false,
    );
  }
}
