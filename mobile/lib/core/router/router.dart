import 'package:go_router/go_router.dart';
import '../di/di.dart';
import '../../features/auth/presentation/bloc/auth_bloc.dart';
import '../../features/auth/presentation/screens/login_screen.dart';
import '../../features/pos/presentation/screens/pos_screen.dart';
import '../../features/pos/presentation/screens/sales_history_screen.dart';
import '../../features/inventory/presentation/screens/inventory_screen.dart';
import '../../features/customers/presentation/screens/customers_screen.dart';
import '../../features/suppliers/presentation/screens/suppliers_screen.dart';
import '../../features/suppliers/presentation/screens/supplier_invoice_screen.dart';
import '../../features/reports/presentation/screens/reports_screen.dart';
import '../../features/cashier/presentation/screens/cashier_screen.dart';
import '../../features/settings/presentation/screens/settings_screen.dart';
import '../../features/activity_log/presentation/screens/activity_log_screen.dart';
import '../../features/returns/presentation/screens/returns_screen.dart';
import '../../features/balance/presentation/screens/balance_screen.dart';
import '../../features/pos/presentation/screens/invoice_details_screen.dart';
import '../../features/pos/domain/entities/sale_entity.dart';
import '../../features/about/presentation/screens/about_screen.dart';

final GoRouter appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    try {
      final authBloc = Gravity.find<AuthBloc>();
      final isLoggedIn = authBloc.currentUser != null;
      final isGoingToLogin = state.matchedLocation == '/login';

      if (!isLoggedIn && !isGoingToLogin) {
        return '/login';
      }
      if (isLoggedIn && isGoingToLogin) {
        return '/pos';
      }
    } catch (_) {
      // In case AuthBloc isn't registered yet in Gravity
      return null;
    }
    return null;
  },
  routes: [
    GoRoute(
      path: '/login',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const LoginScreen(),
      ),
    ),
    GoRoute(
      path: '/pos',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const POSScreen(),
      ),
    ),
    GoRoute(
      path: '/sales',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const SalesHistoryScreen(),
      ),
    ),
    GoRoute(
      path: '/inventory',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const InventoryScreen(),
      ),
    ),
    GoRoute(
      path: '/customers',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CustomersScreen(),
      ),
    ),
    GoRoute(
      path: '/suppliers',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const SuppliersScreen(),
      ),
    ),
    GoRoute(
      path: '/supplier-invoice',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const SupplierInvoiceScreen(),
      ),
    ),
    GoRoute(
      path: '/reports',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ReportsScreen(),
      ),
    ),
    GoRoute(
      path: '/cashier',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const CashierScreen(),
      ),
    ),
    GoRoute(
      path: '/settings',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const SettingsScreen(),
      ),
    ),
    GoRoute(
      path: '/activity-log',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ActivityLogScreen(),
      ),
    ),
    GoRoute(
      path: '/returns',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const ReturnsScreen(),
      ),
    ),
    GoRoute(
      path: '/balance',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const BalanceScreen(),
      ),
    ),
    GoRoute(
      path: '/about',
      pageBuilder: (context, state) => NoTransitionPage(
        key: state.pageKey,
        child: const AboutScreen(),
      ),
    ),
    GoRoute(
      path: '/invoice-details',
      pageBuilder: (context, state) {
        final extra = state.extra;
        SaleEntity? sale;
        String? customerName;
        if (extra is SaleEntity) {
          sale = extra;
        } else if (extra is Map<String, dynamic>) {
          sale = extra['sale'] as SaleEntity?;
          customerName = extra['customerName'] as String?;
        }
        if (sale == null) {
          return NoTransitionPage(
            key: state.pageKey,
            child: const SalesHistoryScreen(),
          );
        }
        return NoTransitionPage(
          key: state.pageKey,
          child: InvoiceDetailsScreen(
            sale: sale,
            customerName: customerName,
          ),
        );
      },
    ),
  ],
);
