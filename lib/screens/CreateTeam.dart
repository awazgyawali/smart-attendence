import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class CreateTeam extends StatefulWidget {
  CreateTeamState createState() => CreateTeamState();
}

class Team {
  String companyKey;
  String name;
  String email;
  List openDays;
  String adminUid;
}

class CreateTeamState extends State<CreateTeam> {
  FirebaseDatabase _database = FirebaseDatabase.instance;
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  FirebaseUser user;
  SharedPreferences pref;

  void initState() {
    super.initState();
    FirebaseAuth.instance.currentUser().then((user) {
      this.user = user;
    });
    SharedPreferences.getInstance().then((pref) {
      this.pref = pref;
    });
  }

  void showInSnackBar(String value) {
    _scaffoldKey.currentState.showSnackBar(SnackBar(content: Text(value)));
  }

  bool _formWasEdited = false;
  bool _autovalidate = false;
  Team team = Team();
  List<String> selectedDays = ["1", "2","3", "4", "5"];

  joinTeam(Team team) async {
    DatabaseReference ref = _database.reference().push();
    team.companyKey = ref.key;
    team.adminUid = user.uid;
    team.openDays = selectedDays;
    await ref.child("company_detail").set({
      "name": team.name,
      "email": team.email,
      "openDays": selectedDays,
      "admin": user.uid
    });
    await _database
        .reference()
        .child(team.companyKey)
        .child("members")
        .child(user.uid)
        .set({
      "name": user.displayName,
      "photoUrl": user.photoUrl,
      "uid": user.uid,
      "email": user.email
    });

    await _database
        .reference()
        .child("users")
        .child(user.uid)
        .child("joinnedCompanies")
        .set(team.companyKey);

    await pref.setString("companyKey", team.companyKey);
    await pref.setString("companyName", team.name);
    await pref.setString("companyEmail", team.email);
    await pref.setString("companyAdmin", team.adminUid);
    await pref.setStringList("companyOpenDays", team.openDays);
    await pref.setBool("loggedIn", true);
  }

  startACompany() {
    joinTeam(team).then((value) {
      Navigator.of(context).pushReplacementNamed("/home");
    });
  }

  void _handleSubmitted() {
    final FormState form = _formKey.currentState;
    if (!form.validate()) {
      _autovalidate = true; // Start validating on every change.
      showInSnackBar('Please fix the errors in red before submitting.');
    } else {
      form.save();
      startACompany();
    }
  }

  daySelected(int day, bool value) {
    setState(() {
      if (value)
        selectedDays.add(day.toString());
      else
        selectedDays.remove(day.toString());
    });
  }

  isSelected(int day) {
    return selectedDays.contains(day.toString());
  }

  String _validateName(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'Name is required.';
    final RegExp nameExp = new RegExp(r'^[A-Za-z ]+$');
    if (!nameExp.hasMatch(value))
      return 'Please enter only alphabetical characters.';
    return null;
  }

  String _validateEmail(String value) {
    _formWasEdited = true;
    if (value.isEmpty) return 'Email is required.';
    final RegExp nameExp = new RegExp(
        r'[a-zA-Z0-9.!#$%&’*+/=?^_`{|}~-]+@[a-zA-Z0-9-]+(?:\.[a-zA-Z0-9-]+)*$');
    if (!nameExp.hasMatch(value)) return 'Invalid email entered.';
    return null;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text("Create a Company"),
      ),
      body: Form(
        key: _formKey,
        autovalidate: _autovalidate,
        child: Padding(
          padding: EdgeInsets.all(20.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              TextFormField(
                decoration: const InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  hintText: '',
                  labelText: 'Company Name *',
                ),
                onSaved: (String value) {
                  team.name = value;
                },
                validator: _validateName,
              ),
              SizedBox(height: 20.0),
              TextFormField(
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  border: const UnderlineInputBorder(),
                  filled: true,
                  hintText: '',
                  labelText: 'Company Email *',
                ),
                onSaved: (String value) {
                  team.email = value;
                },
                validator: _validateEmail,
              ),
              SizedBox(height: 20.0),
              Text("Opening Days"),
              SizedBox(height: 10.0),
              Wrap(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Monday"),
                      selected: isSelected(1),
                      onSelected: (value) => daySelected(1, value),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Tuesday"),
                      selected: isSelected(2),
                      onSelected: (value) => daySelected(2, value),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Wedneusday"),
                      selected: isSelected(3),
                      onSelected: (value) => daySelected(3, value),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Thursday"),
                      selected: isSelected(4),
                      onSelected: (value) => daySelected(4, value),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Friday"),
                      selected: isSelected(5),
                      onSelected: (value) => daySelected(5, value),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Saturday"),
                      selected: isSelected(6),
                      onSelected: (value) => daySelected(6, value),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.all(4.0),
                    child: FilterChip(
                      label: Text("Sunday"),
                      selected: isSelected(7),
                      onSelected: (value) => daySelected(7, value),
                    ),
                  ),
                ],
              ),
              SizedBox(height: 20.0),
              Center(
                child: new RaisedButton(
                  color: Colors.blue,
                  textColor: Colors.white,
                  child: const Text('Create'),
                  onPressed: _handleSubmitted,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
