import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabase_const.dart';
import 'package:flutter/material.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage> {
  @override
  void initState() {
    super.initState();
    _redirect();
  }

  Future<void> _redirect() async {
    await Future.delayed(Duration.zero);
    if (!mounted) return;

    final session = SupaBaseConst.supabase.auth.currentSession;

    if (session != null) {
      Navigator.of(context).pushReplacementNamed(UIData.homeRoute);
    } else {
      Navigator.of(context).pushReplacementNamed(UIData.logIn);
    }
  }

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body: Center(child: CircularProgressIndicator()),
    );
  }
}
