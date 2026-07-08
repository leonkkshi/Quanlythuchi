import 'package:flutter/material.dart';
import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/auth/presentation/views/forgot_password_page.dart';
import '../../features/home/presentation/views/main_navigation_shell.dart';
import '../../features/category/presentation/views/category_management_page.dart';
import '../../features/category/presentation/views/create_category_page.dart';
import '../../features/auth/presentation/views/pin_lock_screen.dart';

class AppRoutes {
  static const String login = '/login';
  static const String register = '/register';
  static const String forgotPassword = '/forgot-password';
  static const String home = '/home';
  static const String categories = '/categories';
  static const String createCategory = '/create-category';
  static const String pinLock = '/pin-lock';

  static Route<dynamic> onGenerateRoute(RouteSettings settings) {
    switch (settings.name) {
      case login:
        return MaterialPageRoute(
          builder: (_) => const LoginPage(),
          settings: settings,
        );
      case register:
        return MaterialPageRoute(
          builder: (_) => const RegisterPage(),
          settings: settings,
        );
      case forgotPassword:
        return MaterialPageRoute(
          builder: (_) => const ForgotPasswordPage(),
          settings: settings,
        );
      case home:
        return MaterialPageRoute(
          builder: (_) => const MainNavigationShell(),
          settings: settings,
        );
      case categories:
        return MaterialPageRoute(
          builder: (_) => const CategoryManagementPage(),
          settings: settings,
        );
      case createCategory:
        final args = settings.arguments as Map<String, dynamic>? ?? {};
        final type = args['type'] as String? ?? 'expense';
        final userId = args['userId'] as String? ?? '';
        return MaterialPageRoute(
          builder: (_) => CreateCategoryPage(type: type, userId: userId),
          settings: settings,
        );
      case pinLock:
        return MaterialPageRoute(
          builder: (_) => const PinLockScreen(),
          settings: settings,
        );
      default:
        return MaterialPageRoute(
          builder: (_) => Scaffold(
            body: Center(
              child: Text('Không tìm thấy trang: ${settings.name}'),
            ),
          ),
        );
    }
  }
}
