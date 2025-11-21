import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:mtandao_admin_panel/utils/app_color.dart';

class AdminSidebar extends StatelessWidget {
  final bool isCollapsed;
  final VoidCallback? onToggle;

  const AdminSidebar({super.key, required this.isCollapsed, this.onToggle});

  @override
  Widget build(BuildContext context) {
    final currentRoute = GoRouterState.of(context).matchedLocation;

    return Container(
      width: isCollapsed ? 80 : 280,
      decoration: BoxDecoration(
        color: Colors.white,
        border: Border(right: BorderSide(color: Colors.grey.shade200)),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.05),
            blurRadius: 10,
            offset: const Offset(2, 0),
          ),
        ],
      ),
      child: Column(
        children: [
          // Header
          Container(
            height: 80,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            decoration: BoxDecoration(
              border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
            ),
            child: Row(
              children: [
                if (!isCollapsed) ...[
                  Image.asset(
                    'assets/logo.png',
                    height: 40,
                    width: 40,
                    errorBuilder:
                        (context, error, stackTrace) => Container(
                          height: 40,
                          width: 40,
                          decoration: BoxDecoration(
                            color: AppColors.primary,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.school, color: Colors.white),
                        ),
                  ),
                  const SizedBox(width: 12),
                  const Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Mtandao Academy',
                          style: TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.bold,
                            color: AppColors.primary,
                          ),
                        ),
                        Text(
                          'Admin Panel',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                ] else ...[
                  Expanded(
                    child: Center(
                      child: Image.asset(
                        'assets/logo.png',
                        height: 32,
                        width: 32,
                        errorBuilder:
                            (context, error, stackTrace) => Container(
                              height: 32,
                              width: 32,
                              decoration: BoxDecoration(
                                color: AppColors.primary,
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: const Icon(
                                Icons.school,
                                color: Colors.white,
                                size: 18,
                              ),
                            ),
                      ),
                    ),
                  ),
                ],
                if (onToggle != null)
                  IconButton(
                    icon: Icon(
                      isCollapsed ? Icons.chevron_right : Icons.chevron_left,
                      color: Colors.grey.shade600,
                    ),
                    onPressed: onToggle,
                    tooltip:
                        isCollapsed ? 'Expand sidebar' : 'Collapse sidebar',
                  ),
              ],
            ),
          ),

          // Navigation Items
          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(vertical: 16),
              children: [
                _NavItem(
                  icon: Icons.dashboard,
                  label: 'Dashboard',
                  isActive: currentRoute == '/',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/'),
                ),
                _NavItem(
                  icon: Icons.people,
                  label: 'User Management',
                  isActive: currentRoute == '/users',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/users'),
                ),
                _NavItem(
                  icon: Icons.school,
                  label: 'Teacher Management',
                  isActive: currentRoute == '/teachers',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/teachers'),
                ),
                _NavItem(
                  icon: Icons.library_books,
                  label: 'Resource Manager',
                  isActive: currentRoute == '/resources',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/resources'),
                ),
                _NavItem(
                  icon: Icons.assignment,
                  label: 'Pastpapers',
                  isActive: currentRoute == '/pastpapers',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/pastpapers'),
                ),
                _NavItem(
                  icon: Icons.assignment_turned_in,
                  label: 'Corrections',
                  isActive: currentRoute == '/corrections',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/corrections'),
                ),
                _NavItem(
                  icon: Icons.credit_card,
                  label: 'Subscriptions',
                  isActive: currentRoute == '/subscriptions',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/subscriptions'),
                ),
                _NavItem(
                  icon: Icons.support_agent,
                  label: 'Support Tickets',
                  isActive: currentRoute == '/support',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/support'),
                ),
                _NavItem(
                  icon: Icons.settings,
                  label: 'Settings',
                  isActive: currentRoute == '/settings',
                  isCollapsed: isCollapsed,
                  onTap: () => context.go('/settings'),
                ),
              ],
            ),
          ),

          // Footer
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              border: Border(top: BorderSide(color: Colors.grey.shade200)),
            ),
            child:
                isCollapsed
                    ? IconButton(
                      icon: const Icon(Icons.logout, color: Colors.red),
                      onPressed: () => _showLogoutDialog(context),
                    )
                    : OutlinedButton.icon(
                      icon: const Icon(Icons.logout, size: 18),
                      label: const Text('Logout'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: Colors.red,
                        side: const BorderSide(color: Colors.red),
                      ),
                      onPressed: () => _showLogoutDialog(context),
                    ),
          ),
        ],
      ),
    );
  }

  void _showLogoutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Logout'),
            content: const Text('Are you sure you want to logout?'),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Cancel'),
              ),
              TextButton(
                onPressed: () {
                  Navigator.pop(context);
                  // Implement logout logic
                  context.go('/login');
                },
                child: const Text(
                  'Logout',
                  style: TextStyle(color: Colors.red),
                ),
              ),
            ],
          ),
    );
  }
}

class _NavItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final bool isActive;
  final bool isCollapsed;
  final VoidCallback onTap;

  const _NavItem({
    required this.icon,
    required this.label,
    required this.isActive,
    required this.isCollapsed,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color:
            isActive ? AppColors.primary.withOpacity(0.1) : Colors.transparent,
        borderRadius: BorderRadius.circular(8),
        border:
            isActive
                ? Border.all(color: AppColors.primary.withOpacity(0.3))
                : null,
      ),
      child: ListTile(
        leading: Icon(
          icon,
          color: isActive ? AppColors.primary : Colors.grey.shade700,
          size: 20,
        ),
        title:
            isCollapsed
                ? null
                : Text(
                  label,
                  style: TextStyle(
                    fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
                    color: isActive ? AppColors.primary : Colors.grey.shade700,
                  ),
                ),
        minLeadingWidth: 0,
        contentPadding: EdgeInsets.symmetric(
          horizontal: isCollapsed ? 16 : 12,
          vertical: 4,
        ),
        onTap: onTap,
      ),
    );
  }
}
