import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

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
        Navigator.pushReplacementNamed(context, '/home');
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

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF8FAFC),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            Icon(
              Icons.lock_rounded,
              size: 64,
              color: Colors.orange[800] ?? Colors.orange,
            ),
            const SizedBox(height: 24),
            Text(
              'Nhập mã PIN mở khóa',
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E293B),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Để truy cập ứng dụng Quản lý Thu Chi',
              style: TextStyle(
                fontSize: 14,
                color: isDark ? const Color(0xFF64748B) : const Color(0xFF475569),
              ),
            ),
            const SizedBox(height: 40),
            // Passcode Dots
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(4, (index) {
                final filled = index < _pin.length;
                return AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  margin: const EdgeInsets.symmetric(horizontal: 16),
                  width: 20,
                  height: 20,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: _isWrong
                          ? Colors.red
                          : (Colors.orange[800] ?? Colors.orange),
                      width: 2,
                    ),
                    color: filled
                        ? (_isWrong ? Colors.red : (Colors.orange[800] ?? Colors.orange))
                        : Colors.transparent,
                  ),
                );
              }),
            ),
            const SizedBox(height: 16),
            if (_errorMessage.isNotEmpty)
              Text(
                _errorMessage,
                style: const TextStyle(color: Colors.red, fontWeight: FontWeight.bold),
              ),
            const Spacer(),
            // Numeric Keypad
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 40),
              child: Column(
                children: [
                  for (var i = 0; i < 3; i++) ...[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: List.generate(3, (index) {
                        final val = i * 3 + index + 1;
                        return _buildKey(val, isDark);
                      }),
                    ),
                    const SizedBox(height: 16),
                  ],
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      // Empty placeholder
                      const SizedBox(width: 72, height: 72),
                      _buildKey(0, isDark),
                      _buildDeleteKey(isDark),
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

  Widget _buildKey(int value, bool isDark) {
    return SizedBox(
      width: 72,
      height: 72,
      child: OutlinedButton(
        style: OutlinedButton.styleFrom(
          shape: const CircleBorder(),
          side: BorderSide(
            color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
            width: 1.5,
          ),
          backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.white,
        ),
        onPressed: () => _onKeyPress(value),
        child: Text(
          '$value',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.bold,
            color: isDark ? Colors.white : const Color(0xFF1E293B),
          ),
        ),
      ),
    );
  }

  Widget _buildDeleteKey(bool isDark) {
    return SizedBox(
      width: 72,
      height: 72,
      child: IconButton(
        icon: Icon(
          Icons.backspace_outlined,
          size: 26,
          color: isDark ? const Color(0xFF94A3B8) : const Color(0xFF475569),
        ),
        onPressed: _onDelete,
      ),
    );
  }
}
