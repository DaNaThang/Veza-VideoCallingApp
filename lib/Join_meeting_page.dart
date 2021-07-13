import 'package:flutter/material.dart';
import 'package:flutter/cupertino.dart';
import 'package:permission_handler/permission_handler.dart';
import 'CallScreen.dart';
import 'Selection_button.dart';
import 'TextField.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Chat_screen.dart';

int sel_type = 0;
User cur_user;

class Join_meeting extends StatefulWidget {

  Join_meeting({@required this.image});
  final ImageProvider image;

  @override
  _Join_meetingState createState() => _Join_meetingState();

}

class _Join_meetingState extends State<Join_meeting> {

  final _controller = TextEditingController();
  final disp_control = TextEditingController();
  var chan_error = false;
  var disp_error = false;
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  String Disp_name = '';
  bool spinner = true;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    disp_control.text = Disp_name;
  }

  void getCurrentUser()  {
    final user = _auth.currentUser;
    spinner = false;
    try{
      if (user!= null) {
        cur_user = user;
        String cur_dispname = cur_user.displayName;
        Disp_name = cur_dispname;
      }
    }
    catch (e) {
      print(e);
    }
  }


  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override

  Widget build(BuildContext) {
    return Scaffold(
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SingleChildScrollView(
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.fromLTRB(30.0, 42.0, 20.0, 5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new, size: 20.0, color: Colors.white,),
                ),
              ),
              Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 5.0),
                    child: Text(
                      'Join a Meeting',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(30.0, 20.0, 30.0, 10.0),
                    child: Textfield(
                      controller: _controller,
                      labeltext: 'Meeting ID',
                      error: chan_error,
                      selhtext: true,
                      hinttext: 'Enter Meeting ID',
                      selicon: false,
                      icon: Icons.password,
                      obscuretext: false,
                      align_centre: true,
                      errortext: 'Meeting ID is required',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(120.0, 5.0, 120.0, 30.0),
                    child: Textfield(
                      controller: disp_control,
                      labeltext: '',
                      error: disp_error,
                      selhtext: true,
                      hinttext: 'Display Name',
                      selicon: false,
                      icon: Icons.edit,
                      obscuretext: false,
                      align_centre: true,
                      errortext: 'Display NAme is required',
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(70.0, 10.0, 70.0, 0.0),
                    child: Text(
                      'Join:',
                      style: TextStyle(
                          fontSize: 17.0,
                          fontWeight: FontWeight.w400,
                          color: Colors.white
                      ),
                    ),
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(70.0, 10.0, 70.0, 0.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            sel_type = 0;
                          });
                        },
                        child: SelectionBox(
                          seltype: 0,
                          text: 'As Presenter',
                        ),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(70.0, 20.0,70.0, 0.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            sel_type = 1;
                          });
                        },
                        child: SelectionBox(
                          seltype: 1,
                          text: 'As Spectator',
                        ),
                      )
                  ),
                  Padding(
                      padding: const EdgeInsets.fromLTRB(70.0, 20.0, 70.0, 0.0),
                      child: GestureDetector(
                        onTap: (){
                          setState(() {
                            sel_type = 2;
                          });
                        },
                        child: SelectionBox(
                          seltype: 2,
                          text: 'Chat',
                        ),
                      )
                  ),
                  SelectionButton(top: 50.0, onpressed: Call, text: 'Join Meeting', color: Colors.blueAccent, left: 50.0, radius: 10.0, bold: true,),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> Call() async{
    setState(() {
      _controller.text.isEmpty
          ? chan_error = true
          : chan_error = false;
      disp_control.text.isEmpty
          ? disp_error = true
          : disp_error = false;
    });
    if (chan_error == false && disp_error == false && sel_type!=2){
      await [Permission.microphone, Permission.camera].request();
      setState(() {
        spinner = true;
      });
      await cur_user.updateDisplayName(disp_control.text);
      await Navigator.push(
        context,
        MaterialPageRoute(
            builder: (context) => Call_screen(
              meeting_id: _controller.text,
              sel_type: sel_type,
              isJoin: true,
              image: widget.image,
            ),
        ),
      );
      Navigator.pop(context);
      setState(() {
        spinner = false;
      });
    }
    else if (chan_error == false && disp_error == false && sel_type==2){
      setState(() {
        spinner = true;
      });
      await cur_user.updateDisplayName(disp_control.text);
      String Collection= 'MeetID_${_controller.text}';
      await _firestore.collection(Collection).doc(cur_user.email).set({
        'part_disp': disp_control.text,
        'part_email': cur_user.email,
        'part_type': 2,
      });
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => ChatScreen(
            meeting_id: _controller.text,
            sel_type: 2,
            image: widget.image,
          ),
        ),
      );
      setState(() {
        spinner = false;
      });
    }
  }
}


class SelectionBox extends StatefulWidget {
  SelectionBox({@required this.seltype, @required this.text});

  final String text;
  final seltype;


  @override
  _SelectionBoxState createState() => _SelectionBoxState(seltype: seltype,text: text);
}

class _SelectionBoxState extends State<SelectionBox> {
  _SelectionBoxState({@required this.seltype, @required this.text});

  final String text;
  var seltype;

  @override
  Widget build(BuildContext context) {
    return Container(
        alignment: Alignment.center,
        height: sel_type == seltype
            ? 42.0
            : 35.0,
        decoration: BoxDecoration(
          color: sel_type == seltype
              ? Colors.blueAccent
              : null,
          border: Border.all(
            width: sel_type == seltype
                ? 3.0
                : 1.0,
            color: sel_type == seltype
                ? Colors.blueAccent
                : Colors.white54
          ),
          borderRadius: BorderRadius.circular(10.0),
        ),
        child: Text(
          text,
          style: TextStyle(
            fontSize: sel_type == seltype
                ? 17.0
                : 14.0,
            color: Colors.white,
            fontWeight: FontWeight.w500,
          ),
        ),
      );
  }
}