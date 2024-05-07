import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseConst {
  static User? currentUser;
  static final supabase = Supabase.instance.client;
  static String? userRole;
  static String? jwt;

  static Future<bool> userIsAuthenticated(BuildContext context) async {
    final session = supabase.auth.currentSession;
    return session != null;
  }

  static Future<String> fetchUserRole() async {
    String role = "";
    final Map<String, dynamic> decodedToken = json.decode(
        utf8.decode(base64.decode(base64.normalize(jwt!.split(".")[1]))));

    if (decodedToken.containsKey("user_role")) {
      role = decodedToken["user_role"];
    }
    return role;
  }
}
