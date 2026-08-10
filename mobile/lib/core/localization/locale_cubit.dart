import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:easy_localization/easy_localization.dart';

class LocaleCubit extends Cubit<Locale> {
  LocaleCubit() : super(const Locale('ar'));

  void setLocale(BuildContext context, Locale newLocale) {
    emit(newLocale);
    context.setLocale(newLocale);
  }

  void switchToArabic(BuildContext context) {
    setLocale(context, const Locale('ar'));
  }

  void switchToEnglish(BuildContext context) {
    setLocale(context, const Locale('en'));
  }
}
