import 'package:crime_spotter/src/features/LogIn/presentation/register.dart';
import 'package:crime_spotter/src/features/explore/1presentation/edit_case.dart';
import 'package:crime_spotter/src/features/explore/1presentation/explore.dart';
import 'package:crime_spotter/src/features/explore/1presentation/single_case.dart';
import 'package:crime_spotter/src/features/admin/admin.dart';
import 'package:crime_spotter/src/shared/4data/cardProvider.dart';
import 'package:crime_spotter/src/shared/4data/mapProvider.dart';
import 'package:crime_spotter/src/shared/4data/userdetailsProvider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:supabase_flutter/supabase_flutter.dart';

import 'src/features/LogIn/presentation/login.dart';
import 'src/features/map/views/map.dart';
import 'src/shared/4data/const.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Supabase.initialize(
    url: 'https://nmijjbrgxttaatvjvegj.supabase.co',
    anonKey:
        'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Im5taWpqYnJneHR0YWF0dmp2ZWdqIiwicm9sZSI6ImFub24iLCJpYXQiOjE3MTEwMjU4NjIsImV4cCI6MjAyNjYwMTg2Mn0.uSz4jgMEZ8P0ngtKEGbm5gjU9hgWBH3ALBdrUufBRYc',
    // authFlowType: AuthFlowType.pkce,
  );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => CaseProvider()),
        ChangeNotifierProvider(create: (_) => MapProvider()),
        ChangeNotifierProvider(create: (_) => UserDetailsProvider()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'Crime Spotter',
        theme: ThemeData(
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.grey),
          useMaterial3: true,
        ),
        home: const MapPage(title: 'Crime Spotter'),
        initialRoute: UIData.logIn,
        routes: <String, WidgetBuilder>{
          UIData.homeRoute: (BuildContext context) =>
              const MapPage(title: 'Crime Spotter'),
          UIData.logIn: (BuildContext context) => const LogIn(),
          UIData.register: (BuildContext context) => const Register(),
          UIData.explore: (BuildContext context) => const Explore(),
          UIData.settings: (BuildContext context) => const Settings(),
          UIData.single_case: (BuildContext context) => const SingleCase(),
          UIData.edit_case: (BuildContext context) => const EditCase(),
        },
      ),
    );
  }
}
