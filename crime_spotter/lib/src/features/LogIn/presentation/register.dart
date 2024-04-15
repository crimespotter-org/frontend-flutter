import 'dart:async';

import 'package:crime_spotter/src/shared/4data/const.dart';
import 'package:crime_spotter/src/shared/4data/supabaseConst.dart';
import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';

class Register extends StatefulWidget {
  const Register({super.key});

  @override
  State<Register> createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool _isLoading = false;
  bool _hidePassword = true;

  late final TextEditingController _emailController = TextEditingController();
  late final TextEditingController _passwordController =
      TextEditingController();
  late final TextEditingController _reapeatedPasswordController =
      TextEditingController();

  Future<void> _register() async {
    setState(() {
      _isLoading = true;
    });
    final sm = ScaffoldMessenger.of(context);
    final theme = Theme.of(context);
    try {
      await SupaBaseConst.supabase.auth.signUp(
        email: _emailController.text.trim(),
        password: _passwordController.text,
        // emailRedirectTo:
        //     kIsWeb ? null : 'io.supabase.flutterquickstart://login-callback/',
      );

      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Bitte bestätigen Sie die Email!'),
          ),
        );
        _emailController.clear();
        _passwordController.clear();
        _reapeatedPasswordController.clear();
      }
    } on AuthException catch (ex) {
      sm.showSnackBar(
        SnackBar(
          content: const Text('Überprüfen Sie Ihre Eingaben'),
          backgroundColor: theme.colorScheme.error,
        ),
      );
    } catch (ex) {
      sm.showSnackBar(
        SnackBar(
          content: const Text('Ein unerwarteter Fehler ist aufgetreten!'),
          backgroundColor: theme.colorScheme.error,
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

  @override
  ListView build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 12),
      children: [
        ListTile(
          contentPadding: const EdgeInsets.symmetric(horizontal: 16.0),
          title: Row(
            children: [
              IconButton(
                iconSize: 20,
                alignment: Alignment.topLeft,
                onPressed: () async {
                  Navigator.pushReplacementNamed(context, UIData.logIn);
                },
                icon: const Icon(Icons.arrow_back),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                  child: Text(
                    'Registrieren',
                    style: TextStyle(
                      fontSize: MediaQuery.of(context).size.width *
                          0.07, // 8% der Bildschirmbreite
                      fontWeight: FontWeight.bold,
                      fontStyle: FontStyle.italic,
                      color: Colors.yellow,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              )
            ],
          ),
        ),
        const SizedBox(height: 10),
        TextFormField(
          controller: _emailController,
          decoration: const InputDecoration(labelText: "E-Mail"),
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
              icon:
                  Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
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
        TextFormField(
          controller: _reapeatedPasswordController,
          obscureText: _hidePassword,
          decoration: InputDecoration(
            //helperText: ,
            labelText: "Passwort",
            suffixIcon: IconButton(
              icon:
                  Icon(_hidePassword ? Icons.visibility_off : Icons.visibility),
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
              return 'Bitte wiederholen Sie Ihr Passwort';
            } else if (_reapeatedPasswordController.value as String != value) {
              return "Ihre eingegebenen Passwörter stimmen nicht überein";
            }
            return null;
          },
        ),
        const SizedBox(height: 10),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            shadowColor: Colors.black12,
            backgroundColor: const Color.fromARGB(172, 248, 197, 79),
          ),
          onPressed: () {
            if (_isLoading) return;
            //if (_listViewKey.currentState!.validate()) {
            _register();
            //}
          },
          child: Text(
            _isLoading ? 'Lädt' : 'Registrieren',
            style: const TextStyle(
              color: Color.fromARGB(216, 8, 1, 1),
            ),
          ),
        ),
      ],
    );
  }
}
