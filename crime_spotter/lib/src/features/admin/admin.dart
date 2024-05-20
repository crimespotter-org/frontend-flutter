import 'package:crime_spotter/src/shared/4data/userdetails_provider.dart';
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
        flexibleSpace: FlexibleSpaceBar(
          background: Image.asset(
            "assets/Backgroung.png",
            fit: BoxFit.cover,
          ),
        ),
        iconTheme: const IconThemeData(color: Colors.white),
        title: const Text(
          "Rollen verwalten",
          style: TextStyle(color: Colors.white),
          textAlign: TextAlign.center,
        ),
      ),
      body: SafeArea(
        child: ListView.builder(
          itemCount: provider.activeUsers.length,
          itemBuilder: (context, index) {
            return Container(
              decoration: const BoxDecoration(
                image: DecorationImage(
                  image: AssetImage("assets/Backgroung.png"),
                  fit: BoxFit.cover,
                ),
              ),
              child: Padding(
                padding: const EdgeInsets.all(5),
                child: Card(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      image: const DecorationImage(
                        image: AssetImage("assets/LogIn-Card.png"),
                        fit: BoxFit.cover,
                      ),
                    ),
                    child: ListTile(
                      leading: CircleAvatar(
                        backgroundImage: provider.profilePictures.any(
                                (element) =>
                                    element.userId ==
                                    provider.activeUsers[index].id)
                            ? Image.memory(provider.profilePictures
                                    .where((element) =>
                                        element.userId ==
                                        provider.activeUsers[index].id)
                                    .first
                                    .imageInBytes)
                                .image
                            : const AssetImage(
                                "assets/placeholder.jpg",
                              ),
                      ),
                      title: Text(
                        provider.activeUsers[index].name,
                        style: const TextStyle(color: Colors.white),
                      ),
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
                              child: Text(
                                value,
                              ),
                            );
                          },
                        ).toList(),
                      ),
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
