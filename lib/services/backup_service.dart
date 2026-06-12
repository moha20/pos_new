import 'dart:convert';
import 'dart:io';
import 'package:file_picker/file_picker.dart';
import 'package:easy_localization/easy_localization.dart';
import '../core/db/hive_config.dart';
import 'activity_log_service.dart';
import '../core/di/di.dart';
import '../features/auth/presentation/bloc/auth_bloc.dart';

class BackupService {
  /// Local Backup: Export all Hive boxes to a JSON file at a user-chosen destination
  Future<String?> backupLocal() async {
    try {
      // Collect all data from all boxes
      final backupData = <String, dynamic>{
        'version': 1,
        'timestamp': DateTime.now().toIso8601String(),
        'users': _boxToList(HiveConfig.usersBox),
        'products': _boxToList(HiveConfig.productsBox),
        'customers': _boxToList(HiveConfig.customersBox),
        'suppliers': _boxToList(HiveConfig.suppliersBox),
        'sales': _boxToList(HiveConfig.salesBox),
        'expenses': _boxToList(HiveConfig.expensesBox),
        'activity_logs': _boxToList(HiveConfig.activityLogsBox),
      };

      final jsonString = const JsonEncoder.withIndent('  ').convert(backupData);

      final dateStr = DateFormat('yyyyMMdd_HHmmss').format(DateTime.now());
      final defaultFileName = 'almohandis_pos_backup_$dateStr.json';

      // Open native save file dialog
      final outputPath = await FilePicker.platform.saveFile(
        dialogTitle: 'Select Backup Destination / اختر مكان حفظ النسخة الاحتياطية',
        fileName: defaultFileName,
        type: FileType.any,
      );

      if (outputPath == null) {
        return 'cancelled';
      }

      // Write JSON to file
      await File(outputPath).writeAsString(jsonString);

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

  /// Local Restore: Load a backup JSON file and replace all Hive box data
  Future<String?> restoreLocal() async {
    try {
      // Pick the backup file (.json)
      final result = await FilePicker.platform.pickFiles(
        dialogTitle: 'Select Backup File to Restore / اختر ملف النسخة الاحتياطية للاستعادة',
        type: FileType.custom,
        allowedExtensions: ['json'],
      );

      if (result == null || result.files.single.path == null) {
        return 'cancelled';
      }

      final backupPath = result.files.single.path!;
      final backupFile = File(backupPath);
      if (!backupFile.existsSync()) {
        return 'backup_file_not_found';
      }

      final jsonString = await backupFile.readAsString();
      final backupData = json.decode(jsonString) as Map<String, dynamic>;

      // Clear and restore each box
      await _restoreBox(HiveConfig.usersBox, backupData['users'] as List?);
      await _restoreBox(HiveConfig.productsBox, backupData['products'] as List?);
      await _restoreBox(HiveConfig.customersBox, backupData['customers'] as List?);
      await _restoreBox(HiveConfig.suppliersBox, backupData['suppliers'] as List?);
      await _restoreBox(HiveConfig.salesBox, backupData['sales'] as List?);
      await _restoreBox(HiveConfig.expensesBox, backupData['expenses'] as List?);
      await _restoreBox(HiveConfig.activityLogsBox, backupData['activity_logs'] as List?);

      // Log activity in restored database
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

  /// Convert a Hive box to a list of {key, value} entries for JSON serialization
  List<Map<String, dynamic>> _boxToList(dynamic box) {
    final list = <Map<String, dynamic>>[];
    for (final key in box.keys) {
      list.add({
        'key': key.toString(),
        'value': box.get(key),
      });
    }
    return list;
  }

  /// Restore a Hive box from a list of {key, value} entries
  Future<void> _restoreBox(dynamic box, List? entries) async {
    await box.clear();
    if (entries == null) return;
    for (final entry in entries) {
      final map = entry as Map<String, dynamic>;
      await box.put(map['key'], map['value']);
    }
  }
}
