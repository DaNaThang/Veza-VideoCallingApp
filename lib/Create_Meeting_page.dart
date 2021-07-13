import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'TextField.dart';
import 'package:random_string/random_string.dart';
import 'package:permission_handler/permission_handler.dart';
import 'CallScreen.dart';
import 'Selection_button.dart';
import 'package:clipboard/clipboard.dart';


class Create_meeting_screen extends StatefulWidget {
  Create_meeting_screen({@required this.image});
  final ImageProvider image;

  @override
  _Create_meeting_screenState createState() => _Create_meeting_screenState();
}

class _Create_meeting_screenState extends State<Create_meeting_screen> {

  String Username = '';
  final disp_control = TextEditingController();
  bool spinner = true;
  var disp_error = false;
  final _auth = FirebaseAuth.instance;
  User cur_user;
  String meeting_id = '';

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    disp_control.text = Username;
  }

  void getCurrentUser()  {
    final user = _auth.currentUser;
    spinner = false;
    meeting_id = randomAlphaNumeric(4).toLowerCase();
    try{
      if (user!= null) {
        cur_user = user;
        String cur_dispname = cur_user.displayName;
        Username = cur_dispname;
      }
    }
    catch (e) {
      print(e);
    }
  }


  @override
  void dispose() {
    disp_control.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ModalProgressHUD(
          inAsyncCall: spinner,
          child: Stack(
            children: [
              Container(
                alignment: Alignment.topLeft,
                padding: const EdgeInsets.fromLTRB(55.0, 42.0, 20.0, 5.0),
                child: GestureDetector(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Icon(Icons.arrow_back_ios_new, size: 20.0, color: Colors.white,),
                ),
              ),
              Column(
                children: [
                  Container(
                    alignment: Alignment.center,
                    padding: const EdgeInsets.fromLTRB(20.0, 40.0, 20.0, 0.0),
                    child: Text(
                      'Start a Meeting',
                      style: TextStyle(
                        fontSize: 22.0,
                        fontWeight: FontWeight.w400,
                        color: Colors.white,
                      ),
                    ),
                  ),
                  Padding(
                    padding: EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 0.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Text(
                          'Meeting ID:  ${Username.toLowerCase()}$meeting_id',
                          style: TextStyle(
                            fontSize: 18.0,
                            color: Colors.white,
                          ),
                        ),
                        GestureDetector(
                          onTap: () {
                            FlutterClipboard.copy('${Username.toLowerCase()}$meeting_id');
                          },
                          child: Container(
                            padding: const EdgeInsets.only(left: 20.0),
                            child: Icon(Icons.copy, color: Colors.white70, size: 20.0,),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.fromLTRB(120.0, 20.0, 120.0, 30.0),
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
                      errortext: 'Display Name is required',
                    ),
                  ),
                  SelectionButton(top: 20.0, onpressed: Call, text: 'Start Meeting', color: Colors.blueAccent, left: 50.0, radius: 10.0,),
                ],
              ),
            ],
          ),
      ),
    );
  }

  Future<void> Call() async{
    setState(() {
      disp_control.text.isEmpty
          ? disp_error = true
          : disp_error = false;
    });
    if (disp_error == false){
      await [Permission.microphone, Permission.camera].request();
      setState(() {
        spinner = true;
      });
      await cur_user.updateDisplayName(disp_control.text);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => Call_screen(
            meeting_id: '${Username.toLowerCase()}$meeting_id',
            sel_type: 0,
            isJoin: false,
            image: widget.image,
          ),
        ),
      );
      Navigator.pop(context);
      setState(() {
        spinner = false;
      });
    }
  }
}
