import 'dart:convert';
import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hive/hive.dart';
import '../core/db/hive_config.dart';
import 'activity_log_service.dart';
import '../core/di/di.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';
import 'file_helper.dart';

class BackupService {
  Map<String, dynamic> _boxToMap(Box box) {
    final map = <String, dynamic>{};
    box.toMap().forEach((key, value) {
      map[key.toString()] = value;
    });
    return map;
  }

  /// Local Backup: Export Hive database contents to a JSON file
  Future<String?> backupLocal() async {
    try {
      final backupData = {
        'users': _boxToMap(HiveConfig.usersBox),
        'products': _boxToMap(HiveConfig.productsBox),
        'customers': _boxToMap(HiveConfig.customersBox),
        'suppliers': _boxToMap(HiveConfig.suppliersBox),
        'sales': _boxToMap(HiveConfig.salesBox),
        'expenses': _boxToMap(HiveConfig.expensesBox),
        'activity_logs': _boxToMap(HiveConfig.activityLogsBox),
      };

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = 'almohandis_pos_backup_$dateStr.json';
      final jsonStr = jsonEncode(backupData);

      if (kIsWeb) {
        await saveFileWeb(jsonStr, defaultFileName);
        _logBackup('web_download');
        return 'success:downloads/$defaultFileName';
      } else {
        // Native save
        final outputPath = await FilePicker.platform.saveFile(
          dialogTitle: 'Select Backup Destination / اختر مكان حفظ النسخة الاحتياطية',
          fileName: defaultFileName,
          type: FileType.any,
        );

        if (outputPath == null) {
          return 'cancelled';
        }

        final file = File(outputPath);
        await file.writeAsString(jsonStr);
        _logBackup(outputPath);
        return 'success:$outputPath';
      }
    } catch (e) {
      return 'error:${e.toString()}';
    }
  }

  /// Local Restore: Replace the active Hive database contents with data from a JSON backup file
  Future<String?> restoreLocal() async {
    try {
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File to Restore / اختر ملف النسخة الاحتياطية للاستعادة',
        type: FileType.custom,
        allowedExtensions: ['json'],
        withData: true,
      );

      if (result == null) {
        return 'cancelled';
      }

      final bytes = result.files.single.bytes;
      if (bytes == null) {
        return 'error:no_data_read';
      }

      final jsonStr = utf8.decode(bytes);
      final backupData = jsonDecode(jsonStr) as Map<String, dynamic>;

      // Verify backup structure
      if (!backupData.containsKey('users') || !backupData.containsKey('products')) {
        return 'error:invalid_backup_format';
      }

      // Restore each box
      await _restoreBox(HiveConfig.usersBox, backupData['users']);
      await _restoreBox(HiveConfig.productsBox, backupData['products']);
      await _restoreBox(HiveConfig.customersBox, backupData['customers']);
      await _restoreBox(HiveConfig.suppliersBox, backupData['suppliers']);
      await _restoreBox(HiveConfig.salesBox, backupData['sales']);
      await _restoreBox(HiveConfig.expensesBox, backupData['expenses']);
      await _restoreBox(HiveConfig.activityLogsBox, backupData['activity_logs']);

      _logRestore(result.files.single.name);
      return 'success';
    } catch (e) {
      return 'error:${e.toString()}';
    }
  }

  Future<void> _restoreBox(Box box, dynamic data) async {
    if (data is Map) {
      await box.clear();
      for (final entry in data.entries) {
        await box.put(entry.key, entry.value);
      }
    }
  }

  void _logBackup(String path) {
    try {
      final currentUsername = Gravity.find<AuthBloc>().currentUser?.username ?? 'admin';
      Gravity.find<ActivityLogService>().log(
        category: 'settings',
        action: 'database_backup',
        description: 'Created database backup at: $path',
        userId: currentUsername,
      );
    } catch (_) {}
  }

  void _logRestore(String name) {
    try {
      final currentUsername = Gravity.find<AuthBloc>().currentUser?.username ?? 'admin';
      Gravity.find<ActivityLogService>().log(
        category: 'settings',
        action: 'database_restore',
        description: 'Restored database from: $name',
        userId: currentUsername,
      );
    } catch (_) {}
  }
}
