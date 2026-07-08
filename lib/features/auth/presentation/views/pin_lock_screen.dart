import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../../../app/routes/app_router.dart';
import '../../../../core/theme/app_theme.dart';

class PinLockScreen extends StatefulWidget {
  const PinLockScreen({super.key});

  @override
  State<PinLockScreen> createState() => _PinLockScreenState();
}

class _PinLockScreenState extends State<PinLockScreen> {
  final List<int> _pin = [];
  String _errorMessage = '';
  bool _isWrong = false;

  void _onKeyPress(int number) {
    if (_pin.length < 4) {
      setState(() {
        _pin.add(number);
        _errorMessage = '';
        _isWrong = false;
      });
    }

    if (_pin.length == 4) {
      _verifyPin();
    }
  }

  void _onDelete() {
    if (_pin.isNotEmpty) {
      setState(() {
        _pin.removeLast();
        _errorMessage = '';
        _isWrong = false;
      });
    }
  }

  Future<void> _verifyPin() async {
    final prefs = await SharedPreferences.getInstance();
    final savedPin = prefs.getString('app_lock_pin') ?? '';
    final currentPinStr = _pin.join('');

    if (currentPinStr == savedPin) {
      if (mounted) {
        context.go(AppRouter.home);
      }
    } else {
      setState(() {
        _pin.clear();
        _isWrong = true;
        _errorMessage = 'Mã PIN chưa chính xác!';
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;
    final accent = AppColors.primary;
    final background = isDark ? AppColors.canvasDark : AppColors.canvasLight;
    final onBackground = theme.colorScheme.onBackground;
    final muted = AppColors.mutedStrong;
    final errorColor = AppColors.tradingDown;

    return Scaffold(
      backgroundColor: background,
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.lock_rounded,
              size: 64,
              color: accent,
            ),
            const SizedBox(height: 24),
            Text(
              'Nhập mã PIN mở khóa',
              style: theme.textTheme.titleLarge?.copyWith(
                fontWeight: FontWeight.bold,
                color: onBackground,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Để truy cập ứng dụng Quản lý Thu Chi',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: muted,
              ),
            ),
            const SizedBox(height: 40),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 12),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isWrong ? errorColor : accent,
                      width: 2,
                    ),
                    color: filled ? (_isWrong ? errorColor : accent) : Colors.transparent,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: theme.textTheme.bodyMedium?.copyWith(
                  color: errorColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            const Spacer(),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        final val = i * 3 + index + 1;
                        return _buildKey(val, theme);
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const SizedBox(width: 72, height: 72),
                      _buildKey(0, theme),
                      _buildDeleteKey(theme),
                    ],
                  ),
                ],
              ),
            ),
            const Spacer(),
          ],
        ),
      ),
    );
  }

  Widget _buildKey(int value, ThemeData theme) {
    final isDark = theme.brightness == Brightness.dark;

    return SizedBox(
      width: 72,
      height: 72,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(
            color: isDark ? AppColors.hairlineOnDark : AppColors.hairlineOnLight,
            width: 1.5,
          ),
          backgroundColor: theme.colorScheme.surface,
        ),
        onPressed: () => _onKeyPress(value),
        child: Text(
          '$value',
          style: theme.textTheme.titleLarge?.copyWith(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: theme.colorScheme.onSurface,
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(ThemeData theme) {
    return SizedBox(
      width: 72,
      height: 72,
      child: IconButton(
        icon: Icon(
          Icons.backspace_outlined,
          size: 26,
          color: theme.colorScheme.onSurface.withOpacity(0.72),
        ),
        onPressed: _onDelete,
      ),
    );
  }
}
