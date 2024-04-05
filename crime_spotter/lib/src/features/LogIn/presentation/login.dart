import 'dart:async';

import 'package:crime_spotter/main.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _isLoading = false;
  bool _redirect = false;

  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  Future<void> _signIn() async {
    try {
      setState(() {
        _isLoading = true;
      });
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _emailController.text,
        // emailRedirectTo:
        //     kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text('Bestätigen Sie die versendete E-Mail!')),
        );
        _emailController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (ex) {
      SnackBar(
        content: Text(ex.message),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } catch (ex) {
      SnackBar(
        content: const Text('Ein unerwarteter Fehler ist aufgetreten!'),
        backgroundColor: Theme.of(context).colorScheme.error,
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  void initState() {
    _authStateSubscription = supabase.auth.onAuthStateChange.listen((data) {
      if (_redirect) return;

      final session = data.session;

      if (session != null) {
        _redirect = true;
        Navigator.of(context).pushReplacementNamed(UIData.homeRoute);
      }
    });
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _authStateSubscription.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/LogIn.jpg'),
            fit: BoxFit.cover,
          ),
        ),
        child: Center(
          child: SizedBox(
            width: MediaQuery.of(context).size.width * 0.8,
            height: MediaQuery.of(context).size.height * 0.6,
            child: Card(
              elevation: 4.0,
              clipBehavior: Clip.antiAliasWithSaveLayer,
              child: Container(
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage(
                        'assets/LogIn.jpg'), //////////////////////// Richtiges Bild einsetzen
                    fit: BoxFit.cover,
                  ),
                ),
                child: ListView(
                  padding:
                      const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
                  children: [
                    // Center(
                    //   child: Image.asset(
                    //     'assets/LogIn.png', //////////////////////// Richtiges Bild einsetzen
                    //     width: 100.0,
                    //     height: 100.0,
                    //     fit: BoxFit.contain,
                    //   ),
                    // ),
                    const SizedBox(height: 20),
                    Text(
                      'LogIn',
                      style: TextStyle(
                        fontSize: MediaQuery.of(context).size.width *
                            0.08, // 8% der Bildschirmbreite
                        fontWeight: FontWeight.bold,
                        color: Colors.yellow,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "E-Mail"),
                    ),
                    const SizedBox(height: 20),
                    TextFormField(
                      controller: _emailController,
                      decoration: const InputDecoration(labelText: "Passwort"),
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: _isLoading ? null : _signIn,
                      child: Text(_isLoading ? 'Lädt' : 'Einloggen'),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
