import 'package:flutter/material.dart';
import 'app_sidebar.dart';
import 'app_bottom_nav.dart';
import 'app_drawer.dart';

class ResponsiveLayout extends StatelessWidget {
  final Widget child;
  final String title;
  final List<Widget>? actions;

  const ResponsiveLayout({
    super.key,
    required this.child,
    required this.title,
    this.actions,
  });

  @override
  Widget build(BuildContext context) {
    final width = MediaQuery.of(context).size.width;
    final isDesktop = width > 950; // Threshold for desktop viewports

    return Scaffold(
      appBar: isDesktop
          ? null
          : AppBar(
              title: Text(title),
              actions: actions,
            ),
      drawer: isDesktop ? null : const AppDrawer(),
      body: isDesktop
          ? Row(
              children: [
                const AppSidebar(),
                Expanded(
                  child: Scaffold(
                    appBar: AppBar(
                      title: Text(title),
                      actions: actions,
                    ),
                    body: child,
                  ),
                ),
              ],
            )
          : child,
      bottomNavigationBar: isDesktop ? null : const AppBottomNav(),
    );
  }
}
