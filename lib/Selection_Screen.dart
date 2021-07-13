import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'Join_meeting_page.dart';
import 'Create_Meeting_page.dart';
import 'Selection_button.dart';
import 'dart:io';
import 'First_page.dart';
import 'EditProfile.dart';

User cur_user;

class Selection_page extends StatefulWidget {
  Selection_page({@required this.image});
  final ImageProvider image;

  @override
  _Selection_pageState createState() => _Selection_pageState();
}

class _Selection_pageState extends State<Selection_page> {
  final _auth = FirebaseAuth.instance;
  String Username = '';
  String picURL;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser()  {
    final user = _auth.currentUser;
    try{
      if (user!= null) {
        cur_user = user;
        String cur_dispname = cur_user.displayName;
        Username = cur_dispname;
        picURL = cur_user.photoURL;
      }
    }
    catch (e) {
      print(e);
    }
  }


  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: SingleChildScrollView(
          child: Stack(
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Container(
                      padding: const EdgeInsets.fromLTRB(25.0, 50.0, 20.0, 12.0),
                      child: Text(
                        'Welcome $Username!',
                        style: TextStyle(
                          fontSize: 27.0,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Divider(thickness: 0.4, color: Colors.white,),
                    SizedBox(height: 30.0,),
                    Container(
                      alignment: Alignment.center,
                      child: Text(
                        'Start or join a meeting instantly!',
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 24.0,
                          color: Colors.white,
                        ),
                      ),
                    ),
                    Container(
                      alignment: Alignment.center,
                      height: 330.0,
                      child: Image.asset('images/Meeting.png'),
                    ),
                    SelectionButton(top: 25.0, text: 'Start Meeting', onpressed: Create, color: Colors.deepOrangeAccent, left: 60.0, radius: 8.0, bold: true,),
                    SelectionButton(top: 22.0, text: 'Join Meeting', onpressed: Join, color: Colors.blueAccent, left: 60.0, radius: 8.0, bold: true),
                  ],
                ),
                GestureDetector(
                  onTap: () {
                    Navigator.push(context,
                      MaterialPageRoute(
                        builder: (context) => EditProfile(image: widget.image,),
                      ),
                    );
                  },
                  child: Container(
                    alignment: Alignment.topRight,
                    padding: const EdgeInsets.fromLTRB(0.0, 42.0, 20.0, 5.0),
                    child: Hero(
                      tag: 'profilepic',
                      child: CircleAvatar(
                        radius: 22.0,
                        backgroundImage: widget.image,
                      ),
                    ),
                  ),
                ),
              ]
          ),
        )
    );
  }

  Future<void> Create() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Create_meeting_screen(image: widget.image,),
      ),
    );
  }

  Future<void> Join() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Join_meeting(image: widget.image,),
      ),
    );
  }

  Future<void> SignOut() async {
    await _auth.signOut();
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => FirstPage(),
      ),
    );
    Navigator.pop(context);
  }
}