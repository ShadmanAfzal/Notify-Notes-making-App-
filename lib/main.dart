import 'package:connectivity/connectivity.dart';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:material_design_icons_flutter/material_design_icons_flutter.dart';
import 'dart:convert' show json;
import 'package:http/http.dart' as http;

void main() {
  runApp(MaterialApp(
    home: Homepage(),
    debugShowCheckedModeBanner: false,
    title: "Notify",
    theme: ThemeData(brightness: Brightness.dark),
  ));
}

class Homepage extends StatefulWidget {
  Homepage({Key key}) : super(key: key);
  @override
  _HomepageState createState() => _HomepageState();
}

class _HomepageState extends State<Homepage> with TickerProviderStateMixin {
  List<dynamic> list = [];
  final GlobalKey<ScaffoldState> scaffoldkey = GlobalKey<ScaffoldState>();
  var refreshKey = GlobalKey<RefreshIndicatorState>();
  List onlyanimate = [];
  bool istap = false;
  AnimationController bodyContainerController;
  Animation<double> bodyAnimation;
  final titleController = TextEditingController();
  final bodyController = TextEditingController();

  Future<String> notesout() async {
    var respone = await http.get(
        Uri.encodeFull("http://justinkhan.pythonanywhere.com/api/note_in"),
        headers: {"Accept": "application/json"});
    setState(() {
      var convertojson = json.decode(respone.body);
      list = convertojson;
    });
    onlyanimate = [for (int i = 0; i < list.length; i++) false];
    return "Success";
  }

  Future<String> delete(String id) async {
    Map data2 = {'id': id};
    var response = await http.post(
        'http://justinkhan.pythonanywhere.com/api/note_delete',
        body: data2);
    if (response.statusCode != 200) {
      showsnackbar("Unable to Delete", 3);
    }
    return "Success";
  }

  Future<String> notes() async {
    Map data1 = {'title': titleController.text, 'body': bodyController.text};
    var response = await http
        .post('http://justinkhan.pythonanywhere.com/api/note_in', body: data1);
    if (response.statusCode != 200) {
      showsnackbar("Title and Notes can't be null", 3);
    }
    return "Success";
  }

  checkinternetaccees() async {
    Connectivity()
        .onConnectivityChanged
        .listen((ConnectivityResult result) async {
      var connectivityResult = await (Connectivity().checkConnectivity());
      if (connectivityResult == ConnectivityResult.none) {
        showsnackbar("Your Device is offline", 3);
      }
      if (connectivityResult == ConnectivityResult.mobile) {
        showsnackbar("Connected", 3);
      }
      if (connectivityResult == ConnectivityResult.wifi) {
        showsnackbar("Connected", 3);
      }
    });
  }

  void showsnackbar(reason, int time) {
    final snackbar = SnackBar(
      backgroundColor: Colors.black54,
      content: Text(
        reason,
        style: TextStyle(
            color: Colors.white, fontFamily: "Rosemary", fontSize: 15),
      ),
      duration: Duration(seconds: time),
    );
    scaffoldkey.currentState.showSnackBar(snackbar);
  }

  animationonly(int index) {
    for (int i = 0; i < onlyanimate.length; i++) {
      if (onlyanimate[index] == true) {
        return bodyAnimation.value;
      } else {
        return 40.0;
      }
    }
  }

  @override
  void initState() {
    super.initState();
    checkinternetaccees();
    Future.delayed(Duration(milliseconds: 200)).then((_) {
      refreshKey.currentState?.show();
    });
    this.notesout();
    bodyContainerController =
        AnimationController(vsync: this, duration: Duration(milliseconds: 100));
    bodyAnimation = Tween<double>(begin: 40, end: 450).animate(CurvedAnimation(
        parent: bodyContainerController, curve: Curves.bounceInOut));
  }

