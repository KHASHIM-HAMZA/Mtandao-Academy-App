import 'package:flutter/material.dart';
import 'package:mtandao_admin_panel/components/sidebar.dart';
import 'package:mtandao_admin_panel/components/topbar.dart';
import 'package:responsive_framework/responsive_framework.dart';

class AdminLayout extends StatefulWidget {
  final Widget child;

  const AdminLayout({super.key, required this.child});

  @override
  State<AdminLayout> createState() => _AdminLayoutState();
}

class _AdminLayoutState extends State<AdminLayout> {
  bool _isSidebarCollapsed = false;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  void _toggleSidebar() {
    setState(() {
      _isSidebarCollapsed = !_isSidebarCollapsed;
    });
  }

  void _openDrawer() {
    _scaffoldKey.currentState?.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    final isDesktop = ResponsiveWrapper.of(context).isLargerThan(TABLET);

    return Scaffold(
      key: _scaffoldKey,
      body: Row(
        children: [
          // Sidebar - hidden on mobile
          if (isDesktop)
            AdminSidebar(
              isCollapsed: _isSidebarCollapsed,
              onToggle: _toggleSidebar,
            ),

          // Main content area
          Expanded(
            child: Column(
              children: [
                AdminTopBar(
                  onMenuPressed: isDesktop ? _toggleSidebar : _openDrawer,
                ),
                Expanded(child: widget.child),
              ],
            ),
          ),
        ],
      ),
      // Mobile drawer
      drawer: isDesktop ? null : const AdminSidebar(isCollapsed: false),
    );
  }
}
