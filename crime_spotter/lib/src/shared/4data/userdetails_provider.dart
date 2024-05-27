import 'dart:convert';
import 'dart:io';

import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:crime_spotter/src/shared/model/active_user_model.dart';
import 'package:crime_spotter/src/shared/model/file_model.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

enum UserRole { crimespotter, crimefluencer, admin }

class UserDetailsProvider extends ChangeNotifier {
  UserDetailsProvider() {
    _initUserProfilePictures();
  }
  User? _currentUser;
  UserRole _userRole = UserRole.crimespotter;
  String _jwt = "";
  bool _userIsAuthenticated = false;
  List<ActiveUser> _activeUsers = [];
  final List<ActiveUser> _activeUsersIncludingCurrent = [];
  final List<FileModel> _profilePictures = [];

  String get jwt => _jwt;
  UserRole get userRole => _userRole;
  bool get userIsAuthenticated => _userIsAuthenticated;
  User get currentUser => _currentUser!;
  List<ActiveUser> get activeUsers => _activeUsers;
  List<ActiveUser> get activeUsersIncludingCurrent =>
      _activeUsersIncludingCurrent;
  List<FileModel> get profilePictures => _profilePictures;

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
      _activeUsersIncludingCurrent.add(
        ActiveUser(
          name: entry['username'],
          role: convertStringToUserRole(entry['role']),
          id: entry['id'],
        ),
      );
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

      bool foundInSecondList =
          _activeUsersIncludingCurrent.any((element) => element.id == user.id);
      if (foundInSecondList) {
        _activeUsersIncludingCurrent.remove(
          _activeUsersIncludingCurrent
              .singleWhere((element) => element.id == user.id),
        );
      }
      return true;
    }

    _activeUsersIncludingCurrent.add(user);
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
      _activeUsersIncludingCurrent
          .singleWhere((element) => element.id == user.id)
          .role = role;
    }
    notifyListeners();
    return true;
  }

  Future<void> _initUserProfilePictures() async {
    final pictures =
        await SupaBaseConst.supabase.storage.from('avatars').list();
    if (pictures.isEmpty) {
      return;
    }

    for (var image in pictures) {
      List<String> splitted = image.name.split('.');
      _profilePictures.add(
        FileModel(
          imageInBytes: await SupaBaseConst.supabase.storage
              .from('avatars')
              .download(image.name),
          userId: splitted[0],
          extension: splitted[1],
        ),
      );
    }
  }

  Future<bool> updateProfilePicture(
      {required XFile image,
      String? userId,
      bool useCurrentUser = true}) async {
    String? response;

    try {
      userId = useCurrentUser ? _currentUser?.id ?? "" : userId;
      FileModel? profileToChange = _profilePictures
          .where((element) => element.userId == userId)
          .firstOrNull;
      if (profileToChange == null) {
        String path = '$userId.${image.name.split('.').last}';
        response = await SupaBaseConst.supabase.storage.from('avatars').upload(
            path, File(image.path),
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false));
      } else {
        String path = '${profileToChange.userId}.${profileToChange.extension}';
        await SupaBaseConst.supabase.storage
            .from('avatars')
            .remove(<String>[path]);
        response = await SupaBaseConst.supabase.storage.from('avatars').upload(
            path, File(image.path),
            fileOptions:
                const FileOptions(cacheControl: '3600', upsert: false));
      }
      if (response.isNotEmpty) {
        if (profileToChange != null) {
          _profilePictures.remove(_profilePictures
              .where((element) => element.userId == userId)
              .first);
        }
        _profilePictures.add(FileModel(
            userId: userId!,
            imageInBytes: await File(image.path).readAsBytes(),
            extension: image.name.split('.').last));
      }
      notifyListeners();
      return true;
    } catch (ex) {
      return false;
    }
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
