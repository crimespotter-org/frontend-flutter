import 'dart:convert';

import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/model/activeUserModel.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { crimespotter, crimefluencer, admin }

class UserDetailsProvider extends ChangeNotifier {
  User? _currentUser;
  UserRole _userRole = UserRole.crimespotter;
  String _jwt = "";
  bool _userIsAuthenticated = false;
  List<ActiveUser> _activeUsers = [];

  String get jwt => _jwt;
  UserRole get userRole => _userRole;
  bool get userIsAuthenticated => _userIsAuthenticated;
  User get currentUser => _currentUser!;
  List<ActiveUser> get activeUsers => _activeUsers;

  Future<List<ActiveUser>?> getAllActiveUser() async {
    final response =
        await SupaBaseConst.supabase.from('user_profiles').select();
    if (response.isEmpty) return null;

    for (var entry in response) {
      if (entry['username'] != currentUser.email) {
        _activeUsers.add(
          ActiveUser(
            name: entry['username'],
            role: convertStringToUserRole(entry['role']),
            id: entry['id'],
          ),
        );
      }
    }
    _activeUsers = _activeUsers.toSet().toList();
    return _activeUsers;
  }

  bool updateActiveUserList({required ActiveUser user, bool remove = false}) {
    if (_activeUsers.isEmpty) getAllActiveUser();

    if (remove) {
      bool userFound = _activeUsers.any((element) => element == user);
      if (!userFound) return false;

      _activeUsers.remove(
        _activeUsers.singleWhere((element) => element == user),
      );
      return true;
    }

    _activeUsers.add(user);
    return true;
  }

  void setCurrentUser(User? user) {
    _currentUser = user;
    notifyListeners();
  }

  void setUserAuthentication(Session? session) {
    _userIsAuthenticated = session != null;
    notifyListeners();
  }

  void setJWT(String jwt) {
    _jwt = jwt;
    fetchUserRoleFromJWT();
    notifyListeners();
  }

  Future<bool> updateUserRole(
      {ActiveUser? user, required UserRole role}) async {
    String userId = user == null ? _currentUser!.id : user.id;
    var response = await SupaBaseConst.supabase
        .from('user_profiles')
        .update({'role': displayUserRole(role).toLowerCase()})
        .eq('id', userId)
        .select();
    if (response.isEmpty) return false;
    if (user == null) {
      _userRole = role;
    } else {
      _activeUsers.singleWhere((element) => element == user).role = role;
    }
    notifyListeners();
    return true;
  }

  void fetchUserRoleFromJWT() {
    final Map<String, dynamic> decodedToken = json.decode(
        utf8.decode(base64.decode(base64.normalize(jwt.split(".")[1]))));

    if (decodedToken.containsKey("user_role")) {
      _userRole = convertStringToUserRole(decodedToken["user_role"]);
    } else {
      _userRole = UserRole.crimespotter;
      _userIsAuthenticated = false;
    }
    notifyListeners();
  }

  UserRole convertStringToUserRole(String role) {
    switch (role.toLowerCase()) {
      case "crimefluencer":
        return UserRole.crimefluencer;
      case "crimespotter":
        return UserRole.crimespotter;
      case "admin":
        return UserRole.admin;
      default:
        return UserRole.crimespotter;
    }
  }

  String displayUserRole(UserRole role) {
    switch (role) {
      case UserRole.crimefluencer:
        return "CrimeFluencer";
      case UserRole.crimespotter:
        return "CrimeSpotter";
      case UserRole.admin:
        return "Admin";
    }
  }
}
