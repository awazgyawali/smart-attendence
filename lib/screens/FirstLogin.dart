import 'package:flutter/material.dart';

class FirstLogin extends StatefulWidget {
  FirstLoginState createState() => FirstLoginState();
}

class FirstLoginState extends State<FirstLogin> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Welcome"),
      ),
      body: SafeArea(
        child: Center(
          child: Column(
            children: <Widget>[
              RaisedButton(
                child: Text("Join an existing Team"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/joinTeam");},
              ),
              RaisedButton(
                child: Text("Start a new Team"),
                onPressed: () {
                  Navigator.of(context).pushNamed("/createTeam");
                },
              ),
            ],
          ),
        ),
      ),
    );
  }
}
