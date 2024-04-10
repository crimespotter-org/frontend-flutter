import 'package:flutter/material.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SafeArea(
        child: Column(
          children: [
            GestureDetector(
              onTap: () => {},
              child: Card(
                //margin: EdgeInsets.only(left: 40),
                elevation: 4.0,
                clipBehavior: Clip.antiAlias,
                child: Stack(
                  children: [
                    Ink.image(
                      height: 100,
                      image: const AssetImage('assets/LogIn-Card.png'),
                      fit: BoxFit.cover,
                    ),
                    const Positioned(
                      // top: 12,
                      // bottom: 12,
                      // left: 12,
                      // right: 12,
                      child: Align(
                        alignment: Alignment.centerLeft,
                        child: CircleAvatar(
                          radius: 40,
                          backgroundImage: AssetImage('assets/LogIn-Card.png'),
                        ),
                      ),
                    ),
                    const Positioned(
                      top: 12,
                      bottom: 12,
                      left: 120,
                      right: 12,
                      child: Center(
                        child: Text(
                          'Benutzername',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 24.0,
                            fontWeight: FontWeight.bold,
                            shadows: <Shadow>[
                              Shadow(
                                color: Colors.black,
                                blurRadius: 10.0,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
