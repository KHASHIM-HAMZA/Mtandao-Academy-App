// import 'package:flutter/material.dart';
// import 'package:mtandao_admin_panel/components/sidebar.dart';
// import 'package:mtandao_admin_panel/components/topbar.dart';
// import 'package:mtandao_admin_panel/models/user_model.dart';
// import 'package:mtandao_admin_panel/pages/users/UserFilters.dart';
// import 'package:mtandao_admin_panel/providers/users_provider.dart';
// import 'package:mtandao_admin_panel/widget/users_table.dart';
// import 'package:provider/provider.dart';
// import 'user_detail_page.dart';
// import 'user_create_page.dart';

// class UsersPage extends StatefulWidget {
//   const UsersPage({super.key});

//   @override
//   State<UsersPage> createState() => _UsersPageState();
// }

// class _UsersPageState extends State<UsersPage> {
//   final ScrollController _scrollController = ScrollController();
//   bool _isLoadingMore = false;

//   @override
//   void initState() {
//     super.initState();
//     _loadUsers();
//     _scrollController.addListener(_scrollListener);
//   }

//   @override
//   void dispose() {
//     _scrollController.dispose();
//     super.dispose();
//   }

//   void _loadUsers() {
//     WidgetsBinding.instance.addPostFrameCallback((_) {
//       final provider = Provider.of<UsersProvider>(context, listen: false);
//       provider.loadUsers(refresh: true);
//     });
//   }

//   void _scrollListener() {
//     final provider = Provider.of<UsersProvider>(context, listen: false);

//     if (_scrollController.offset >=
//             _scrollController.position.maxScrollExtent - 200 &&
//         !_isLoadingMore &&
//         provider.currentPage < provider.totalPages) {
//       _loadMoreUsers();
//     }
//   }

//   void _loadMoreUsers() async {
//     if (_isLoadingMore) return;

//     setState(() {
//       _isLoadingMore = true;
//     });

//     final provider = Provider.of<UsersProvider>(context, listen: false);
//     await provider.loadUsers(page: provider.currentPage + 1);

//     setState(() {
//       _isLoadingMore = false;
//     });
//   }

//   void _showUserDetails(User user) {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => UserDetailPage(user: user)),
//     );
//   }

//   void _createNewUser() {
//     Navigator.push(
//       context,
//       MaterialPageRoute(builder: (context) => const UserCreatePage()),
//     );
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Row(
//         children: [
//           const AdminSidebar(),
//           Expanded(
//             child: Column(
//               children: [
//                 const AdminTopBar(title: 'Users Management'),
//                 Expanded(
//                   child: Consumer<UsersProvider>(
//                     builder: (context, provider, child) {
//                       return Padding(
//                         padding: const EdgeInsets.all(24),
//                         child: Column(
//                           crossAxisAlignment: CrossAxisAlignment.start,
//                           children: [
//                             // Header with actions
//                             _buildHeader(provider),

//                             const SizedBox(height: 16),

//                             // Filters
//                             UserFilters(onFiltersChanged: () => _loadUsers()),

//                             const SizedBox(height: 16),

//                             // Users Table
//                             Expanded(child: _buildContent(provider)),

//                             // Pagination Info
//                             _buildPaginationInfo(provider),
//                           ],
//                         ),
//                       );
//                     },
//                   ),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader(UsersProvider provider) {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Students Management',
//               style: TextStyle(
//                 fontSize: 24,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               '${provider.totalUsers} students found',
//               style: TextStyle(fontSize: 14, color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             // Export Button
//             OutlinedButton.icon(
//               onPressed: () => _exportUsers(),
//               icon: const Icon(Icons.download, size: 16),
//               label: const Text('Export'),
//               style: OutlinedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 16,
//                   vertical: 12,
//                 ),
//               ),
//             ),
//             const SizedBox(width: 12),
//             // Add User Button
//             ElevatedButton.icon(
//               onPressed: _createNewUser,
//               icon: const Icon(Icons.person_add, size: 16),
//               label: const Text('Add New Student'),
//               style: ElevatedButton.styleFrom(
//                 padding: const EdgeInsets.symmetric(
//                   horizontal: 20,
//                   vertical: 12,
//                 ),
//                 backgroundColor: Colors.blue,
//                 foregroundColor: Colors.white,
//               ),
//             ),
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildContent(UsersProvider provider) {
//     if (provider.isLoading && provider.users.isEmpty) {
//       return const Center(child: CircularProgressIndicator());
//     }

//     if (provider.error != null && provider.users.isEmpty) {
//       return Center(
//         child: Column(
//           mainAxisAlignment: MainAxisAlignment.center,
//           children: [
//             Icon(Icons.error_outline, size: 64, color: Colors.red.shade400),
//             const SizedBox(height: 16),
//             Text(
//               'Failed to load users',
//               style: TextStyle(fontSize: 18, color: Colors.grey.shade700),
//             ),
//             const SizedBox(height: 8),
//             Text(
//               provider.error!,
//               textAlign: TextAlign.center,
//               style: TextStyle(color: Colors.grey.shade500),
//             ),
//             const SizedBox(height: 16),
//             ElevatedButton(
//               onPressed: _loadUsers,
//               child: const Text('Try Again'),
//             ),
//           ],
//         ),
//       );
//     }

//     return Column(
//       children: [
//         Expanded(
//           child: UsersTable(
//             users: provider.users,
//             onUserSelected: _showUserDetails,
//             scrollController: _scrollController,
//           ),
//         ),

//         // Loading more indicator
//         if (_isLoadingMore)
//           const Padding(
//             padding: EdgeInsets.all(16),
//             child: CircularProgressIndicator(),
//           ),
//       ],
//     );
//   }

//   Widget _buildPaginationInfo(UsersProvider provider) {
//     return Container(
//       padding: const EdgeInsets.all(16),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         mainAxisAlignment: MainAxisAlignment.spaceBetween,
//         children: [
//           Text(
//             'Page ${provider.currentPage} of ${provider.totalPages}',
//             style: TextStyle(color: Colors.grey.shade600),
//           ),
//           Text(
//             'Total: ${provider.totalUsers} students',
//             style: TextStyle(
//               fontWeight: FontWeight.w500,
//               color: Colors.grey.shade700,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   void _exportUsers() {
//     // Implement export functionality
//     ScaffoldMessenger.of(context).showSnackBar(
//       const SnackBar(
//         content: Text('Export functionality will be implemented soon'),
//         backgroundColor: Colors.blue,
//       ),
//     );
//   }
// }
