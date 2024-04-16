import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class SupaBaseConst {
  static User? currentUser;
  static final supabase = Supabase.instance.client;

  static Future<bool> userIsAuthenticated(BuildContext context) async {
    final session = supabase.auth.currentSession;
    return session != null;
  }
}
