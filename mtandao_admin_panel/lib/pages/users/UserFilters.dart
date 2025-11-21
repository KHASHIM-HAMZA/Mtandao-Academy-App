import 'dart:async';

import 'package:flutter/material.dart';
import 'package:mtandao_admin_panel/providers/users_provider.dart';
import 'package:provider/provider.dart';

class UserFilters extends StatefulWidget {
  final VoidCallback onFiltersChanged;

  const UserFilters({super.key, required this.onFiltersChanged});

  @override
  State<UserFilters> createState() => _UserFiltersState();
}

class _UserFiltersState extends State<UserFilters> {
  final TextEditingController _searchController = TextEditingController();
  Timer? _searchDebounce;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(_onSearchChanged);
  }

  @override
  void dispose() {
    _searchDebounce?.cancel();
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged() {
    if (_searchDebounce?.isActive ?? false) _searchDebounce?.cancel();

    _searchDebounce = Timer(const Duration(milliseconds: 500), () {
      final provider = Provider.of<UsersProvider>(context, listen: false);
      provider.setSearchQuery(_searchController.text.trim());
      widget.onFiltersChanged();
    });
  }

  void _clearFilters() {
    _searchController.clear();
    final provider = Provider.of<UsersProvider>(context, listen: false);
    provider.clearFilters();
    widget.onFiltersChanged();
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<UsersProvider>(
      builder: (context, provider, child) {
        return Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(12),
            boxShadow: [
              BoxShadow(
                color: Colors.grey.shade200,
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Column(
            children: [
              // Search and Quick Filters
              Row(
                children: [
                  // Search Box
                  Expanded(
                    child: Container(
                      height: 40,
                      decoration: BoxDecoration(
                        color: Colors.grey.shade50,
                        borderRadius: BorderRadius.circular(8),
                        border: Border.all(color: Colors.grey.shade300),
                      ),
                      child: Row(
                        children: [
                          const SizedBox(width: 12),
                          Icon(
                            Icons.search,
                            size: 20,
                            color: Colors.grey.shade500,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: TextField(
                              controller: _searchController,
                              decoration: const InputDecoration(
                                hintText: 'Search by name, email, or phone...',
                                border: InputBorder.none,
                                hintStyle: TextStyle(fontSize: 14),
                              ),
                              style: const TextStyle(fontSize: 14),
                            ),
                          ),
                          if (_searchController.text.isNotEmpty)
                            IconButton(
                              icon: Icon(
                                Icons.clear,
                                size: 16,
                                color: Colors.grey.shade500,
                              ),
                              onPressed: () {
                                _searchController.clear();
                                provider.setSearchQuery('');
                                widget.onFiltersChanged();
                              },
                            ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(width: 16),

                  // Clear Filters
                  OutlinedButton.icon(
                    onPressed: _clearFilters,
                    icon: const Icon(Icons.filter_alt_off, size: 16),
                    label: const Text('Clear Filters'),
                    style: OutlinedButton.styleFrom(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 10,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // Filter Chips
              Wrap(
                spacing: 12,
                runSpacing: 8,
                children: [
                  _buildLevelFilter(provider),
                  _buildStatusFilter(provider),
                  _buildRegionFilter(provider),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildLevelFilter(UsersProvider provider) {
    const levels = ['all', 'Primary', 'O-Level', 'A-Level'];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.school, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          const Text(
            'Level:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedLevel,
              icon: const Icon(Icons.arrow_drop_down, size: 16),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  provider.setLevelFilter(newValue);
                  widget.onFiltersChanged();
                }
              },
              items:
                  levels.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'all' ? 'All Levels' : value,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatusFilter(UsersProvider provider) {
    const statuses = [
      {'value': 'all', 'label': 'All Status'},
      {'value': 'active', 'label': 'Active'},
      {'value': 'inactive', 'label': 'Inactive'},
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.circle, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          const Text(
            'Status:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedStatus,
              icon: const Icon(Icons.arrow_drop_down, size: 16),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  provider.setStatusFilter(newValue);
                  widget.onFiltersChanged();
                }
              },
              items:
                  statuses.map<DropdownMenuItem<String>>((status) {
                    return DropdownMenuItem<String>(
                      value: status['value'],
                      child: Text(
                        status['label']!,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRegionFilter(UsersProvider provider) {
    const regions = [
      'all',
      'Dar es Salaam',
      'Arusha',
      'Mwanza',
      'Mbeya',
      'Dodoma',
      'Tanga',
      'Morogoro',
      'Moshi',
      'Zanzibar',
    ];

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
      decoration: BoxDecoration(
        color: Colors.grey.shade50,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.grey.shade300),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.location_on, size: 16, color: Colors.grey),
          const SizedBox(width: 6),
          const Text(
            'Region:',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.w500),
          ),
          const SizedBox(width: 6),
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              value: provider.selectedRegion,
              icon: const Icon(Icons.arrow_drop_down, size: 16),
              style: const TextStyle(fontSize: 12, color: Colors.black87),
              onChanged: (String? newValue) {
                if (newValue != null) {
                  provider.setRegionFilter(newValue);
                  widget.onFiltersChanged();
                }
              },
              items:
                  regions.map<DropdownMenuItem<String>>((String value) {
                    return DropdownMenuItem<String>(
                      value: value,
                      child: Text(
                        value == 'all' ? 'All Regions' : value,
                        style: const TextStyle(fontSize: 12),
                      ),
                    );
                  }).toList(),
            ),
          ),
        ],
      ),
    );
  }
}
