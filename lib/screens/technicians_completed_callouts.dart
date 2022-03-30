import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_projects/Shared/constants.dart';
import 'package:flutter_projects/Shared/loading.dart';
import 'package:flutter_projects/screens/customer_new_dashboard.dart';
import 'package:image_picker/image_picker.dart';
import 'package:syncfusion_flutter_signaturepad/signaturepad.dart';
import 'package:toast/toast.dart';
import 'dart:io';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'admin_dashboard.dart';

class technicians_completed_callouts extends StatefulWidget {
  const technicians_completed_callouts({Key key}) : super(key: key);

  @override
  _technicians_completed_calloutsState createState() => _technicians_completed_calloutsState();
}

class _technicians_completed_calloutsState extends State<technicians_completed_callouts> {

  String userID;
  String name;

  fetchUserInfo() async {
    User getUser = FirebaseAuth.instance.currentUser;
    userID = getUser.uid;
  }

  @override
  void initState() {
    fetchUserInfo();
    //fetchTechnicianName();
    //getTechnicianName();
    super.initState();
    //fetchDatabaseList();
  }


  navigateToCompletedTechniciansCalloutsPage(Map<String, dynamic> details) {
    Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => completed_callouts_page(
              details: details,
            )));
  }

  @override
  Widget build(BuildContext context) {
    final Stream<QuerySnapshot> _usersStream = FirebaseFirestore.instance
        .collection('Updated Callouts')
        .orderBy('Service Date')
        .where('TechnicianUID', isEqualTo: userID)
        //.where('Completed', isEqualTo: true)
        .snapshots();
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
        title:
        Text("Completed Callouts", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Container(
          alignment: Alignment.center,
          padding: EdgeInsets.symmetric(
            vertical: 20.0,
            horizontal: 20.0,
          ),
          child: SizedBox(
            width: 500,
            child: StreamBuilder<QuerySnapshot>(
              stream: _usersStream,
              builder: (BuildContext context,
                  AsyncSnapshot<QuerySnapshot> snapshot) {
                if (snapshot.hasError) {
                  return Text('Something went wrong');
                }

                if (snapshot.connectionState == ConnectionState.waiting) {
                  return CircularProgressIndicator(
                    color: Colors.orange,
                  );
                }

                return ListView(
                  children: snapshot.data.docs.map((DocumentSnapshot document) {
                    Map<String, dynamic> data =
                    document.data() as Map<String, dynamic>;
                    return Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Container(
                        child: ListTile(
                          leading: Text(
                            data['Service Date'],
                            textAlign: TextAlign.left,
                          ),
                          title: Text(
                            data['Customer'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          subtitle: Text(
                            'Reason: ' + data['Callout Reason'],
                          ),
                          trailing: Text(
                            data['Technician'],
                            textAlign: TextAlign.right,
                          ),
                          onTap: () => navigateToCompletedTechniciansCalloutsPage(data),
                        ),
                        decoration: new BoxDecoration(
                          border: new Border(
                            bottom:
                            BorderSide(color: Colors.orange, width: 2.0),
                            top: BorderSide(color: Colors.orange, width: 2.0),
                            right: BorderSide(color: Colors.orange, width: 2.0),
                            left: BorderSide(color: Colors.orange, width: 2.0),
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

class completed_callouts_page extends StatefulWidget {
  final Map<String, dynamic> details;

  completed_callouts_page({this.details});

  @override
  _completed_callouts_pageState createState() => _completed_callouts_pageState();
}

// ignore: camel_case_types
class _completed_callouts_pageState extends State<completed_callouts_page> {

  final GlobalKey<SfSignaturePadState> _signaturePadStateKey = GlobalKey();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool loading = false;

  final List<String> options = ['Complete', 'Incomplete', 'Still busy'];

  TimeOfDay arrivalTime;
  TimeOfDay departureTime;

  File _image1;
  File _image2;

  String arrival_time;
  String notes;
  String location;

  String imgUrl1; // image before
  String actionPerformed = '';
  String imgUrl2; // image after
  String _completed;
  String departure_time;
  bool signature = false;
  String customerComment = '';
  String customerRating;

  double customer_rating = 0;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    arrivalTime = TimeOfDay.now();
    departureTime = TimeOfDay.now();
  }

  Map<String,dynamic> completedCalloutData;
  CollectionReference completedCallout = FirebaseFirestore.instance.collection('Updated Callouts');

  Future customerUpdateCallout() async {

    try{

      completedCalloutData = {
        'Reference Number': widget.details['Reference Number'],
        'Service Date': widget.details['Service Date'],
        'Customer': widget.details['Customer'],
        'Callout Reason': widget.details['Callout Reason'],
        'Technician': widget.details['Technician'],
        'Technician Location': widget.details['Technician Location'],
        'Arrival Time': widget.details['Arrival Time'],
        'Notes': widget.details['Notes'],
        'Image Before': widget.details['Image Before'],
        'Action Performed': widget.details['Action Performed'],
        'Image After': widget.details['Image After'],
        'Status': widget.details['Status'],
        'Departure Time': widget.details['Departure Time'],
        'Signature': widget.details['Signature'],
      };

      return completedCallout.add(completedCalloutData).whenComplete(() => print('Added to Database Successfully'));

    } catch(e){
      print(e.toString());
    }

  }



  @override
  Widget build(BuildContext context) {
    return loading ? Loading() : Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
          //onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (context) => HomeScreen())),
        ),
        title:
        Text("Completed Callouts", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: ListView(
          children: <Widget>[
            Container(
              alignment: Alignment.center,
              padding: EdgeInsets.symmetric(
                vertical: 20.0,
                horizontal: 20.0,
              ),
              child: Form(
                // TODO : implement key
                key: _formKey,
                child: Column(
                  children: <Widget>[
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Reference Number: ' + widget.details['Reference Number'],
                            style: TextStyle(fontWeight: FontWeight.bold),
                            textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Service Date: ' + widget.details['Service Date'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Customer: ' + widget.details['Customer'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Callout Reason: ' + widget.details['Callout Reason'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Technician: ' + widget.details['Technician'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Arrival Time
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Arrival Time : ' + widget.details['Arrival Time'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Notes
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Notes: ' + widget.details['Notes'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Action Performed
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Action(s) Performed: ' + widget.details['Action Performed'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Completed ?
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Status: ' + widget.details['Status'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Departure Time
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Departure Time: ' + widget.details['Departure Time'],
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                    // TODO : Signature
                    SizedBox(
                      width: 500.0,
                      child: Container(
                        child: ListTile(
                          title: Text(
                            'Signed: ' + widget.details['Signature'].toString(),
                            //style: TextStyle(fontWeight: FontWeight.bold),
                            //textAlign: TextAlign.center,
                          ),
                          //subtitle: Text(),
                        ),
                        decoration: BoxDecoration(
                          border: Border.all(color: Colors.orange, width: 2.0),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 20.0,
                    ),

                  ],
                ),
              ),
            )
          ],
        ),
      ),
    );
  }


  _pickArrivalTime() async {
    TimeOfDay a_t = await showTimePicker(
      context: context,
      initialTime: arrivalTime,
    );

    if (arrivalTime != null) {
      setState(() {
        arrivalTime = a_t;
        arrival_time = a_t.format(context);
      });
    }
  }

  _pickDepartureTime() async {
    TimeOfDay d_t = await showTimePicker(
      context: context,
      initialTime: departureTime,
    );

    if (departureTime != null) {
      setState(() {
        departureTime = d_t;
        departure_time = d_t.format(context);
      });
    }
  }

  _imgFromCamera() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image1 = image;
    });
  }

  _imgFromGallery() async {
    var image = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image1 = image;
    });
  }

  _imgFromCamera2() async {
    var image2 = await ImagePicker.pickImage(
        source: ImageSource.camera, imageQuality: 50);

    setState(() {
      _image2 = image2;
    });
  }

  _imgFromGallery2() async {
    var image2 = await ImagePicker.pickImage(
        source: ImageSource.gallery, imageQuality: 50);

    setState(() {
      _image2 = image2;
    });
  }

  // chooseImage() async {
  //   final pickedFile = await ImagePicker.pickImage(source: ImageSource.gallery);
  //   setState(() {
  //     File(pickedFile.path);
  //   });
  //   if(pickedFile.path == null) retrieveLostData();
  // }
  //
  // Future<void> retrieveLostData() async {
  //   final LostDataResponse response = await ImagePicker.retrieveLostData();
  //
  //   if(response.isEmpty){
  //     return;
  //   }
  //   if(response.file != null){
  //     setState(() {
  //       File(response.file.path);
  //     });
  //   }
  //   else{
  //     print(response.file);
  //   }
  // }

  void _showPicker(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }

  void _showPicker2(context) {
    showModalBottomSheet(
        context: context,
        builder: (BuildContext bc) {
          return SafeArea(
            child: Container(
              child: new Wrap(
                children: <Widget>[
                  new ListTile(
                      leading: new Icon(Icons.photo_library),
                      title: new Text('Photo Library'),
                      onTap: () {
                        _imgFromGallery2();
                        Navigator.of(context).pop();
                      }),
                  new ListTile(
                    leading: new Icon(Icons.photo_camera),
                    title: new Text('Camera'),
                    onTap: () {
                      _imgFromCamera2();
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              ),
            ),
          );
        });
  }


}
