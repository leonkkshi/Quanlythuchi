import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'app/app.dart';
import 'app/routes/app_routes.dart';
import 'features/auth/data/datasources/auth_local_data_source_impl.dart';

void main() async {
  // Ensure Flutter bindings are initialized before calling async platform services
  WidgetsFlutterBinding.ensureInitialized();

  // Check authentication status to determine starting screen
  String initialRoute = AppRoutes.login;
  
  try {
    final localDataSource = AuthLocalDataSourceImpl();
    final token = await localDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      initialRoute = AppRoutes.home;
      
      final prefs = await SharedPreferences.getInstance();
      final pinEnabled = prefs.getBool('app_lock_enabled') ?? false;
      final pinCode = prefs.getString('app_lock_pin') ?? '';
      if (pinEnabled && pinCode.isNotEmpty) {
        initialRoute = AppRoutes.pinLock;
      }
    }
  } catch (_) {
    // Fallback to login screen on local storage retrieval error
  }

  runApp(MyApp(initialRoute: initialRoute));
}
