import 'package:crime_spotter/src/shared/4data/userdetailsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Settings extends StatefulWidget {
  const Settings({super.key});

  @override
  State<Settings> createState() => _SettingsState();
}

class _SettingsState extends State<Settings> {
  // @override
  // void initState() {
  //   super.initState();
  //   WidgetsBinding.instance.addPostFrameCallback(
  //     (_) async => await tempProvider.userIsAuthenticated(context).then(
  //           (loggedIn) async => loggedIn
  //               ? null
  //               : await Navigator.popAndPushNamed(context, UIData.logIn),
  //         ),
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<UserDetailsProvider>(context);
    return Scaffold(
        appBar: AppBar(
          title: const Text(
            "Rollen verwalten",
            textAlign: TextAlign.center,
          ),
        ),
        body: SafeArea(
          child: ListView.builder(
            itemCount: provider.activeUsers.length,
            itemBuilder: (context, index) {
              return Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    backgroundImage: AssetImage("assets/placeholder.jpg"),
                  ),
                  title: Text(provider.activeUsers[index].name),
                  subtitle: DropdownButton<String>(
                    value: provider
                        .displayUserRole(provider.activeUsers[index].role),
                    onChanged: (newValue) {
                      setState(
                        () {
                          provider.updateUserRole(
                            user: provider.activeUsers[index],
                            role: provider
                                .convertStringToUserRole(newValue ?? ""),
                          );
                        },
                      );
                    },
                    items: <String>[
                      provider.displayUserRole(UserRole.admin),
                      provider.displayUserRole(UserRole.crimefluencer),
                      provider.displayUserRole(UserRole.crimespotter)
                    ].map<DropdownMenuItem<String>>(
                      (String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      },
                    ).toList(),
                  ),
                ),
              );
            },
          ),
        ));
  }
}
