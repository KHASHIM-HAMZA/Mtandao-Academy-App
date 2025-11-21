import 'package:flutter/material.dart';
import 'package:mtandao_admin_panel/models/user_model.dart';

class UsersTable extends StatelessWidget {
  final List<User> users;
  final Function(User) onUserSelected;
  final ScrollController scrollController;

  const UsersTable({
    super.key,
    required this.users,
    required this.onUserSelected,
    required this.scrollController,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(
            color: Colors.grey.shade200,
            blurRadius: 8,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: Scrollbar(
        controller: scrollController,
        child: ListView(
          controller: scrollController,
          children: [
            // Table Header
            _buildTableHeader(),

            // Table Rows
            ...users.map((user) => _buildUserRow(user, context)),
          ],
        ),
      ),
    );
  }

  Widget _buildTableHeader() {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        border: Border(bottom: BorderSide(color: Colors.grey.shade200)),
      ),
      child: const Row(
        children: [
          Expanded(
            flex: 2,
            child: Text(
              'Student',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text('Level', style: TextStyle(fontWeight: FontWeight.w600)),
          ),
          Expanded(
            child: Text(
              'School',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              'Region',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              'Status',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              'Downloads',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          Expanded(
            child: Text(
              'Last Login',
              style: TextStyle(fontWeight: FontWeight.w600),
            ),
          ),
          SizedBox(width: 100), // Actions column
        ],
      ),
    );
  }

  Widget _buildUserRow(User user, BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
      ),
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: InkWell(
          onTap: () => onUserSelected(user),
          child: Row(
            children: [
              // Student Info
              Expanded(
                flex: 2,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      user.name,
                      style: const TextStyle(
                        fontWeight: FontWeight.w500,
                        fontSize: 14,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      user.email,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                    const SizedBox(height: 2),
                    Text(
                      user.phone,
                      style: TextStyle(
                        fontSize: 12,
                        color: Colors.grey.shade600,
                      ),
                    ),
                  ],
                ),
              ),

              // Level
              Expanded(
                child: Text(
                  '${user.level}\n${user.subLevel}',
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),

              // School
              Expanded(
                child: Text(
                  user.school,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                  overflow: TextOverflow.ellipsis,
                ),
              ),

              // Region
              Expanded(
                child: Text(
                  user.region,
                  style: TextStyle(fontSize: 13, color: Colors.grey.shade700),
                ),
              ),

              // Status
              Expanded(child: _buildStatusBadge(user)),

              // Downloads
              Expanded(
                child: Text(
                  '${user.resourcesDownloaded}',
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey.shade700,
                    fontWeight: FontWeight.w500,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Last Login
              Expanded(
                child: Text(
                  user.lastLogin != null
                      ? _formatLastLogin(user.lastLogin!)
                      : 'Never',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
                ),
              ),

              // Actions
              SizedBox(
                width: 100,
                child: UserActions(
                  user: user,
                  onActionComplete: () {
                    // Refresh the list if needed
                  },
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStatusBadge(User user) {
    Color color;
    String text;

    if (!user.isActive) {
      color = Colors.red;
      text = 'Inactive';
    } else if (user.subscriptionStatus == 'active') {
      color = Colors.green;
      text = 'Active';
    } else {
      color = Colors.orange;
      text = 'No Subscription';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.3)),
      ),
      child: Text(
        text,
        style: TextStyle(
          color: color,
          fontSize: 11,
          fontWeight: FontWeight.w500,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  String _formatLastLogin(DateTime lastLogin) {
    final now = DateTime.now();
    final difference = now.difference(lastLogin);

    if (difference.inMinutes < 60) {
      return '${difference.inMinutes}m ago';
    } else if (difference.inHours < 24) {
      return '${difference.inHours}h ago';
    } else {
      return '${difference.inDays}d ago';
    }
  }

  UserActions({
    required User user,
    required Null Function() onActionComplete,
  }) {}
}
