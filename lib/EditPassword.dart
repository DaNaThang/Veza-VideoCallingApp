import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'EditProfile.dart';

class Password extends StatefulWidget {
  Password({@required this.image});
  final ImageProvider image;

  @override
  _NameState createState() => _NameState();
}

class _NameState extends State<Password> {

  User cur_user;
  final _auth = FirebaseAuth.instance;
  final newpass_control = TextEditingController();
  final curpass_control = TextEditingController();
  bool new_error = false;
  bool cur_error = false;

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
                padding: const EdgeInsets.symmetric(horizontal: 75.0),
                child: Text(
                  'Change Password',
                  style: TextStyle(fontSize: 20.0, color: Colors.white, fontWeight: FontWeight.w700),
                ),
              ),
              GestureDetector(
                onTap: () {
                  PasswordUpdated();
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
                  'Current Password',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Flexible(
                child: TextField(
                  obscureText: true,
                  controller: curpass_control,
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
                    hintText: 'Enter Current Password',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                    errorText:
                    cur_error ? 'Current Password is required' : null,
                  ),
                ),
              ),
            ],
          ),
          Divider(color: Colors.white70, thickness: 0.1,),
          Row(
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(15.0, 8.0, 34.0, 8.0),
                child: Text(
                  'New Password',
                  style: TextStyle(
                    fontSize: 15.0,
                    color: Colors.white,
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ),
              Flexible(
                child: TextField(
                  obscureText: true,
                  controller: newpass_control,
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
                    hintText: 'Enter New Password',
                    hintStyle: TextStyle(
                      color: Colors.white70,
                      fontWeight: FontWeight.w400,
                    ),
                    errorText:
                    new_error ? 'New Password is required' : null,
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

  Future<void> PasswordUpdated() async {
    setState(() {
      newpass_control.text.isEmpty
          ? new_error = true
          : new_error = false;
      curpass_control.text.isEmpty
          ? cur_error = true
          : cur_error = false;
    });
    if (new_error == false && cur_error == false){
      UserCredential credential = await cur_user.reauthenticateWithCredential(
        EmailAuthProvider.credential(
          email: cur_user.email,
          password: curpass_control.text,
        ),
      );
      credential.user;
      await cur_user.updatePassword(newpass_control.text);
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
