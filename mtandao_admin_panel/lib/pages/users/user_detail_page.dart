// import 'package:flutter/material.dart';
// import 'package:mtandao_admin_panel/components/topbar.dart';
// import 'package:mtandao_admin_panel/models/user_model.dart';
// import 'package:mtandao_admin_panel/providers/users_provider.dart';
// import 'package:provider/provider.dart';

// class UserDetailPage extends StatefulWidget {
//   final User user;

//   const UserDetailPage({super.key, required this.user});

//   @override
//   State<UserDetailPage> createState() => _UserDetailPageState();
// }

// class _UserDetailPageState extends State<UserDetailPage> {
//   late User _user;
//   bool _isEditing = false;
//   final _formKey = GlobalKey<FormState>();

//   // Form controllers
//   final TextEditingController _nameController = TextEditingController();
//   final TextEditingController _emailController = TextEditingController();
//   final TextEditingController _phoneController = TextEditingController();
//   final TextEditingController _schoolController = TextEditingController();
//   final TextEditingController _regionController = TextEditingController();

//   @override
//   void initState() {
//     super.initState();
//     _user = widget.user;
//     _initializeForm();
//   }

//   void _initializeForm() {
//     _nameController.text = _user.name;
//     _emailController.text = _user.email;
//     _phoneController.text = _user.phone;
//     _schoolController.text = _user.school;
//     _regionController.text = _user.region;
//   }

//   void _toggleEdit() {
//     setState(() {
//       _isEditing = !_isEditing;
//       if (!_isEditing) {
//         _initializeForm(); // Reset form when canceling edit
//       }
//     });
//   }

//   Future<void> _saveChanges() async {
//     if (_formKey.currentState!.validate()) {
//       final provider = Provider.of<UsersProvider>(context, listen: false);

//       try {
//         final updatedUser = await provider.updateUser(_user.id, {
//           'name': _nameController.text.trim(),
//           'email': _emailController.text.trim(),
//           'phone': _phoneController.text.trim(),
//           'school': _schoolController.text.trim(),
//           'region': _regionController.text.trim(),
//           'level': _user.level,
//           'subLevel': _user.subLevel,
//         });

//         setState(() {
//           // _user = updatedUser;
//           _isEditing = false;
//         });

