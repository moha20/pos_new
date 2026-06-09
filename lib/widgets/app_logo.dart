import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../features/settings/presentation/bloc/settings_bloc.dart';

class AppLogo extends StatelessWidget {
  final double? height;
  final double? width;
  final BoxFit fit;

  const AppLogo({
    super.key,
    this.height,
    this.width,
    this.fit = BoxFit.contain,
  });

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<SettingsBloc, SettingsState>(
      builder: (context, state) {
        String? logoPath;
        if (state is SettingsLoaded) {
          logoPath = state.logoPath;
        }
        if (logoPath != null && logoPath.isNotEmpty && File(logoPath).existsSync()) {
          return Image.file(
            File(logoPath),
            height: height,
            width: width,
            fit: fit,
          );
        }
        return Image.asset(
          'assets/images/logo.jpg',
          height: height,
          width: width,
          fit: fit,
        );
      },
    );
  }
}
