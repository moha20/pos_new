import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:hive/hive.dart';

import 'app.dart';
import 'core/di/di.dart';
import 'core/db/hive_config.dart';
import 'services/print_service.dart';
import 'services/barcode_service.dart';
import 'services/backup_service.dart';

import 'features/auth/domain/repositories/auth_repository.dart';
import 'features/auth/data/repositories/auth_repository_impl.dart';
import 'features/auth/presentation/bloc/auth_bloc.dart';

import 'features/inventory/domain/repositories/product_repository.dart';
import 'features/inventory/data/repositories/product_repository_impl.dart';
import 'features/inventory/presentation/bloc/inventory_bloc.dart';

import 'features/customers/domain/repositories/customer_repository.dart';
import 'features/customers/data/repositories/customer_repository_impl.dart';
import 'features/customers/presentation/bloc/customer_bloc.dart';

import 'features/suppliers/domain/repositories/supplier_repository.dart';
import 'features/suppliers/data/repositories/supplier_repository_impl.dart';
import 'features/suppliers/presentation/bloc/supplier_bloc.dart';

import 'features/pos/domain/repositories/sale_repository.dart';
import 'features/pos/data/repositories/sale_repository_impl.dart';
import 'features/pos/presentation/bloc/pos_bloc.dart';
import 'features/pos/presentation/bloc/sales_history_cubit.dart';

import 'features/cashier/domain/repositories/cashier_repository.dart';
import 'features/cashier/data/repositories/cashier_repository_impl.dart';
import 'features/cashier/presentation/bloc/cashier_bloc.dart';

import 'features/reports/presentation/bloc/reports_bloc.dart';
import 'features/settings/presentation/bloc/settings_bloc.dart';

import 'features/activity_log/domain/repositories/activity_log_repository.dart';
import 'features/activity_log/data/repositories/activity_log_repository_impl.dart';
import 'features/activity_log/presentation/bloc/activity_log_cubit.dart';
import 'services/activity_log_service.dart';
import 'features/returns/presentation/bloc/returns_cubit.dart';

import 'features/balance/domain/repositories/payment_repository.dart';
import 'features/balance/data/repositories/payment_repository_impl.dart';
import 'features/balance/presentation/bloc/balance_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await EasyLocalization.ensureInitialized();

  // 1. Initialize Hive DB
  await HiveConfig.init();

  // 2. Initialize SharedPreferences
  final prefs = await SharedPreferences.getInstance();

  // 3. Register Core infrastructure singletons
  Gravity.put<Box>(HiveConfig.usersBox);
  Gravity.put<SharedPreferences>(prefs);
  Gravity.put<PrintService>(PrintService());
  Gravity.put<BarcodeService>(BarcodeService());
  Gravity.put<BackupService>(BackupService());

  // 4. Register Repository implementations
  Gravity.put<AuthRepository>(AuthRepositoryImpl(HiveConfig.usersBox));
  Gravity.put<ProductRepository>(ProductRepositoryImpl(HiveConfig.productsBox));
  Gravity.put<CustomerRepository>(CustomerRepositoryImpl(HiveConfig.customersBox));
  Gravity.put<SupplierRepository>(SupplierRepositoryImpl(HiveConfig.suppliersBox));
  Gravity.put<SaleRepository>(SaleRepositoryImpl(HiveConfig.salesBox, HiveConfig.productsBox));
  Gravity.put<CashierRepository>(
    CashierRepositoryImpl(HiveConfig.expensesBox, Gravity.find<SharedPreferences>()),
  );
  Gravity.put<ActivityLogRepository>(ActivityLogRepositoryImpl(HiveConfig.activityLogsBox));
  Gravity.put<ActivityLogService>(ActivityLogService(Gravity.find<ActivityLogRepository>()));

  // Balance / Payment
  Gravity.put<PaymentRepository>(PaymentRepositoryImpl(HiveConfig.paymentsBox));

  // 5. Register Presentation BLoC state singletons
  Gravity.put<AuthBloc>(AuthBloc(Gravity.find<AuthRepository>()));
  Gravity.put<InventoryBloc>(InventoryBloc(Gravity.find<ProductRepository>()));
  Gravity.put<CustomerBloc>(CustomerBloc(Gravity.find<CustomerRepository>()));
  Gravity.put<SupplierBloc>(SupplierBloc(Gravity.find<SupplierRepository>()));
  Gravity.put<POSBloc>(
    POSBloc(
      saleRepository: Gravity.find<SaleRepository>(),
      productRepository: Gravity.find<ProductRepository>(),
      customerRepository: Gravity.find<CustomerRepository>(),
    ),
  );
  Gravity.put<SalesHistoryCubit>(SalesHistoryCubit(Gravity.find<SaleRepository>()));
  Gravity.put<CashierBloc>(CashierBloc(Gravity.find<CashierRepository>()));
  Gravity.put<ReportsBloc>(
    ReportsBloc(
      Gravity.find<SaleRepository>(),
      Gravity.find<CashierRepository>(),
    ),
  );
  Gravity.put<SettingsBloc>(SettingsBloc(Gravity.find<SharedPreferences>()));
  Gravity.put<ActivityLogCubit>(ActivityLogCubit(Gravity.find<ActivityLogRepository>()));
  Gravity.put<ReturnsCubit>(ReturnsCubit(
    productRepository: Gravity.find<ProductRepository>(),
    customerRepository: Gravity.find<CustomerRepository>(),
    supplierRepository: Gravity.find<SupplierRepository>(),
    saleRepository: Gravity.find<SaleRepository>(),
    activityLogService: Gravity.find<ActivityLogService>(),
  ));
  Gravity.put<BalanceCubit>(BalanceCubit(
    paymentRepository: Gravity.find<PaymentRepository>(),
    customerRepository: Gravity.find<CustomerRepository>(),
    supplierRepository: Gravity.find<SupplierRepository>(),
  ));

  runApp(
    EasyLocalization(
      supportedLocales: const [Locale('ar'), Locale('en')],
      path: 'assets/translations',
      fallbackLocale: const Locale('ar'),
      startLocale: const Locale('ar'),
      child: const App(),
    ),
  );
}
