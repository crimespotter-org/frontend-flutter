import 'dart:async';
import 'package:crime_spotter/src/features/LogIn/presentation/register.dart';
import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:crime_spotter/src/shared/4data/userdetailsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class LogIn extends StatefulWidget {
  const LogIn({super.key});

  @override
  State<LogIn> createState() => _LogInState();
}

class _LogInState extends State<LogIn> {
  bool _isLoading = false;
  bool _hidePassword = true;
  bool _register = false;

  late final TextEditingController _emailController =
      TextEditingController(text: 'i21034@hb.dhbw-stuttgart.de');
  late final TextEditingController _passwordController =
      TextEditingController(text: 'Test31');

  final _listViewKey = GlobalKey<FormState>();

  Future<void> _signIn(UserDetailsProvider provider) async {
    setState(() {
      _isLoading = true;
    });
    final currentContext = Theme.of(context);
    final sn = ScaffoldMessenger.of(context);
    try {
      var response = await SupaBaseConst.supabase.auth.signInWithPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        // emailRedirectTo:
        //     kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted && SupaBaseConst.supabase.auth.currentSession != null) {
        provider.setJWT(response.session!.accessToken);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Willkommen bei CrimeSpotter!'),
            backgroundColor: Colors.green,
          ),
        );
        provider.setCurrentUser(SupaBaseConst.supabase.auth.currentUser);
        provider.getAllActiveUser();
        _emailController.clear();
        _passwordController.clear();
      }
    } on AuthException catch (ex) {
      sn.showSnackBar(
        SnackBar(
          content: const Text('Überprüfen Sie Ihre Eingaben'),
          backgroundColor: currentContext.colorScheme.error,
        ),
      );
    } catch (ex) {
      sn.showSnackBar(
        SnackBar(
          content: const Text('Ein unerwarteter Fehler ist aufgetreten!'),
          backgroundColor: currentContext.colorScheme.error,
        ),
      );
    } finally {
      if (mounted) {
        setState(
          () {
            _isLoading = false;
          },
        );
      }
    }
  }

  Future<void> _upadateRegister() async {
    setState(() {
      _register = !_register;
    });
  }

  Future<void> _setupAuthListener() async {
    SupaBaseConst.supabase.auth.onAuthStateChange.listen(
      (data) {
        final event = data.event;
        if (event == AuthChangeEvent.signedIn && mounted) {
          Navigator.of(context).pushReplacementNamed(UIData.homeRoute);
        }
      },
    );
  }

  @override
  void initState() {
    _setupAuthListener();
    super.initState();
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDetailsProvider>(context);
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
              clipBehavior: Clip.antiAlias,
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
                                'assets/Login-Detective.png',
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
                                  _signIn(provider);
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