//         ScaffoldMessenger.of(context).showSnackBar(
//           const SnackBar(
//             content: Text('User updated successfully'),
//             backgroundColor: Colors.green,
//           ),
//         );
//       } catch (e) {
//         ScaffoldMessenger.of(context).showSnackBar(
//           SnackBar(
//             content: Text('Failed to update user: $e'),
//             backgroundColor: Colors.red,
//           ),
//         );
//       }
//     }
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Column(
//         children: [
//           AdminTopBar(title: 'Student Details'),
//           Expanded(
//             child: SingleChildScrollView(
//               padding: const EdgeInsets.all(24),
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   // Header with actions
//                   _buildHeader(),

//                   const SizedBox(height: 24),

//                   // User Info Cards
//                   Row(
//                     crossAxisAlignment: CrossAxisAlignment.start,
//                     children: [
//                       // Basic Information
//                       Expanded(flex: 2, child: _buildBasicInfoCard()),

//                       const SizedBox(width: 24),

//                       // Statistics & Actions
//                       Expanded(
//                         flex: 1,
//                         child: Column(
//                           children: [
//                             _buildStatisticsCard(),
//                             const SizedBox(height: 16),
//                             _buildQuickActionsCard(),
//                           ],
//                         ),
//                       ),
//                     ],
//                   ),

//                   const SizedBox(height: 24),

//                   // Activity History
//                   _buildActivityCard(),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildHeader() {
//     return Row(
//       mainAxisAlignment: MainAxisAlignment.spaceBetween,
//       children: [
//         Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             Text(
//               _user.name,
//               style: const TextStyle(
//                 fontSize: 28,
//                 fontWeight: FontWeight.bold,
//                 color: Colors.black87,
//               ),
//             ),
//             const SizedBox(height: 4),
//             Text(
//               _user.email,
//               style: TextStyle(fontSize: 16, color: Colors.grey.shade600),
//             ),
//           ],
//         ),
//         Row(
//           children: [
//             if (_isEditing) ...[
//               OutlinedButton(
//                 onPressed: _toggleEdit,
//                 child: const Text('Cancel'),
//               ),
//               const SizedBox(width: 12),
//               ElevatedButton(
//                 onPressed: _saveChanges,
//                 child: const Text('Save Changes'),
//               ),
//             ] else ...[
//               OutlinedButton.icon(
//                 onPressed: _toggleEdit,
//                 icon: const Icon(Icons.edit, size: 16),
//                 label: const Text('Edit'),
//               ),
//               const SizedBox(width: 12),
//               _buildStatusToggle(),
//             ],
//           ],
//         ),
//       ],
//     );
//   }

//   Widget _buildStatusToggle() {
//     return Container(
//       padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
//       decoration: BoxDecoration(
//         color: _user.isActive ? Colors.green.shade50 : Colors.red.shade50,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(
//           color: _user.isActive ? Colors.green.shade200 : Colors.red.shade200,
//         ),
//       ),
//       child: Row(
//         mainAxisSize: MainAxisSize.min,
//         children: [
//           Icon(
//             _user.isActive ? Icons.check_circle : Icons.cancel,
//             size: 16,
//             color: _user.isActive ? Colors.green : Colors.red,
//           ),
//           const SizedBox(width: 6),
//           Text(
//             _user.isActive ? 'Active' : 'Inactive',
//             style: TextStyle(
//               color: _user.isActive ? Colors.green : Colors.red,
//               fontWeight: FontWeight.w500,
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildBasicInfoCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Basic Information',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 20),

//             _isEditing ? _buildEditForm() : _buildReadOnlyInfo(),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildReadOnlyInfo() {
//     return Column(
//       children: [
//         _buildInfoRow('Full Name', _user.name),
//         _buildInfoRow('Email', _user.email),
//         _buildInfoRow('Phone', _user.phone),
//         _buildInfoRow('Education Level', '${_user.level} - ${_user.subLevel}'),
//         _buildInfoRow('School', _user.school),
//         _buildInfoRow('Region', _user.region),
//         _buildInfoRow('Member Since', _formatDate(_user.joinDate)),
//         _buildInfoRow(
//           'Last Login',
//           _user.lastLogin != null ? _formatDate(_user.lastLogin!) : 'Never',
//         ),
//         _buildInfoRow('Subscription', _user.subscriptionStatus.toUpperCase()),
//       ],
//     );
//   }

//   Widget _buildEditForm() {
//     return Form(
//       key: _formKey,
//       child: Column(
//         children: [
//           _buildFormField('Full Name', _nameController, Icons.person),
//           const SizedBox(height: 16),
//           _buildFormField('Email', _emailController, Icons.email),
//           const SizedBox(height: 16),
//           _buildFormField('Phone', _phoneController, Icons.phone),
//           const SizedBox(height: 16),
//           _buildFormField('School', _schoolController, Icons.school),
//           const SizedBox(height: 16),
//           _buildFormField('Region', _regionController, Icons.location_on),
//         ],
//       ),
//     );
//   }

//   Widget _buildFormField(
//     String label,
//     TextEditingController controller,
//     IconData icon,
//   ) {
//     return TextFormField(
//       controller: controller,
//       decoration: InputDecoration(
//         labelText: label,
//         prefixIcon: Icon(icon),
//         border: const OutlineInputBorder(),
//       ),
//       validator: (value) {
//         if (value == null || value.isEmpty) {
//           return 'Please enter $label';
//         }
//         return null;
//       },
//     );
//   }

//   Widget _buildInfoRow(String label, String value) {
//     return Padding(
//       padding: const EdgeInsets.symmetric(vertical: 8),
//       child: Row(
//         crossAxisAlignment: CrossAxisAlignment.start,
//         children: [
//           Expanded(
//             flex: 2,
//             child: Text(
//               label,
//               style: TextStyle(
//                 fontWeight: FontWeight.w500,
//                 color: Colors.grey.shade700,
//               ),
//             ),
//           ),
//           Expanded(
//             flex: 3,
//             child: Text(
//               value,
//               style: const TextStyle(fontWeight: FontWeight.w400),
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildStatisticsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Learning Statistics',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             _buildStatItem(
//               'Resources Downloaded',
//               '${_user.resourcesDownloaded}',
//               Icons.download,
//             ),
//             _buildStatItem(
//               'Tests Completed',
//               '${_user.testsCompleted}',
//               Icons.quiz,
//             ),
//             _buildStatItem('Study Time', '45h 30m', Icons.access_time),
//             _buildStatItem('Average Score', '78.5%', Icons.bar_chart),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildStatItem(String label, String value, IconData icon) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 12),
//       padding: const EdgeInsets.all(12),
//       decoration: BoxDecoration(
//         color: Colors.grey.shade50,
//         borderRadius: BorderRadius.circular(8),
//       ),
//       child: Row(
//         children: [
//           Icon(icon, size: 20, color: Colors.blue),
//           const SizedBox(width: 12),
//           Expanded(
//             child: Column(
//               crossAxisAlignment: CrossAxisAlignment.start,
//               children: [
//                 Text(
//                   value,
//                   style: const TextStyle(
//                     fontWeight: FontWeight.bold,
//                     fontSize: 16,
//                   ),
//                 ),
//                 Text(
//                   label,
//                   style: TextStyle(fontSize: 12, color: Colors.grey.shade600),
//                 ),
//               ],
//             ),
//           ),
//         ],
//       ),
//     );
//   }

//   Widget _buildQuickActionsCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(20),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Quick Actions',
//               style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             _buildActionButton('Reset Password', Icons.lock_reset, Colors.blue),
//             _buildActionButton(
//               _user.isActive ? 'Deactivate' : 'Activate',
//               _user.isActive ? Icons.person_off : Icons.person,
//               _user.isActive ? Colors.orange : Colors.green,
//             ),
//             _buildActionButton('Send Message', Icons.message, Colors.purple),
//             _buildActionButton('View Activity', Icons.history, Colors.teal),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActionButton(String text, IconData icon, Color color) {
//     return Container(
//       margin: const EdgeInsets.only(bottom: 8),
//       child: ListTile(
//         leading: Icon(icon, size: 20, color: color),
//         title: Text(text, style: const TextStyle(fontSize: 14)),
//         trailing: const Icon(Icons.arrow_forward_ios, size: 12),
//         onTap: () {
//           // Handle action
//           ScaffoldMessenger.of(
//             context,
//           ).showSnackBar(SnackBar(content: Text('$text action triggered')));
//         },
//         contentPadding: EdgeInsets.zero,
//       ),
//     );
//   }

//   Widget _buildActivityCard() {
//     return Card(
//       child: Padding(
//         padding: const EdgeInsets.all(24),
//         child: Column(
//           crossAxisAlignment: CrossAxisAlignment.start,
//           children: [
//             const Text(
//               'Recent Activity',
//               style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
//             ),
//             const SizedBox(height: 16),
//             _buildActivityItem('Downloaded Mathematics Notes', '2 hours ago'),
//             _buildActivityItem(
//               'Completed Physics Test - Score 85%',
//               '1 day ago',
//             ),
//             _buildActivityItem('Viewed Chemistry Resources', '2 days ago'),
//             _buildActivityItem('Downloaded Past Papers', '3 days ago'),
//             _buildActivityItem('Updated Profile Information', '1 week ago'),
//           ],
//         ),
//       ),
//     );
//   }

//   Widget _buildActivityItem(String activity, String time) {
//     return Container(
//       padding: const EdgeInsets.symmetric(vertical: 12),
//       decoration: BoxDecoration(
//         border: Border(bottom: BorderSide(color: Colors.grey.shade100)),
//       ),
//       child: Row(
//         children: [
//           Container(
//             width: 8,
//             height: 8,
//             decoration: const BoxDecoration(
//               color: Colors.green,
//               shape: BoxShape.circle,
//             ),
//           ),
//           const SizedBox(width: 12),
//           Expanded(child: Text(activity)),
//           Text(
//             time,
//             style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
//           ),
//         ],
//       ),
//     );
//   }

//   String _formatDate(DateTime date) {
//     return '${date.day}/${date.month}/${date.year}';
//   }
// }
