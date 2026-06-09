import 'package:flutter/material.dart';
import 'package:flutter_barcode_scanner/flutter_barcode_scanner.dart';
import 'dart:io' show Platform;
import 'package:easy_localization/easy_localization.dart';

class BarcodeService {
  Future<String?> scanBarcode(BuildContext context) async {
    bool isMobile = false;
    try {
      isMobile = Platform.isAndroid || Platform.isIOS;
    } catch (_) {
      isMobile = false;
    }

    if (isMobile) {
      try {
        final result = await FlutterBarcodeScanner.scanBarcode(
          '#E65100', 
          'cancel'.tr(), 
          true, 
          ScanMode.BARCODE,
        );
        if (result != '-1') {
          return result;
        }
      } catch (_) {
        // Fallback to input dialog if hardware permissions or platform throws
      }
    }

    if (!context.mounted) return null;

    // Desktop/Web simulation dialog
    return showDialog<String>(
      context: context,
      builder: (context) {
        final controller = TextEditingController();
        return AlertDialog(
          title: Text('barcode'.tr()),
          content: TextField(
            controller: controller,
            autofocus: true,
            decoration: InputDecoration(
              hintText: 'barcode'.tr(),
              suffixIcon: IconButton(
                icon: const Icon(Icons.arrow_forward),
                onPressed: () => Navigator.pop(context, controller.text),
              ),
            ),
            onSubmitted: (value) => Navigator.pop(context, value),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: Text('cancel'.tr()),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, controller.text),
              child: Text('confirm'.tr()),
            ),
          ],
        );
      },
    );
  }
}
