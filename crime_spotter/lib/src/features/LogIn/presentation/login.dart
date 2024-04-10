import 'dart:async';
import 'package:crime_spotter/main.dart';
import 'package:crime_spotter/src/features/LogIn/presentation/register.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
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
  bool _hidePassword = true;
  bool _register = false;

  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final StreamSubscription<AuthState> _authStateSubscription;

  final _listViewKey = GlobalKey<FormState>();

  Future<void> _signIn() async {
    setState(() {
      _isLoading = true;
    });
    try {
      await supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        // emailRedirectTo:
        //     kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('WIllkommen bei CrimeSpotter!'),
            backgroundColor: Colors.green,
          ),
        );
        _emailController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Überprüfen Sie Ihre Eingaben'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } catch (ex) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: const Text('Ein unerwarteter Fehler ist aufgetreten!'),
          backgroundColor: Theme.of(context).colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _upadateRegister() async {
    setState(() {
      _register = !_register;
    });
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
                    image: AssetImage('assets/LogIn-Card.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                child: Form(
                  key: _listViewKey,
                  child: _register
                      ? const Register()
                      : ListView(
                          padding: const EdgeInsets.symmetric(
                              vertical: 18, horizontal: 12),
                          children: [
                            Center(
                              child: Image.asset(
                                'assets/Login-Detective.png', //////////////////////// Richtiges Bild einsetzen
                                width: 100.0,
                                height: 100.0,
                                fit: BoxFit.contain,
                              ),
                            ),
                            Text(
                              'LogIn',
                              style: TextStyle(
                                fontSize: MediaQuery.of(context).size.width *
                                    0.08, // 8% der Bildschirmbreite
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.yellow,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _emailController,
                              decoration:
                                  const InputDecoration(labelText: "E-Mail"),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte geben Sie eine E-Mail ein';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            TextFormField(
                              controller: _passwordController,
                              obscureText: _hidePassword,
                              decoration: InputDecoration(
                                //helperText: ,
                                labelText: "Passwort",
                                suffixIcon: IconButton(
                                  icon: Icon(_hidePassword
                                      ? Icons.visibility_off
                                      : Icons.visibility),
                                  onPressed: () {
                                    setState(
                                      () {
                                        _hidePassword = !_hidePassword;
                                      },
                                    );
                                  },
                                ),
                              ),
                              validator: (value) {
                                if (value == null || value.isEmpty) {
                                  return 'Bitte geben Sie Ihr Passwort ein';
                                }
                                return null;
                              },
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.black12,
                                backgroundColor:
                                    const Color.fromARGB(172, 248, 197, 79),
                              ),
                              onPressed: () {
                                if (_isLoading) return;

                                if (_listViewKey.currentState!.validate()) {
                                  _signIn();
                                }
                              },
                              child: Text(
                                _isLoading ? 'Lädt' : 'Einloggen',
                                style: const TextStyle(
                                  color: Color.fromARGB(216, 8, 1, 1),
                                ),
                              ),
                            ),
                            const SizedBox(height: 10),
                            ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                shadowColor: Colors.black12,
                                backgroundColor:
                                    const Color.fromARGB(172, 248, 197, 79),
                              ),
                              onPressed: () {
                                if (_isLoading) return;

                                _upadateRegister();
                              },
                              child: Text(
                                _isLoading ? 'Lädt' : 'Registrieren',
                                style: const TextStyle(
                                  color: Color.fromARGB(216, 8, 1, 1),
                                ),
                              ),
                            ),
                          ],
                        ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
