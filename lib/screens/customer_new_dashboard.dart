import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/screens/customer_callouts_view.dart';
import 'package:flutter_projects/screens/view_callouts.dart';
import 'package:flutter_projects/services/auth2.dart';
import 'package:flutter_projects/screens/login.dart';
import 'package:toast/toast.dart';

class customer_new_dashboard extends StatelessWidget {

  final AuthService _auth = AuthService();

  Future<bool> showWarning(BuildContext context) async => showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Do you want to exit the app ?"),
        actions: [
          ElevatedButton(
            child: Text("No"),
            onPressed: () => Navigator.pop(context, false),
          ),
          ElevatedButton(
            child: Text("Yes"),
            onPressed: () async {
              await _auth.signOut();
              Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
              //Navigator.pop(context, true);
            },
          ),
        ],
      )
  );

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        final shouldPop = await showWarning(context);
        dynamic result = await _auth.signOut();
        return shouldPop ?? false;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('YSF IT Solutions', style: TextStyle(fontWeight: FontWeight
              .bold)),
          centerTitle: true,
          backgroundColor: Colors.orange,
        ),
        backgroundColor: Colors.orangeAccent[100],

        drawer: new Drawer(
          child: ListView(
            children: <Widget>[
              UserAccountsDrawerHeader(
                accountName: new Text("User",
                    style: new TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 17.0)
                ),
                //accountEmail: new Text(""),
              ),
              // ListTile(
              //   leading: Icon(Icons.person),
              //   title: Text("Profile"),
              // ),
              // ListTile(
              //   leading: Icon(Icons.settings),
              //   title: Text("Settings"),
              // ),
              // ListTile(
              //   leading: Icon(Icons.work_outline_sharp),
              //   title: Text("Previous Callouts"),
              // ),
              ListTile(
                leading: Icon(Icons.logout),
                title: Text("Logout"),
                onTap: () async {
                  dynamic result = await _auth.signOut();
                  Navigator.push(context,
                      MaterialPageRoute(builder: (context) => LoginPage()));
                  Toast.show("Logged out Successfully", context,
                      duration: Toast.LENGTH_LONG, gravity: Toast.BOTTOM);
                },
              ),
            ],
          ),
        ),
        body: Container(
          padding: EdgeInsets.all(30.0),
          child: GridView.count(
              crossAxisCount: 2,
              children: <Widget>[
                Card(
                    margin: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () {
                        Navigator.push(context, MaterialPageRoute(
                            builder: (context) => customer_callouts_view()));
                      },
                      splashColor: Colors.orange,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.work, size: 70.0,),
                            Text("View Callouts",
                              style: new TextStyle(fontSize: 17.0),)
                          ],
                        ),
                      ),
                    )
                ),

                Card(
                    margin: EdgeInsets.all(8.0),
                    child: InkWell(
                      onTap: () async {
                        dynamic result = await _auth.signOut();
                        Navigator.push(context, MaterialPageRoute(builder: (context) => LoginPage()));
                        Toast.show("Logged out Successfully", context, duration: Toast.LENGTH_LONG, gravity:  Toast.BOTTOM);
                      },
                      splashColor: Colors.orange,
                      child: Center(
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: <Widget>[
                            Icon(Icons.logout, size: 70.0,),
                            Text("Logout",style: new TextStyle(fontSize: 17.0),)
                          ],
                        ),
                      ),
                    )
                ),
              ]
          ),
        ),
      ),
    );
  }

  Future <void> _signOut() async {
    await FirebaseAuth.instance.signOut();
    User user = await FirebaseAuth.instance.currentUser;
  }
}
