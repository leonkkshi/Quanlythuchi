import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:iconly/iconly.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';

import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../application/providers/savings_provider.dart';

class SavingsPage extends StatefulWidget {
  const SavingsPage({super.key});

  @override
  State<SavingsPage> createState() => _SavingsPageState();
}

class _SavingsPageState extends State<SavingsPage> {
  final _currencyFormatter = NumberFormat.currency(locale: 'vi_VN', symbol: 'đ');

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      final authService = Provider.of<AuthServiceImpl>(context, listen: false);
      final user = await authService.getCurrentUser();
      if (user != null && mounted) {
        Provider.of<SavingsProvider>(context, listen: false).loadGoals(user.id);
      }
    });
  }

  Color _getColorFromHex(String? hexColor) {
    if (hexColor == null || hexColor.isEmpty) return Colors.blueAccent;
    final hex = hexColor.replaceAll('#', '');
    try {
      return Color(int.parse('FF$hex', radix: 16));
    } catch (_) {
      return Colors.blueAccent;
    }
  }

  void _showAddFundsDialog(BuildContext context, String goalId, String goalName) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (_) {
        return AlertDialog(
          title: Text('Nạp tiền vào: $goalName'),
          content: TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            decoration: const InputDecoration(
              hintText: 'Nhập số tiền',
              suffixText: 'đ',
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () async {
                final amount = double.tryParse(controller.text) ?? 0;
                if (amount > 0) {
                  final authService = Provider.of<AuthServiceImpl>(context, listen: false);
                  final user = await authService.getCurrentUser();
                  if (user != null && context.mounted) {
                    final success = await Provider.of<SavingsProvider>(context, listen: false)
                        .addFunds(goalId, amount, user.id);
                    if (success && context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        const SnackBar(content: Text('Nạp tiền thành công!')),
                      );
                    }
                  }
                }
                if (context.mounted) Navigator.pop(context);
              },
              child: const Text('Nạp tiền'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mục tiêu tiết kiệm', style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: Consumer<SavingsProvider>(
        builder: (context, provider, child) {
          if (provider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          if (provider.goals.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(IconlyLight.wallet, size: 64, color: Colors.grey.withOpacity(0.5)),
                  const SizedBox(height: 16),
                  const Text('Chưa có mục tiêu tiết kiệm nào', style: TextStyle(color: Colors.grey)),
                ],
              ),
            );
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.goals.length,
            separatorBuilder: (context, index) => const SizedBox(height: 16),
            itemBuilder: (context, index) {
              final goal = provider.goals[index];
              final color = _getColorFromHex(goal.colorHex);
              final progress = goal.progressPercentage;

              return Card(
                elevation: 0,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                  side: BorderSide(
                    color: isDark ? const Color(0xFF334155) : const Color(0xFFE2E8F0),
                  ),
                ),
                color: isDark ? const Color(0xFF1E293B) : Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              goal.name,
                              style: const TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                              ),
                              overflow: TextOverflow.ellipsis,
                            ),
                          ),
                          IconButton(
                            icon: const Icon(IconlyLight.plus, color: Colors.green),
                            onPressed: () => _showAddFundsDialog(context, goal.id, goal.name),
                            tooltip: 'Nạp tiền',
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            _currencyFormatter.format(goal.currentAmount),
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w600,
                              color: color,
                            ),
                          ),
                          Text(
                            _currencyFormatter.format(goal.targetAmount),
                            style: const TextStyle(
                              fontSize: 14,
                              color: Colors.grey,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(8),
                        child: LinearProgressIndicator(
                          value: progress,
                          backgroundColor: color.withOpacity(0.15),
                          valueColor: AlwaysStoppedAnimation<Color>(color),
                          minHeight: 8,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            '${(progress * 100).toStringAsFixed(1)}%',
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.bold,
                              color: color,
                            ),
                          ),
                          if (goal.deadline != null && goal.deadline!.isNotEmpty)
                            Text(
                              'Đáo hạn: ${goal.deadline}',
                              style: const TextStyle(fontSize: 12, color: Colors.grey),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => context.push('/savings/add'),
        icon: const Icon(IconlyLight.plus),
        label: const Text('Thêm mục tiêu'),
      ),
    );
  }
}
