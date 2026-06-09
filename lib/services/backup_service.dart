import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:realm/realm.dart';
import '../core/db/realm_config.dart';
import 'activity_log_service.dart';
import '../core/di/di.dart';

// Model imports for schema reinitialization
import '../features/auth/data/models/user_model.dart';
import '../features/inventory/data/models/product_model.dart';
import '../features/customers/data/models/customer_model.dart';
import '../features/suppliers/data/models/supplier_model.dart';
import '../features/pos/data/models/sale_model.dart';
import '../features/cashier/data/models/expense_model.dart';
import '../features/activity_log/data/models/activity_log_model.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class BackupService {
  /// Local Backup: Copy the current active Realm file to a user-chosen destination
  Future<String?> backupLocal() async {
    try {
      final activePath = RealmConfig.realm.config.path;
      final activeFile = File(activePath);
      if (!activeFile.existsSync()) {
        return 'database_not_found';
      }

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = 'almohandis_pos_backup_$dateStr.realm';

      // Open native save file dialog
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select Backup Destination / اختر مكان حفظ النسخة الاحتياطية',
        fileName: defaultFileName,
        type: FileType.any,
      );

      if (outputPath == null) {
        return 'cancelled';
      }

      // Perform copy
      await activeFile.copy(outputPath);

      // Log activity
      try {
        final currentUsername = Gravity.find<AuthBloc>().currentUser?.username ?? 'admin';
        Gravity.find<ActivityLogService>().log(
          category: 'settings',
          action: 'database_backup',
          description: 'Created database backup at: $outputPath',
          userId: currentUsername,
        );
      } catch (_) {}

      return 'success:$outputPath';
    } catch (e) {
      return 'error:${e.toString()}';
    }
  }

  /// Local Restore: Replace the active database file with a backup file chosen by the user
  Future<String?> restoreLocal() async {
    try {
      // Pick the backup file (.realm)
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File to Restore / اختر ملف النسخة الاحتياطية للاستعادة',
        type: FileType.custom,
        allowedExtensions: ['realm'],
      );

      if (result == null || result.files.single.path == null) {
        return 'cancelled';
      }

      final backupPath = result.files.single.path!;
      final backupFile = File(backupPath);
      if (!backupFile.existsSync()) {
        return 'backup_file_not_found';
      }

      final defaultPath = RealmConfig.realm.config.path;

      // 1. Close current realm instance
      RealmConfig.realm.close();

      // 2. Remove existing database files (database, lock file, management folder)
      final activeFile = File(defaultPath);
      if (activeFile.existsSync()) {
        activeFile.deleteSync();
      }

      final lockFile = File('$defaultPath.lock');
      if (lockFile.existsSync()) {
        lockFile.deleteSync();
      }

      final managementDir = Directory('$defaultPath.management');
      if (managementDir.existsSync()) {
        managementDir.deleteSync(recursive: true);
      }

      // 3. Copy backup file to active location
      backupFile.copySync(defaultPath);

      // 4. Re-initialize the active Realm
      final config = Configuration.local([
        User.schema,
        Product.schema,
        PriceTier.schema,
        Customer.schema,
        Supplier.schema,
        SaleItem.schema,
        Sale.schema,
        Expense.schema,
        ActivityLog.schema,
      ], schemaVersion: 5);

      RealmConfig.realm = Realm(config);

      // Log activity in new database instance
      try {
        final currentUsername = Gravity.find<AuthBloc>().currentUser?.username ?? 'admin';
        Gravity.find<ActivityLogService>().log(
          category: 'settings',
          action: 'database_restore',
          description: 'Restored database from: $backupPath',
          userId: currentUsername,
        );
      } catch (_) {}

      return 'success';
    } catch (e) {
      return 'error:${e.toString()}';
    }
  }
}
