import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';
import '../core/network/api_client.dart';
import '../core/theme/app_theme.dart';
import '../core/theme/theme_provider.dart';
import '../features/auth/application/services/auth_service_impl.dart';
import '../features/auth/data/datasources/auth_local_data_source_impl.dart';
import '../features/auth/data/datasources/auth_remote_data_source_impl.dart';
import '../features/auth/data/repositories/auth_repository_impl.dart';
import '../features/category/application/providers/budget_provider.dart';
import '../features/category/application/providers/category_provider.dart';
import '../features/transaction/application/providers/transaction_provider.dart';
import '../features/profile/application/providers/profile_provider.dart';
import '../features/reports/application/providers/report_provider.dart';
import '../features/settings/application/providers/settings_provider.dart';
import 'routes/app_router.dart';

class MyApp extends StatefulWidget {
  final String initialLocation;

  const MyApp({super.key, required this.initialLocation});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final GoRouter _router;

  @override
  void initState() {
    super.initState();
    _router = AppRouter.createRouter(initialLocation: widget.initialLocation);
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        Provider<ApiClient>(
          create: (_) => ApiClient(),
        ),
        ProxyProvider<ApiClient, AuthRemoteDataSourceImpl>(
          update: (_, apiClient, __) =>
              AuthRemoteDataSourceImpl(apiClient: apiClient),
        ),
        Provider<AuthLocalDataSourceImpl>(
          create: (_) => AuthLocalDataSourceImpl(),
        ),
        ProxyProvider2<AuthRemoteDataSourceImpl, AuthLocalDataSourceImpl,
            AuthRepositoryImpl>(
          update: (_, remoteSource, localSource, __) => AuthRepositoryImpl(
            remoteDataSource: remoteSource,
            localDataSource: localSource,
          ),
        ),
        ProxyProvider<AuthRepositoryImpl, AuthServiceImpl>(
          update: (_, repository, __) =>
              AuthServiceImpl(authRepository: repository),
        ),
        ChangeNotifierProvider<CategoryProvider>(
          create: (_) => CategoryProvider(),
        ),
        ChangeNotifierProvider<ThemeProvider>(
          create: (_) => ThemeProvider(),
        ),
        ChangeNotifierProvider<BudgetProvider>(
          create: (_) => BudgetProvider(),
        ),
        ChangeNotifierProvider<TransactionProvider>(
          create: (_) => TransactionProvider(),
        ),
        ChangeNotifierProvider<ProfileProvider>(
          create: (_) => ProfileProvider(),
        ),
        ChangeNotifierProvider<ReportProvider>(
          create: (_) => ReportProvider(),
        ),
        ChangeNotifierProvider<SettingsProvider>(
          create: (_) => SettingsProvider(),
        ),
      ],
      child: Consumer<ThemeProvider>(
        builder: (context, themeProvider, child) {
          return MaterialApp.router(
            title: 'Quản Lý Thu Chi',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme(),
            darkTheme: AppTheme.darkTheme(),
            themeMode: themeProvider.themeMode,
            routerConfig: _router,
          );
        },
      ),
    );
  }
}
