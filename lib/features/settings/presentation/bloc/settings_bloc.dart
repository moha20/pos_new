import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../core/di/di.dart';
import '../../../../services/activity_log_service.dart';
import '../../../auth/presentation/bloc/auth_bloc.dart';

// Events
abstract class SettingsEvent {}

class LoadSettings extends SettingsEvent {}

class SaveSettings extends SettingsEvent {
  final String companyName;
  final double taxPercent;
  final String printerIp;
  final String themeType;
  final String themeMode;
  final String whatsappPhone;

  SaveSettings({
    required this.companyName,
    required this.taxPercent,
    required this.printerIp,
    required this.themeType,
    required this.themeMode,
    required this.whatsappPhone,
  });
}

class SaveLogo extends SettingsEvent {
  final String? logoPath;
  SaveLogo(this.logoPath);
}

// States
abstract class SettingsState {}

class SettingsInitial extends SettingsState {}

class SettingsLoading extends SettingsState {}

class SettingsLoaded extends SettingsState {
  final String companyName;
  final double taxPercent;
  final String printerIp;
  final String themeType;
  final String themeMode;
  final String whatsappPhone;
  final String? logoPath;

  SettingsLoaded({
    required this.companyName,
    required this.taxPercent,
    required this.printerIp,
    required this.themeType,
    required this.themeMode,
    required this.whatsappPhone,
    this.logoPath,
  });
}

class SettingsError extends SettingsState {
  final String message;
  SettingsError(this.message);
}

// Bloc
class SettingsBloc extends Bloc<SettingsEvent, SettingsState> {
  final SharedPreferences prefs;

  SettingsBloc(this.prefs) : super(SettingsLoaded(
    companyName: prefs.getString('company_name') ?? 'مؤسسة المهندس للأدوات الكهربائية',
    taxPercent: prefs.getDouble('tax_percent') ?? 14.0,
    printerIp: prefs.getString('printer_ip') ?? '192.168.1.100',
    themeType: prefs.getString('theme_type') ?? 'copper',
    themeMode: prefs.getString('theme_mode') ?? 'light',
    whatsappPhone: prefs.getString('whatsapp_phone') ?? '',
    logoPath: prefs.getString('logo_path'),
  )) {
    on<LoadSettings>((event, emit) {
      try {
        final company = prefs.getString('company_name') ?? 'مؤسسة المهندس للأدوات الكهربائية';
        final tax = prefs.getDouble('tax_percent') ?? 14.0;
        final ip = prefs.getString('printer_ip') ?? '192.168.1.100';
        final theme = prefs.getString('theme_type') ?? 'copper';
        final mode = prefs.getString('theme_mode') ?? 'light';
        final whatsapp = prefs.getString('whatsapp_phone') ?? '';
        final logo = prefs.getString('logo_path');
        emit(SettingsLoaded(
          companyName: company,
          taxPercent: tax,
          printerIp: ip,
          themeType: theme,
          themeMode: mode,
          whatsappPhone: whatsapp,
          logoPath: logo,
        ));
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    on<SaveSettings>((event, emit) async {
      try {
        await prefs.setString('company_name', event.companyName);
        await prefs.setDouble('tax_percent', event.taxPercent);
        await prefs.setString('printer_ip', event.printerIp);
        await prefs.setString('theme_type', event.themeType);
        await prefs.setString('theme_mode', event.themeMode);
        await prefs.setString('whatsapp_phone', event.whatsappPhone);
        final logo = prefs.getString('logo_path');
        emit(SettingsLoaded(
          companyName: event.companyName,
          taxPercent: event.taxPercent,
          printerIp: event.printerIp,
          themeType: event.themeType,
          themeMode: event.themeMode,
          whatsappPhone: event.whatsappPhone,
          logoPath: logo,
        ));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'settings_updated',
            category: 'settings',
            description: 'Updated settings: Company Name: ${event.companyName}, Tax: ${event.taxPercent}%, Printer IP: ${event.printerIp}, Theme: ${event.themeType}, Mode: ${event.themeMode}, WhatsApp: ${event.whatsappPhone}',
            userId: user?.username ?? 'system',
          );
        } catch (_) {}
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });

    on<SaveLogo>((event, emit) async {
      try {
        if (event.logoPath == null) {
          await prefs.remove('logo_path');
        } else {
          await prefs.setString('logo_path', event.logoPath!);
        }
        final company = prefs.getString('company_name') ?? 'مؤسسة المهندس للأدوات الكهربائية';
        final tax = prefs.getDouble('tax_percent') ?? 14.0;
        final ip = prefs.getString('printer_ip') ?? '192.168.1.100';
        final theme = prefs.getString('theme_type') ?? 'copper';
        final mode = prefs.getString('theme_mode') ?? 'light';
        final whatsapp = prefs.getString('whatsapp_phone') ?? '';
        emit(SettingsLoaded(
          companyName: company,
          taxPercent: tax,
          printerIp: ip,
          themeType: theme,
          themeMode: mode,
          whatsappPhone: whatsapp,
          logoPath: event.logoPath,
        ));
        try {
          final user = Gravity.find<AuthBloc>().currentUser;
          Gravity.find<ActivityLogService>().log(
            action: 'logo_updated',
            category: 'settings',
            description: event.logoPath == null ? 'Removed custom logo' : 'Updated custom logo to: ${event.logoPath}',
            userId: user?.username ?? 'system',
          );
        } catch (_) {}
      } catch (e) {
        emit(SettingsError(e.toString()));
      }
    });
  }
}
