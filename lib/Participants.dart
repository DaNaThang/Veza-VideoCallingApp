import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:math';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class Participants extends StatefulWidget {
  Participants({@required this.meeting_id, this.sel_type = 0});

  final String meeting_id;
  final int sel_type;

  @override
  _ParticipantsState createState() => _ParticipantsState();
}

class _ParticipantsState extends State<Participants> {

  final message_controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String message;
  List<Widget> Nav_screens = [Container(), Container(), Container()];
  int Index;

  void ChangeScreen(int index) {
    setState(() {
      Index = index;
    });
  }


  @override
  void initState() {
    super.initState();
    getCurrentUser();
    Index = widget.sel_type;
    Nav_screens = [
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ParticipantStream(chan_name: widget.meeting_id, seltype: 0,),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ParticipantStream(chan_name: widget.meeting_id, seltype: 1,),
        ],
      ),
      Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          ParticipantStream(chan_name: widget.meeting_id, seltype: 2,),
        ],
      ),
    ];
  }

  Future <void> getCurrentUser() async {
    final user = await _auth.currentUser;
    try{
      if (user!= null) {
        loggedInUser = user;
      }
    }
    catch (e) {
      print(e);
    }
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              color: Colors.blueAccent,
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () { Navigator.pop(context); },
            );
          },
        ),
        title: Text('Participants'),
        backgroundColor: Color(0xFF161616),
      ),
      body: SafeArea(
        child: Nav_screens.elementAt(Index),
      ),
      bottomNavigationBar: BottomNavigationBar(
        items: [
          BottomNavigationBarItem(icon: Icon(Icons.person), label: 'Presenters'),
          BottomNavigationBarItem(icon: Icon(Icons.view_agenda), label: 'Viewers'),
          BottomNavigationBarItem(icon: Icon(Icons.chat), label: 'Chat'),
        ],
        currentIndex: Index,
        selectedItemColor: Colors.blueAccent,
        onTap: ChangeScreen,
        backgroundColor: Color(0xFF161616),
        unselectedItemColor: Colors.white70,
      ),
    );
  }
}

class AttendeeWidget extends StatelessWidget {

  AttendeeWidget({this.Name, this.type,@required this.isMe});

  final Name;
  final type;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 4.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Container(
                decoration: BoxDecoration(
                  color: rand_color(),
                  shape: BoxShape.circle,
                ),
                height: 44.0,
                width: 44.0,
                child: Center(
                  child: Text(
                    Name[0].toString().toUpperCase(),
                    style: TextStyle(
                      fontSize: 21.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 12.0,),
              Text(
                isMe? Name + ' (You)' : Name,
                style: TextStyle(
                  fontSize: 20.0,
                  color: Colors.white,
                ),
              ),
            ],
          ),
          SizedBox(
            height: 8.0,
          ),
          Divider(thickness: 0.4, color: Colors.white,),
        ],
      ),
    );
  }

  Color rand_color(){
    var rnd = Random();
    var r = rnd.nextInt(10) * 16;
    var g = rnd.nextInt(10) * 16;
    var b = rnd.nextInt(10) * 16;
    Color color = Color.fromARGB(255, r, g, b);
    return color;
  }
}

class ParticipantStream extends StatelessWidget {
  ParticipantStream({@required this.chan_name, @required this.seltype});

  final int seltype;
  final String chan_name;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(chan_name).orderBy('part_disp', descending: true).snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.white70
              ),
            );
          }
          final participants = snapshot.data.docs.reversed;
          List<AttendeeWidget> ParticipantWidgets = [];
          for (var participant in participants) {
            Map<String, dynamic> data = participant.data() as Map<String, dynamic>;
            final part_type = data['part_type'];
            var part_disp = data['part_disp'].toString();
            var part_email = data['part_email'].toString();

            var currentUser = loggedInUser.email;


            final ParticipantWidget = AttendeeWidget(
              Name: part_disp,
              type: part_type,
              isMe: currentUser == part_email,
            );
            if (part_type == seltype){
              ParticipantWidgets.add(ParticipantWidget);
            }
          }
          return Expanded(
            child: ListView(
                  padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
                  children: ParticipantWidgets,
                ),
          );
        }
    );
  }
}