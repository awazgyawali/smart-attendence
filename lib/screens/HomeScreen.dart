import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:connectivity/connectivity.dart';

import '../components/HomeBody.dart';
import '../components/Drawer.dart';

class HomeScreen extends StatefulWidget {
  HomeScreenState createState() => HomeScreenState();
}

class HomeScreenState extends State<HomeScreen> {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();
  FirebaseUser user;
  SharedPreferences _pref;

  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      this.user = user;
    });
    SharedPreferences.getInstance().then((pref) {
      this._pref = pref;
    });
  }

  attendToday() {
    DateTime now = new DateTime.now();
    if (!_pref
        .getStringList("companyOpenDays")
        .contains(now.weekday.toString())) {
      _scaffoldKey.currentState.showSnackBar(
        SnackBar(
          content: Text("Your company is closed today."),
        ),
      );
    } else {
      var _ref = FirebaseDatabase.instance
          .reference()
          .child(_pref.getString("companyKey"))
          .child("attendence_data")
          .child("${now.year}-${now.month}-${now.day}");

      _ref.child("date").set("${now.year}-${now.month}-${now.day}");

      _ref
          .child("attendence")
          .child(user.uid)
          .set({"uid": user.uid, "present": true, "message": ""});
    }
  }

  openDrawer() {
    _scaffoldKey.currentState.openDrawer();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.grey,
      key: _scaffoldKey,
      drawer: CustomDrawer(),
      bottomNavigationBar: BottomAppBar(
        hasNotch: true,
        child: Row(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            IconButton(
              onPressed: () => openDrawer(),
              color: Colors.blue,
              icon: Icon(Icons.menu),
            ),
            Text("Smart Attendence System",
                style: TextStyle(color: Colors.blue, fontSize: 18.0)),
          ],
        ),
      ),
      body: SafeArea(
        child: HomeBody(),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.endDocked,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.blue,
        foregroundColor: Colors.white,
        child: Icon(Icons.add),
        onPressed: () => attendToday(),
      ),
    );
  }
}
