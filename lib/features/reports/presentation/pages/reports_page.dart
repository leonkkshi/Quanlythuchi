// lib/features/reports/presentation/pages/reports_page.dart

import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../../../../features/auth/application/services/auth_service_impl.dart';
import '../../application/providers/report_provider.dart';
import '../../../settings/application/providers/settings_provider.dart';
import '../../../../widgets/async_state_view.dart';
import '../widgets/category_summary_list.dart';
import '../widgets/expense_pie_chart.dart';
import '../widgets/monthly_bar_chart.dart';
import '../widgets/report_filter_bar.dart';
import '../widgets/report_overview_card.dart';

/// Màn hình báo cáo thu chi.
class ReportsPage extends StatefulWidget {
  const ReportsPage({super.key});

  @override
  State<ReportsPage> createState() => _ReportsPageState();
}

class _ReportsPageState extends State<ReportsPage> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) => _loadData());
  }

  Future<void> _loadData() async {
    final settingsProvider =
        Provider.of<SettingsProvider>(context, listen: false);
    final authService = Provider.of<AuthServiceImpl>(context, listen: false);
    final reportProvider = Provider.of<ReportProvider>(context, listen: false);

    await settingsProvider.loadSettings();
    final user = await authService.getCurrentUser();
    if (user != null && mounted) {
      await reportProvider.loadReports(user.id);
    }
  }

  Future<void> _pickDateRange(ReportProvider provider) async {
    final now = DateTime.now();
    final range = await showDateRangePicker(
      context: context,
      firstDate: DateTime(now.year - 5),
      lastDate: now,
      initialDateRange: DateTimeRange(
        start: provider.customStart ?? now.subtract(const Duration(days: 7)),
        end: provider.customEnd ?? now,
      ),
    );

    if (range != null && mounted) {
      await provider.setCustomRange(range.start, range.end);
    }
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor:
          isDark ? const Color(0xFF020617) : const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: const Text(
          'Báo Cáo',
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
        backgroundColor: Colors.transparent,
      ),
      body: Consumer2<ReportProvider, SettingsProvider>(
        builder: (context, reportProvider, settingsProvider, _) {
          final currency = settingsProvider.currency;
          final isEmpty = !reportProvider.isLoading &&
              reportProvider.errorMessage == null &&
              reportProvider.transactions.isEmpty;

          return RefreshIndicator(
            onRefresh: reportProvider.refresh,
            child: AsyncStateView(
              isLoading: reportProvider.isLoading &&
                  reportProvider.transactions.isEmpty,
              errorMessage: reportProvider.errorMessage,
              isEmpty: isEmpty,
              onRetry: _loadData,
              child: ListView(
                physics: const AlwaysScrollableScrollPhysics(),
                padding: const EdgeInsets.all(16),
                children: [
                  ReportFilterBar(
                    selectedPeriod: reportProvider.currentPeriod,
                    customStart: reportProvider.customStart,
                    customEnd: reportProvider.customEnd,
                    onPeriodChanged: reportProvider.setPeriod,
                    onPickDateRange: () => _pickDateRange(reportProvider),
                  ),
                  const SizedBox(height: 16),
                  ReportOverviewCard(
                    totalIncome: reportProvider.totalIncome,
                    totalExpense: reportProvider.totalExpense,
                    balance: reportProvider.balance,
                    currency: currency,
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Chi tiêu theo danh mục',
                    child: ExpensePieChart(
                      data: reportProvider.expenseByCategory,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Thu & Chi theo tháng',
                    child: MonthlyBarChart(
                      data: reportProvider.monthlySummary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  _SectionCard(
                    title: 'Tổng hợp danh mục',
                    child: CategorySummaryList(
                      data: reportProvider.expenseByCategory,
                      currency: currency,
                    ),
                  ),
                  const SizedBox(height: 24),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}

class _SectionCard extends StatelessWidget {
  final String title;
  final Widget child;

  const _SectionCard({required this.title, required this.child});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      elevation: 2,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
      color: isDark ? const Color(0xFF0F172A) : Colors.white,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
            const SizedBox(height: 12),
            child,
          ],
        ),
      ),
    );
  }
}
