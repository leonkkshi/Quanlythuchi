// lib/app/routes/app_router.dart

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import '../../features/auth/presentation/views/forgot_password_page.dart';
import '../../features/auth/presentation/views/login_page.dart';
import '../../features/auth/presentation/views/pin_lock_screen.dart';
import '../../features/auth/presentation/views/register_page.dart';
import '../../features/category/presentation/views/category_management_page.dart';
import '../../features/category/presentation/views/create_category_page.dart';
import '../../features/home/presentation/views/main_navigation_shell.dart';
import '../../features/profile/presentation/pages/edit_profile_page.dart';
import '../../features/profile/presentation/pages/profile_page.dart';

/// Cấu hình GoRouter cho toàn bộ ứng dụng.
class AppRouter {
  static const login = '/login';
  static const register = '/register';
  static const forgotPassword = '/forgot-password';
  static const home = '/home';
  static const categories = '/categories';
  static const createCategory = '/create-category';
  static const pinLock = '/pin-lock';
  static const profile = '/profile';
  static const editProfile = '/profile/edit';

  static GoRouter createRouter({required String initialLocation}) {
    return GoRouter(
      initialLocation: initialLocation,
      routes: [
        GoRoute(
          path: login,
          builder: (context, state) => const LoginPage(),
        ),
        GoRoute(
          path: register,
          builder: (context, state) => const RegisterPage(),
        ),
        GoRoute(
          path: forgotPassword,
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: home,
          builder: (context, state) => const MainNavigationShell(),
        ),
        GoRoute(
          path: categories,
          builder: (context, state) => const CategoryManagementPage(),
        ),
        GoRoute(
          path: createCategory,
          builder: (context, state) {
            final args = state.extra as Map<String, dynamic>? ?? {};
            return CreateCategoryPage(
              type: args['type'] as String? ?? 'expense',
              userId: args['userId'] as String? ?? '',
            );
          },
        ),
        GoRoute(
          path: pinLock,
          builder: (context, state) => const PinLockScreen(),
        ),
        GoRoute(
          path: profile,
          builder: (context, state) => const ProfilePage(),
        ),
        GoRoute(
          path: editProfile,
          builder: (context, state) => const EditProfilePage(),
        ),
      ],
      errorBuilder: (context, state) => Scaffold(
        body: Center(
          child: Text('Không tìm thấy trang: ${state.uri}'),
        ),
      ),
    );
  }
}
