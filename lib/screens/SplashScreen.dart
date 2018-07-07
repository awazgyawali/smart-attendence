import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    startTimeout();
  }

  startTimeout() {
    return new Timer(Duration(seconds: 3), handleTimeout);
  }

  void handleTimeout() {
    SharedPreferences.getInstance().then((pref) {
      if (pref.getBool("loggedIn") != null && pref.getBool("loggedIn")) {
        Navigator.of(context).pushReplacementNamed("/home");
      } else {
        Navigator.of(context).pushReplacementNamed("/login");
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Container(
          margin: EdgeInsets.all(50.0),
          child: Center(
            child: Text(
              "Smart Attendence System",
              textAlign: TextAlign.center,
              style: TextStyle(
                color: Colors.indigo,
                fontSize: 20.0,
                fontWeight: FontWeight.bold
              ),
            ),
          ),
        ),
      ),
    );
  }
}
