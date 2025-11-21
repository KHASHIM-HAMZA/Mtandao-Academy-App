import 'package:flutter/material.dart';
import '../services/admin_service.dart';
import '../models/user_model.dart';

class UsersProvider with ChangeNotifier {
  final AdminService _adminService = AdminService();

  List<User> _users = [];
  User? _selectedUser;
  bool _isLoading = false;
  String? _error;
  int _currentPage = 1;
  int _totalPages = 1;
  int _totalUsers = 0;

  // Filter states
  String _searchQuery = '';
  String _selectedLevel = 'all';
  String _selectedStatus = 'all';
  String _selectedRegion = 'all';

  List<User> get users => _users;
  User? get selectedUser => _selectedUser;
  bool get isLoading => _isLoading;
  String? get error => _error;
  int get currentPage => _currentPage;
  int get totalPages => _totalPages;
  int get totalUsers => _totalUsers;

  // Filter getters
  String get searchQuery => _searchQuery;
  String get selectedLevel => _selectedLevel;
  String get selectedStatus => _selectedStatus;
  String get selectedRegion => _selectedRegion;

  // Load users with pagination and filters
  Future<void> loadUsers({int page = 1, bool refresh = false}) async {
    if (refresh) {
      _currentPage = 1;
    } else {
      _isLoading = true;
    }

    notifyListeners();

    try {
      final response = await _adminService.getUsers(
        page: page,
        search: _searchQuery.isNotEmpty ? _searchQuery : null,
        level: _selectedLevel != 'all' ? _selectedLevel : null,
        status: _selectedStatus != 'all' ? _selectedStatus : null,
        region: _selectedRegion != 'all' ? _selectedRegion : null,
      );

      if (refresh || page == 1) {
        _users =
            (response['data'] as List)
                .map((userData) => User.fromJson(userData))
                .toList();
      } else {
        _users.addAll(
          (response['data'] as List)
              .map((userData) => User.fromJson(userData))
              .toList(),
        );
      }

      _currentPage = response['currentPage'] ?? page;
      _totalPages = response['totalPages'] ?? 1;
      _totalUsers = response['totalUsers'] ?? 0;
      _error = null;
    } catch (e) {
      _error = e.toString();
      // Load mock data for development
      if (_users.isEmpty) {
        _users = _getMockUsers();
        _totalUsers = _users.length;
        _totalPages = 1;
      }
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  // Set filters
  void setSearchQuery(String query) {
    _searchQuery = query;
    loadUsers(page: 1, refresh: true);
  }

  void setLevelFilter(String level) {
    _selectedLevel = level;
    loadUsers(page: 1, refresh: true);
  }

  void setStatusFilter(String status) {
    _selectedStatus = status;
    loadUsers(page: 1, refresh: true);
  }

  void setRegionFilter(String region) {
    _selectedRegion = region;
    loadUsers(page: 1, refresh: true);
  }

  void clearFilters() {
    _searchQuery = '';
    _selectedLevel = 'all';
    _selectedStatus = 'all';
    _selectedRegion = 'all';
    loadUsers(page: 1, refresh: true);
  }

  // User operations
  Future<void> selectUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      _selectedUser = await _adminService.getUserById(userId);
      _error = null;
    } catch (e) {
      _error = e.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> createUser(Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final newUser = await _adminService.createUser(userData);
      _users.insert(0, newUser);
      _totalUsers++;
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> updateUser(String userId, Map<String, dynamic> userData) async {
    _isLoading = true;
    notifyListeners();

    try {
      final updatedUser = await _adminService.updateUser(userId, userData);
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = updatedUser;
      }
      if (_selectedUser?.id == userId) {
        _selectedUser = updatedUser;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> deleteUser(String userId) async {
    _isLoading = true;
    notifyListeners();

    try {
      await _adminService.deleteUser(userId);
      _users.removeWhere((user) => user.id == userId);
      _totalUsers--;
      if (_selectedUser?.id == userId) {
        _selectedUser = null;
      }
      _error = null;
    } catch (e) {
      _error = e.toString();
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> toggleUserStatus(String userId, bool isActive) async {
    try {
      await _adminService.toggleUserStatus(userId, isActive);
      final index = _users.indexWhere((user) => user.id == userId);
      if (index != -1) {
        _users[index] = _users[index].copyWith(isActive: isActive);
      }
      if (_selectedUser?.id == userId) {
        _selectedUser = _selectedUser!.copyWith(isActive: isActive);
      }
      notifyListeners();
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  Future<void> resetUserPassword(String userId) async {
    try {
      await _adminService.resetUserPassword(userId);
    } catch (e) {
      _error = e.toString();
      rethrow;
    }
  }

  // Mock data for development
  List<User> _getMockUsers() {
    return [
      User(
        id: '1',
        name: 'John Student',
        email: 'john.student@mtandao.academy',
        phone: '+255 789 456 123',
        level: 'O-Level',
        subLevel: 'Form 3',
        school: 'Mlimani Secondary School',
        region: 'Dar es Salaam',
        joinDate: DateTime(2024, 1, 15),
        isActive: true,
        status: 'active',
        resourcesDownloaded: 24,
        testsCompleted: 12,
        lastLogin: DateTime.now().subtract(const Duration(hours: 2)),
        subscriptionStatus: 'active',
      ),
      User(
        id: '2',
        name: 'Sarah Johnson',
        email: 'sarah.j@mtandao.academy',
        phone: '+255 712 345 678',
        level: 'A-Level',
        subLevel: 'Form 6',
        school: 'Kibo High School',
        region: 'Arusha',
        joinDate: DateTime(2024, 2, 10),
        isActive: true,
        status: 'active',
        resourcesDownloaded: 45,
        testsCompleted: 18,
        lastLogin: DateTime.now().subtract(const Duration(days: 1)),
        subscriptionStatus: 'active',
      ),
      User(
        id: '3',
        name: 'Michael Chen',
        email: 'michael.c@mtandao.academy',
        phone: '+255 767 890 123',
        level: 'Primary',
        subLevel: 'Standard 7',
        school: 'Uhuru Primary School',
        region: 'Mwanza',
        joinDate: DateTime(2024, 3, 5),
        isActive: false,
        status: 'inactive',
        resourcesDownloaded: 8,
        testsCompleted: 3,
        lastLogin: DateTime.now().subtract(const Duration(days: 30)),
        subscriptionStatus: 'expired',
      ),
    ];
  }
}
