import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Selection_Screen.dart';
import 'Selection_button.dart';
import 'TextField.dart';
import 'package:firebase_storage/firebase_storage.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {

  final _auth = FirebaseAuth.instance;

  final password_control = TextEditingController();
  final email_control = TextEditingController();
  var password_error = false;
  var email_error = false;
  var pass_errotext = 'Password is required';
  var email_errortext = 'Email is required';
  bool spinner = false;
  String URL;
  ImageProvider profile_image;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget> [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 5.0),
                child: Container(
                  child: Text(
                    'Log in',
                    style: TextStyle(
                      fontSize: 34.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 35.0, 20.0, 10.0),
                child: Textfield(
                  controller: email_control,
                  labeltext: 'Email',
                  error: email_error,
                  selhtext: false,
                  hinttext: '',
                  selicon: true,
                  icon: Icons.email,
                  obscuretext: false,
                  align_centre: false,
                  errortext: email_errortext,
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
                child: Textfield(
                  controller: password_control,
                  labeltext: 'Password',
                  error: password_error,
                  selhtext: false,
                  hinttext: '',
                  selicon: true,
                  icon: Icons.password,
                  obscuretext: true,
                  align_centre: false,
                  errortext: pass_errotext,
                ),
              ),
              SelectionButton(top: 35.0, onpressed: Selection, text: 'Log in', color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> Selection() async {
    setState(() {
      password_control.text.isEmpty
          ? password_error = true
          : password_error = false;
      email_control.text.isEmpty
          ? email_error = true
          : email_error = false;
    });
    if (password_error == false && email_error == false){
      setState(() {
        spinner = true;
      });
      try {
        final user = await _auth.signInWithEmailAndPassword(email: email_control.text, password: password_control.text);
        if (user != null) {
          final _auth = await FirebaseAuth.instance;
          final cur_user = _auth.currentUser;
          try{
            if (cur_user!= null) {
              final ref = FirebaseStorage.instance.ref('Profile/${cur_user.email}');
              URL = await ref.getDownloadURL();
            }
          }
          catch (e) {
            print(e);
          }
          print(URL);
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => Selection_page(
                image: URL == null
                    ? AssetImage('images/ronaldo.jpg') as ImageProvider
                    : NetworkImage(URL),
              ),
            ),
          );
          Navigator.pop(context);
        }
        setState(() {
          spinner = false;
        });
      }on FirebaseAuthException catch (e) {
        if (e.code == 'user-not-found') {
          setState(() {
            email_errortext = "User doesn't exist" ;
            email_error = true;
            spinner = false;
          });
        } else if (e.code == 'wrong-password') {
          setState(() {
            pass_errotext = 'Wrong password';
            password_error = true;
            spinner = false;
          });
        }
      }
      catch(e) {
        print(e);
      }
    }
  }
}