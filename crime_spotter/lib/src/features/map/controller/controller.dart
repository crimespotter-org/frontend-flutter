import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:flutter/material.dart';

class ButtonController {
  static Future<List<Map<String, dynamic>>> updateUserRole(String role) async {
    return await SupaBaseConst.supabase
        .from('user_profiles')
        .update({'role': role})
        .eq('id', SupaBaseConst.currentUser!.id)
        .select();
  }

  static List<FloatingActionButton> itemsActionBar(BuildContext context) {
    return [
      FloatingActionButton(
        heroTag: "signOut",
        backgroundColor: Colors.greenAccent,
        onPressed: () {
          SupaBaseConst.supabase.auth.signOut();
          Navigator.pushReplacementNamed(context, UIData.logIn);
        },
        tooltip: "Ausloggen",
        child: const Icon(Icons.add),
      ),
      FloatingActionButton(
        heroTag: "explore",
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          Navigator.pushNamed(context, UIData.explore);
        },
        tooltip: "Entdecken",
        child: const Icon(Icons.explore),
      ),
      FloatingActionButton(
        heroTag: "settings",
        backgroundColor: Colors.grey,
        onPressed: () async {
          Navigator.pushNamed(context, UIData.settings);
        },
        tooltip: "Einstellungen",
        child: const Icon(Icons.settings),
      ),
    ];
  }
}
