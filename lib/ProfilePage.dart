import 'package:flutter/material.dart';
import 'package:firebase_database/firebase_database.dart';

final databaseReference = FirebaseDatabase.instance.reference();

class Test {
  String name, purpose;
  Test({
    this.name = "",
    this.purpose = "",
  });
}

class Profile extends StatefulWidget {
  Profile({Key key, this.title}) : super(key: key);
  final String title;
  ProfilePage createState() => ProfilePage();
}

class ProfilePage extends State<Profile> {
  TextEditingController editingController = TextEditingController();
  List<Test> x = List<Test>();
  List<Test> l = List<Test>();
  int curr = -1;
  bool flag = false;

  @override
  void initState() {
    getData();
    super.initState();
  }

  getData() {
    databaseReference
        .orderByChild('timestamp')
        .once()
        .then((DataSnapshot snapshot) {
      print(snapshot.value);
      setState(() {
        x.clear();
        Map<dynamic, dynamic> values = snapshot.value;
        values.forEach((key, values) {
          if (values != null) {
            x.add(
              Test(
                name: values['name'],
                purpose: values['purpose'],
              ),
            );
            print(values['timestamp']);
            // print(values['name'].toString() + values['purpose'].toString());
          }
        });
        setState(() {
          x = x.reversed.toList();
          l = x;
        });
      });
    });
  }

  void filterSearchResults(String query) {
    print(x);
    List<Test> dummySearchList = List<Test>();
    dummySearchList.addAll(x);
    if (query.isNotEmpty) {
      List<Test> dummyListData = List<Test>();
      dummySearchList.forEach(
        (item) {
          if (item.name.toLowerCase().contains(query.toLowerCase()) ||
              item.purpose.toLowerCase().contains(query.toLowerCase())) {
            dummyListData.add(item);
          }
        },
      );
      setState(() {
        l = dummyListData;
      });
      return;
    } else {
      setState(() {
        l = x;
      });
      return;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Material(
      child: Column(
        children: <Widget>[
          TextField(
            onChanged: (value) {
              filterSearchResults(value);
            },
            controller: editingController,
            decoration: InputDecoration(
                hintText: "Search",
                prefixIcon: Icon(Icons.search),
                border: OutlineInputBorder(
                    borderRadius: BorderRadius.all(Radius.circular(25.0)))),
          ),
          Expanded(
            child: ListView.builder(
              itemCount: l.length,
              itemBuilder: (context, index) {
                Test user = l[index];
                return Padding(
                  padding:
                      EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Flexible(
                        child: Row(
                          children: <Widget>[
                            SizedBox(
                              width: 20.0,
                            ),
                            Expanded(
                              child: Container(
                                padding: EdgeInsets.only(right: 10.0),
                                child: Text(
                                  user.name,
                                  maxLines: 1,
                                  softWrap: false,
                                  style: TextStyle(fontSize: 20.0),
                                  overflow: TextOverflow.fade,
                                ),
                              ),
                            ),
                            Expanded(
                              child: GestureDetector(
                                onTap: () {
                                  setState(() {
                                    if (flag == false) {
                                      curr = index;
                                      flag = true;
                                    } else {
                                      curr = -1;
                                      flag = false;
                                    }
                                  });
                                },
                                child: Container(
                                  padding: EdgeInsets.only(right: 10.0),
                                  child: Text(
                                    user.purpose,
                                    maxLines: curr != index ? 1 : null,
                                    // softWrap: false,
                                    style: TextStyle(fontSize: 20.0),
                                    overflow: TextOverflow.fade,
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
