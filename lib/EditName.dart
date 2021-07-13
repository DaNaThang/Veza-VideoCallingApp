import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EditProfile.dart';


class DispName extends StatefulWidget {
  DispName({@required this.image});
  final ImageProvider image;

  @override
  _NameState createState() => _NameState();
}

class _NameState extends State<DispName> {

  User cur_user;
  final _auth = FirebaseAuth.instance;
  String Disp_name = '';
  final disp_control = TextEditingController();
  bool error = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
    disp_control.text = Disp_name;
  }

  void getCurrentUser()  {
    final user = _auth.currentUser;
    try{
      if (user!= null) {
        cur_user = user;
        Disp_name = cur_user.displayName;
      }
    }
    catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          SizedBox(height: 30.0,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.pop(context);
                },
                child: Icon(Icons.arrow_back_ios_new, size: 20.0, color: Colors.white,),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 80.0),
                child: Text(
                  'Edit Display Name',
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () {
                  NameUpdated();
                },
                child: Text(
                  'Done',
                  style: TextStyle(fontSize: 18.0, color: Colors.blue, fontWeight: FontWeight.w500),
                ),
              ),
            ],
          ),
          SizedBox(height: 25.0,),
          Divider(color: Colors.white70, thickness: 0.1,),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 8.0, 15.0, 8.0),
                child: Text(
                  'Display Name',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Flexible(
                child: TextField(
                  controller: disp_control,
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 15.0,
                    fontWeight: FontWeight.w500,
                  ),
                  decoration: InputDecoration(
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none,
                    enabledBorder: InputBorder.none,
                    errorBorder: InputBorder.none,
                    disabledBorder: InputBorder.none,
                    hintText: 'Enter Display Name',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                    errorText:
                    error ? 'Display name is required' : null,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white70, thickness: 0.1,),
        ],
      ),
    );
  }

  Future<void> NameUpdated() async {
    setState(() {
      disp_control.text.isEmpty
          ? error = true
          : error = false;
    });
    if (error == false){
      await cur_user.updateDisplayName(disp_control.text);
      await Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => EditProfile(image: widget.image),
        ),
      );
      Navigator.pop(context);
    }
  }
}