  @override
  void dispose() {
    bodyContainerController.dispose();
    titleController.dispose();
    bodyContainerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      key: scaffoldkey,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.white,
        child: Icon(MdiIcons.plus, color: Colors.black),
        onPressed: () {
          showDialog(
              context: context,
              builder: (BuildContext context) {
                return Dialog(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(15),
                    ),
                    insetAnimationDuration: Duration(milliseconds: 300),
                    insetAnimationCurve: Curves.easeIn,
                    child: Container(
                      child: Container(
                        height: MediaQuery.of(context).size.height / 2,
                        width: 500,
                        margin: EdgeInsets.only(left: 10, right: 10, top: 10),
                        child: Column(
                          children: <Widget>[
                            Container(
                              alignment: Alignment(1, 1),
                              child: IconButton(
                                icon: Icon(
                                  MdiIcons.close,
                                  size: 30,
                                ),
                                onPressed: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            ),
                            TextField(
                              maxLines: 1,
                              controller: titleController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                prefixIcon: Icon(
                                  MdiIcons.desktopMac,
                                  color: Colors.white,
                                ),
                                hintText: "Title",
                              ),
                            ),
                            TextField(
                              maxLines: 8,
                              controller: bodyController,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                hintText: "Notes",
                              ),
                            ),
                            InkWell(
                              onTap: () {
                                setState(() async {
                                  await notes();
                                  await notesout();
                                  bodyController.clear();
                                  titleController.clear();
                                  Navigator.of(context).pop();
                                });
                              },
                              child: Text(
                                "Create",
                                style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontFamily: "DancingScript"),
                              ),
                            )
                          ],
                        ),
                      ),
                    ));
              });
        },
      ),
      appBar: AppBar(
        centerTitle: true,
        title: Text("Notify",
            style: TextStyle(color: Colors.white, fontFamily: "DancingScript")),
        leading: Icon(
          MdiIcons.tools,
          color: Colors.white,
        ),
        // backgroundColor: Colors.black87,
      ),
      body: RefreshIndicator(
        key: refreshKey,
        color: Colors.white,
        //backgroundColor: Colors.black,
        onRefresh: notesout,
        child: ListView.builder(
          itemBuilder: (BuildContext context, int index) {
            if (list == null) {
              return Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Text(
                    "Click to Add Notes",
                    style: TextStyle(
                        fontFamily: "DancingScript",
                        fontSize: 30,
                        color: Colors.white),
                  )
                ],
              );
            } else {
              return Padding(
                padding: const EdgeInsets.only(top: 5),
                child: GestureDetector(
                  onTap: () {
                    setState(() {
                      if (istap) {
                        bodyContainerController.reverse();
                        onlyanimate[index] = false;
                      } else {
                        bodyContainerController.forward();
                        onlyanimate[index] = true;
                      }
                      istap = !istap;
                      onlyanimate[index] = !onlyanimate[index];
                      animationonly(index);
                      for (int i = 0; i < onlyanimate.length; i++) {
                        if (index != i) {
                          onlyanimate[i] = false;
                        }
                      }
                    });
                  },
                  child: Stack(
                    children: <Widget>[
                      Card(
                        child: Container(
                          height: animationonly(index),
                          width: MediaQuery.of(context).size.width,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: <Widget>[
                              Padding(
                                padding: const EdgeInsets.only(left: 10),
                                child: Text(
                                  list[index]['title'],
                                  style: TextStyle(
                                      fontSize: 23,
                                      color: Colors.white,
                                      fontFamily: "DancingScript"),
                                ),
                              ),
                              Padding(
                                padding: const EdgeInsets.all(8),
                                child: SingleChildScrollView(
                                  child: Column(
                                    children: <Widget>[
                                      Container(
                                        child: SelectableText(
                                          list[index]['body'],
                                          style: TextStyle(
                                              fontSize: 20,
                                              fontFamily: "Rosemary"
                                              // color: Colors.black,
                                              ),
                                          showCursor: false,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      Container(
                        alignment: Alignment(1, 1),
                        child: IconButton(
                          onPressed: () async {
                            await delete("${list[index]['id']}");
                            await notesout();
                          },
                          iconSize: 25,
                          icon: Icon(
                            Icons.cancel,
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
            }
          },
          itemCount: list == null ? 1 : list.length,
        ),
      ),
      //backgroundColor: Colors.black,
    );
  }
}
