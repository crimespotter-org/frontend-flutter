import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:flutter/material.dart';

class ButtonController {
  static List<FloatingActionButton> itemsActionBar(
      BuildContext context, bool isAdmin) {
    List<FloatingActionButton> list = [];
    list.add(
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
    );
    list.add(
      FloatingActionButton(
        heroTag: "explore",
        backgroundColor: Colors.blueAccent,
        onPressed: () async {
          Navigator.pushNamed(context, UIData.explore);
        },
        tooltip: "Entdecken",
        child: const Icon(Icons.explore),
      ),
    );

    if (isAdmin) {
      list.add(
        FloatingActionButton(
          heroTag: "changeRole",
          backgroundColor: Colors.grey,
          onPressed: () async {
            Navigator.pushNamed(context, UIData.settings);
          },
          tooltip: "Rollen verwalten",
          child: const Icon(Icons.settings),
        ),
      );
    }
    return list;
  }
}
