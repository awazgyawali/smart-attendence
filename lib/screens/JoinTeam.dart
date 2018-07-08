import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';

class JoinTeam extends StatefulWidget {
  JoinTeamState createState() => JoinTeamState();
}

class JoinTeamState extends State<JoinTeam> {
  FirebaseDatabase _database = FirebaseDatabase.instance;
  FirebaseUser _user;
  SharedPreferences _pref;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  String teamCode;

  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      this._pref = pref;
    });
    FirebaseAuth.instance.currentUser().then((user) {
      this._user = user;
    });
  }

  teamCodeValidator(String value) {
    if (value.length == 0) {
      return "Please enter the team code.";
    } else if (value.length < 3) {
      return "Team code too short";
    }
  }

  submit() async {
    final FormState form = _formKey.currentState;
    if (form.validate()) {
      form.save();
      DataSnapshot snapshot = await _database
          .reference()
          .child(teamCode)
          .child("company_detail")
          .once();
      if (snapshot.value["name"] == null) {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text("Invalid Team Code"),
                content: Text(
                    "The code $teamCode is not associated with any team. Make sure you entered the correct code."),
                actions: <Widget>[
                  FlatButton(
                    child: Text("OK"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  )
                ],
              );
            });
      } else {
        showDialog(
            context: context,
            builder: (context) {
              return AlertDialog(
                title: Text(snapshot.value["name"]),
                content: Text(
                    "Are you sure you want to join ${snapshot.value["name"]}?"),
                actions: <Widget>[
                  FlatButton(
                    child: Text("No"),
                    onPressed: () {
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                  FlatButton(
                    child: Text("Yes"),
                    onPressed: () {
                      fillData(teamCode, snapshot.value);
                      Navigator.of(context, rootNavigator: true).pop('dialog');
                    },
                  ),
                ],
              );
            });
      }
    }
  }

  fillData(String companyKey, dynamic companyDetail) async {
    await _database
        .reference()
        .child(companyKey)
        .child("members")
        .child(_user.uid)
        .set({
      "name": _user.displayName,
      "photoUrl": _user.photoUrl,
      "uid": _user.uid,
      "email": _user.email
    });

    await _database
        .reference()
        .child("users")
        .child(_user.uid)
        .child("joinnedCompanies")
        .set(companyKey);

    await _pref.setString("companyKey", companyKey);
    await _pref.setString("companyName", companyDetail["name"]);
    await _pref.setString("companyEmail", companyDetail["email"]);
    await _pref.setString("companyAdmin", companyDetail["admin"]);    
    List<String> openDays = List();
    for (var value in companyDetail["openDays"]) {
      openDays.add(value.toString());
    }
    await _pref.setStringList("companyOpenDays", openDays);
    await _pref.setBool("loggedIn", true);
    Navigator.of(context).pushReplacementNamed("/home");
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Join a Team"),
      ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Form(
            key: _formKey,
            child: Column(
              children: <Widget>[
                TextFormField(
                  keyboardType: TextInputType.text,
                  onSaved: (value) {
                    teamCode = value;
                  },
                  decoration: const InputDecoration(
                    border: const UnderlineInputBorder(),
                    filled: true,
                    hintText: '',
                    labelText: 'Team Code',
                  ),
                  validator: (value) => teamCodeValidator(value),
                ),
                SizedBox(
                  height: 20.0,
                ),
                RaisedButton(
                  child: Text("Sumbit"),
                  onPressed: () => submit(),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
