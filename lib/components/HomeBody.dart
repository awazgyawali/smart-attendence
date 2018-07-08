import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:async';
import 'package:shared_preferences/shared_preferences.dart';

import './FirstOpen.dart';

List months = [
  "",
  "Jan",
  "Feb",
  "Mar",
  "Apr",
  "May",
  "Jun",
  "Jul",
  "Aug",
  "Sep",
  "Oct",
  "Nov",
  "Dec"
];

class Attendence {
  Attendence(this.date, {this.present, this.message});
  String date;
  Map<String, bool> present = Map();
  Map<String, String> message = Map();

  bool selected = false;
}

class AttendenceDataSource extends DataTableSource {
  List<Attendence> _attendences;
  List names;

  int _selectedCount = 0;

  @override
  DataRow getRow(int index) {
    assert(index >= 0);
    if (index >= _attendences.length) return null;
    final Attendence attendence = _attendences[index];
    return new DataRow.byIndex(index: index, cells: getDataCell(attendence));
  }

  getDataCell(Attendence attendence) {
    List dateList = attendence.date.split("-");
    DateTime dateTime = DateTime(
        int.parse(dateList[0]), int.parse(dateList[1]), int.parse(dateList[2]));
    var cells = <DataCell>[
      DataCell(Center(
          child: Text(
              '${months[dateTime.month]} ${dateTime.day}, ${dateTime.year}')))
    ];
    names.forEach((data) {
      bool present = attendence.present[data['key']];
      if (attendence.present[data['key']] != null) if (present)
        cells.add(DataCell(Center(
            child: Icon(
          Icons.check,
          color: Colors.green,
        ))));
      else
        cells.add(DataCell(Center(
            child: Icon(
          Icons.info_outline,
          color: Colors.orange,
        ))));
      else
        cells.add(DataCell(Center(
            child: Icon(
          Icons.close,
          color: Colors.red,
        ))));
    });
    return cells;
  }

  @override
  int get rowCount => _attendences.length;

  @override
  bool get isRowCountApproximate => false;

  @override
  int get selectedRowCount => _selectedCount;
}

class HomeBody extends StatefulWidget {
  HomeBodyState createState() => HomeBodyState();
}

class HomeBodyState extends State<HomeBody> {
  int _rowsPerPage = PaginatedDataTable.defaultRowsPerPage;
  FirebaseDatabase _database = FirebaseDatabase.instance;
  bool _sortAscending = true;
  final AttendenceDataSource _attendencesDataSource = AttendenceDataSource();
  SharedPreferences _pref;
  String companyKey = "";

  void initState() {
    super.initState();
    SharedPreferences.getInstance().then((pref) {
      this._pref = pref;
      setState(() {
        companyKey = pref.getString("companyKey");
      });
    });
  }

  getHeaders() {
    var columns = <DataColumn>[
      DataColumn(
        label: Text(
          "Date",
          textAlign: TextAlign.right,
          style: TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
    ];

    _attendencesDataSource.names.forEach((data) {
      columns.add(DataColumn(label: Text(data["name"])));
    });

    return columns;
  }

  Future<void> pullHeader() async {
    _attendencesDataSource.names = List();
    DataSnapshot userSnapshot = await _database
        .reference()
        .child(_pref.getString("companyKey"))
        .child("members")
        .once();
    for (var value in userSnapshot.value.values) {
      _attendencesDataSource.names
          .add({"key": value["uid"], "name": value["name"]});
    }
    return userSnapshot;
  }

  getDataFromFirebase(attendenceSnapahot) {
    _attendencesDataSource._attendences = <Attendence>[];
    pullHeader();
    for (var value in attendenceSnapahot.value.values) {
      Attendence attendence = Attendence(value["date"]);
      attendence.message = Map();
      attendence.present = Map();
      for (var attValue in value["attendees"].values) {
        attendence.message[attValue["uid"]] = attValue["message"];
        attendence.present[attValue["uid"]] = attValue["present"];
      }
      _attendencesDataSource._attendences.add(attendence);
    }

    return ListView(
      children: <Widget>[
        PaginatedDataTable(
          header: Text(_pref.getString("companyName")),
          rowsPerPage: _rowsPerPage,
          sortAscending: _sortAscending,
          onRowsPerPageChanged: (int value) {
            setState(() {
              _rowsPerPage = value;
            });
          },
          columns: getHeaders(),
          source: _attendencesDataSource,
        )
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return FutureBuilder(
        future: pullHeader(),
        builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
          if (asyncSnapshot.hasData) {
            if (asyncSnapshot.data != null) {
              return StreamBuilder(
                stream: _database
                    .reference()
                    .child(companyKey)
                    .child("attendence_data")
                    .onValue,
                builder: (BuildContext context, AsyncSnapshot asyncSnapshot) {
                  if (asyncSnapshot.hasData) {
                    if (asyncSnapshot.data != null) {
                      return getDataFromFirebase(asyncSnapshot.data.snapshot);
                    } else {
                      return Center(
                        child: CircularProgressIndicator(),
                      );
                    }
                  } else {
                    return FirstOpenPrompt();
                  }
                },
              );
            }
          }
          return Center(
                        child: CircularProgressIndicator(),
                      );
        });
  }
}
