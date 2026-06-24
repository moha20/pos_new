import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'core/router/router.dart';
import 'core/theme/theme.dart';
import 'core/localization/locale_cubit.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';
import 'features/suppliers/presentation/bloc/supplier_bloc.dart';
import 'features/pos/presentation/bloc/pos_bloc.dart';
import 'features/pos/presentation/bloc/sales_history_cubit.dart';
import 'features/cashier/presentation/bloc/cashier_bloc.dart';
import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';
import 'features/activity_log/presentation/bloc/activity_log_cubit.dart';
import 'features/returns/presentation/bloc/returns_cubit.dart';
import 'features/balance/presentation/bloc/balance_cubit.dart';
import 'core/di/di.dart';

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => LocaleCubit()),
        BlocProvider(
          create: (_) => Gravity.find<AuthBloc>()..add(AuthCheckStatus()),
        ),
        BlocProvider(
          create: (_) => Gravity.find<InventoryBloc>()..add(LoadInventory()),
        ),
        BlocProvider(
          create: (_) => Gravity.find<CustomerBloc>()..add(LoadCustomers()),
        ),
        BlocProvider(
          create: (_) => Gravity.find<SupplierBloc>()..add(LoadSuppliers()),
        ),
        BlocProvider(create: (_) => Gravity.find<POSBloc>()..add(POSInit())),
        BlocProvider(
          create: (_) => Gravity.find<SalesHistoryCubit>()..loadSales(),
        ),
        BlocProvider(
          create: (_) => Gravity.find<CashierBloc>()..add(LoadCashier()),
        ),
        BlocProvider(
          create: (_) => Gravity.find<ReportsBloc>()..add(LoadReportsEvent()),
        ),
        BlocProvider(
          create: (_) => Gravity.find<SettingsBloc>()..add(LoadSettings()),
        ),
        BlocProvider(create: (_) => Gravity.find<ActivityLogCubit>()),
        BlocProvider(create: (_) => Gravity.find<ReturnsCubit>()),
        BlocProvider(create: (_) => Gravity.find<BalanceCubit>()..loadPayments()),
      ],
      child: BlocBuilder<LocaleCubit, Locale>(
        builder: (context, locale) {
          return BlocBuilder<SettingsBloc, SettingsState>(
            builder: (context, settingsState) {
              String themeType = 'copper';
              ThemeMode activeThemeMode = ThemeMode.light;
              if (settingsState is SettingsLoaded) {
                themeType = settingsState.themeType;
                final mode = settingsState.themeMode;
                if (mode == 'dark') {
                  activeThemeMode = ThemeMode.dark;
                } else if (mode == 'system')
                  activeThemeMode = ThemeMode.system;
                else
                  activeThemeMode = ThemeMode.light;
              }
              final isBlue = themeType == 'logo_blue';
              return ScreenUtilInit(
                designSize: const Size(1280, 800),
                minTextAdapt: true,
                splitScreenMode: true,
                builder: (context, child) {
                  return MaterialApp.router(
                    debugShowCheckedModeBanner: false,
                    scrollBehavior: const AppScrollBehavior(),
                    locale: context.locale,
                    supportedLocales: context.supportedLocales,
                    localizationsDelegates: context.localizationDelegates,
                    routerConfig: appRouter,
                    themeMode: activeThemeMode,
                    theme: isBlue ? AppTheme.logoBlueLight : AppTheme.light,
                    darkTheme: isBlue ? AppTheme.logoBlueDark : AppTheme.dark,
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}

class AppScrollBehavior extends MaterialScrollBehavior {
  const AppScrollBehavior();

  @override
  Set<PointerDeviceKind> get dragDevices => {
        PointerDeviceKind.touch,
        PointerDeviceKind.mouse,
        PointerDeviceKind.trackpad,
        PointerDeviceKind.stylus,
      };
}
