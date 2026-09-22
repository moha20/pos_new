import 'package:flutter/material.dart';

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
    return Image.asset(
      'assets/images/logo.png',
      height: height,
      width: width,
      fit: fit,
      errorBuilder: (context, error, stackTrace) => Image.asset(
        'assets/images/logo.jpg',
        height: height,
        width: width,
        fit: fit,
      ),
    );
  }
}
