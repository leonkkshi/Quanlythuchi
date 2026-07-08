import 'package:flutter/material.dart';
import 'package:iconly/iconly.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../../application/services/auth_service_impl.dart';
import '../viewmodels/register_view_model.dart';
import '../../../../app/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> with SingleTickerProviderStateMixin {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmPasswordController = TextEditingController();
  
  bool _obscurePassword = true;
  bool _obscureConfirmPassword = true;
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    );
    _fadeAnimation = CurvedAnimation(
      parent: _fadeController,
      curve: Curves.easeOut,
    );
    _fadeController.forward();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _confirmPasswordController.dispose();
    _fadeController.dispose();
    super.dispose();
  }

  void _submit(RegisterViewModel viewModel) async {
    if (_formKey.currentState!.validate()) {
      final success = await viewModel.register(
        _nameController.text,
        _emailController.text,
        _passwordController.text,
        _confirmPasswordController.text,
      );
      if (success && mounted) {
        // Show success and redirect to home screen
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: const Text('Đăng ký tài khoản thành công!'),
            backgroundColor: Theme.of(context).colorScheme.secondary,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
        );
        context.go(AppRouter.home);
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.colorScheme.primary;
    final borderColor = theme.colorScheme.outlineVariant;

    return ChangeNotifierProvider<RegisterViewModel>(
      create: (context) => RegisterViewModel(
        authService: Provider.of<AuthServiceImpl>(context, listen: false),
      ),
      child: Consumer<RegisterViewModel>(
        builder: (context, viewModel, child) {
          if (viewModel.errorMessage != null) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(viewModel.errorMessage!),
                  backgroundColor: Colors.redAccent,
                  behavior: SnackBarBehavior.floating,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
              );
              viewModel.clearError();
            });
          }

          return Scaffold(
            backgroundColor: AppColors.canvasDark,
            body: SafeArea(
              child: Center(
                child: SingleChildScrollView(
                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
                  child: FadeTransition(
                    opacity: _fadeAnimation,
                    child: Form(
                      key: _formKey,
                      child: Column(
                        mainAxisSize: MainAxisSize.min,
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          Container(
                            width: 72,
                            height: 72,
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCardDark,
                              borderRadius: BorderRadius.circular(18),
                            ),
                            child: Icon(
                              IconlyBold.add_user,
                              color: primaryColor,
                              size: 32,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Text(
                            'TẠO TÀI KHOẢN',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.titleLarge?.copyWith(
                              color: AppColors.onDark,
                              fontWeight: FontWeight.w800,
                            ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Khởi đầu hành trình quản lý tài chính thông minh',
                            textAlign: TextAlign.center,
                            style: theme.textTheme.bodyMedium?.copyWith(
                              color: AppColors.mutedStrong,
                              height: 1.5,
                            ),
                          ),
                          const SizedBox(height: 32),
                          Container(
                            padding: const EdgeInsets.all(24),
                            decoration: BoxDecoration(
                              color: AppColors.surfaceCardDark,
                              borderRadius: BorderRadius.circular(16),
                              border: Border.all(color: borderColor),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.stretch,
                              children: [
                                Text(
                                  'Thông tin cá nhân',
                                  style: theme.textTheme.titleMedium?.copyWith(
                                    color: AppColors.onDark,
                                    fontWeight: FontWeight.w700,
                                  ),
                                ),
                                const SizedBox(height: 20),
                                TextFormField(
                                  controller: _nameController,
                                  keyboardType: TextInputType.name,
                                  enabled: !viewModel.isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Họ và tên',
                                    hintText: 'Nhập họ tên đầy đủ',
                                    prefixIcon: Icon(IconlyLight.profile),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập họ tên';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _emailController,
                                  keyboardType: TextInputType.emailAddress,
                                  enabled: !viewModel.isLoading,
                                  decoration: const InputDecoration(
                                    labelText: 'Email',
                                    hintText: 'Nhập địa chỉ email',
                                    prefixIcon: Icon(IconlyLight.message),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập email';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _passwordController,
                                  obscureText: _obscurePassword,
                                  enabled: !viewModel.isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Mật khẩu',
                                    hintText: 'Nhập mật khẩu (tối thiểu 6 ký tự)',
                                    prefixIcon: const Icon(IconlyLight.lock),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscurePassword
                                            ? IconlyLight.hide
                                            : IconlyLight.show,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscurePassword = !_obscurePassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng nhập mật khẩu';
                                    }
                                    if (value.length < 6) {
                                      return 'Mật khẩu phải chứa ít nhất 6 ký tự';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 16),
                                TextFormField(
                                  controller: _confirmPasswordController,
                                  obscureText: _obscureConfirmPassword,
                                  enabled: !viewModel.isLoading,
                                  decoration: InputDecoration(
                                    labelText: 'Xác nhận mật khẩu',
                                    hintText: 'Nhập lại mật khẩu',
                                    prefixIcon: const Icon(IconlyBold.password),
                                    suffixIcon: IconButton(
                                      icon: Icon(
                                        _obscureConfirmPassword
                                            ? IconlyLight.hide
                                            : IconlyLight.show,
                                      ),
                                      onPressed: () {
                                        setState(() {
                                          _obscureConfirmPassword = !_obscureConfirmPassword;
                                        });
                                      },
                                    ),
                                  ),
                                  validator: (value) {
                                    if (value == null || value.trim().isEmpty) {
                                      return 'Vui lòng xác nhận mật khẩu';
                                    }
                                    if (value != _passwordController.text) {
                                      return 'Mật khẩu xác nhận không khớp';
                                    }
                                    return null;
                                  },
                                ),
                                const SizedBox(height: 24),
                                ElevatedButton(
                                  onPressed: viewModel.isLoading ? null : () => _submit(viewModel),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: primaryColor,
                                    foregroundColor: AppColors.onPrimary,
                                    minimumSize: const Size.fromHeight(52),
                                    shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                  child: viewModel.isLoading
                                      ? const SizedBox(
                                          height: 24,
                                          width: 24,
                                          child: CircularProgressIndicator(
                                            color: AppColors.onPrimary,
                                            strokeWidth: 2.5,
                                          ),
                                        )
                                      : const Text('ĐĂNG KÝ'),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 24),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                'Đã có tài khoản? ',
                                style: theme.textTheme.bodyMedium?.copyWith(
                                  color: AppColors.mutedStrong,
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  context.go(AppRouter.login);
                                },
                                child: Text(
                                  'Đăng nhập ngay',
                                  style: theme.textTheme.bodyMedium?.copyWith(
                                    color: primaryColor,
                                    fontWeight: FontWeight.w700,
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
            ),
          );
        },
      ),
    );
  }
}
