import 'package:flutter/material.dart';

import './screens/SplashScreen.dart';
import './screens/LoginScreen.dart';
import './screens/HomeScreen.dart';
import './screens/CreateTeam.dart';
import './screens/JoinTeam.dart';
import './screens/FirstLogin.dart';

void main() => runApp(new MyApp());

class MyApp extends StatelessWidget {
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return new MaterialApp(
      title: 'Brainants Attendence',
      theme: new ThemeData(
        primarySwatch: Colors.blue,
      ),
      routes: <String, WidgetBuilder>{
        '/splash': (BuildContext context) => SplashScreen(),
        '/login': (BuildContext context) => LoginScreen(),
        '/firstLogin': (BuildContext context) => FirstLogin(),
        '/joinTeam': (BuildContext context) => JoinTeam(),
        '/createTeam': (BuildContext context) => CreateTeam(),
        '/home': (BuildContext context) => HomeScreen(),
      },
      home: SplashScreen(),
    );
  }
}
