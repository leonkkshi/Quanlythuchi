import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'app/app.dart';
import 'app/routes/app_router.dart';
import 'features/auth/data/datasources/auth_local_data_source_impl.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  String initialLocation = AppRouter.login;

  try {
    final localDataSource = AuthLocalDataSourceImpl();
    final token = await localDataSource.getToken();
    if (token != null && token.isNotEmpty) {
      initialLocation = AppRouter.home;

      final prefs = await SharedPreferences.getInstance();
      final pinEnabled = prefs.getBool('app_lock_enabled') ?? false;
      final pinCode = prefs.getString('app_lock_pin') ?? '';
      if (pinEnabled && pinCode.isNotEmpty) {
        initialLocation = AppRouter.pinLock;
      }
    }
  } catch (_) {
    // Fallback to login screen on local storage retrieval error
  }

  runApp(MyApp(initialLocation: initialLocation));
}
