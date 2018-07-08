import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:async';

class LoginScreen extends StatefulWidget {
  LoginScreenState createState() => LoginScreenState();
}

class LoginScreenState extends State<LoginScreen> {
  FirebaseAuth _auth = FirebaseAuth.instance;
  FirebaseDatabase _database = FirebaseDatabase.instance;
  GoogleSignIn _googleSignIn = GoogleSignIn();

  getUserFrom(FirebaseUser user) {
    _database
        .reference()
        .child("users")
        .child(user.uid)
        .child("joinnedCompanies")
        .once()
        .then((data) {
      if (data.value != null) {
        _database
            .reference()
            .child("users")
            .child(user.uid)
            .child("instanceId")
            .set(""); //todo instance id halna cha
        setupForExistingCompany(data.value);
      } else {
        uploadUserData(user).then((sd) {
          Navigator.of(context).pushReplacementNamed("/firstLogin");
        });
      }
    });
  }

  Future<void> uploadUserData(FirebaseUser user) async {
    await _database.reference().child("users").child(user.uid).set({
      "name": user.displayName,
      "photoUrl": user.photoUrl,
      "uid": user.uid,
      "email": user.email,
      "instanceId": "DDsdsdsddsds", //todo instance id halne
    });
  }

  setupForExistingCompany(String companyKey) async {
    DataSnapshot snapshot = await _database
        .reference()
        .child(companyKey)
        .child("company_detail")
        .once();

    SharedPreferences pref = await SharedPreferences.getInstance();

    await pref.setString("companyKey", companyKey);
    await pref.setString("companyName", snapshot.value["name"]);
    await pref.setString("companyEmail", snapshot.value["email"]);
    await pref.setString("companyAdmin", snapshot.value["admin"]);
    List<String> openDays = List();
    for (var value in snapshot.value["openDays"]) {
      openDays.add(value.toString());
    }
    await pref.setStringList("companyOpenDays", openDays);
    await pref.setBool("loggedIn", true);

    Navigator.of(context).pushReplacementNamed("/home");
  }

  void initState() {
    super.initState();
    _auth.onAuthStateChanged.listen((user) {
      if (user != null) {
        getUserFrom(user);
      }
    });
  }

  Future<FirebaseUser> _startGoogleSignIn() async {
    try {
      GoogleSignInAccount googleUser = await _googleSignIn.signIn();
      GoogleSignInAuthentication googleAuth = await googleUser.authentication;
      FirebaseUser user = await _auth.signInWithGoogle(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );
      return user;
    } catch (e) {
      throw (e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Smart Attendence System"),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            Text(
                "This screen will contain all the options to login, google, facebook, phone, email"),
            RaisedButton(
              child: Text("Login With Google"),
              onPressed: () => _startGoogleSignIn(),
            )
          ],
        ),
      ),
    );
  }
}
