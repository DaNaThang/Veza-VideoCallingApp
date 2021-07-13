import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Selection_button.dart';
import 'TextField.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'Selection_Screen.dart';
import 'package:firebase_storage/firebase_storage.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {

  final _auth = FirebaseAuth.instance;

  final password_control = TextEditingController();
  final email_control = TextEditingController();
  final dispname_control = TextEditingController();
  var password_error = false;
  var email_error = false;
  var dispname_error = false;
  var pass_errotext = 'Password is required';
  var email_errortext = 'Email is required';
  bool spinner = false;
  PickedFile _image;
  final ImagePicker _picker = ImagePicker();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      //resizeToAvoidBottomInset: false,
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 50.0, 20.0, 5.0),
                child: Container(
                  child: Text(
                    'Create Account',
                    style: TextStyle(
                      fontSize: 32.0,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.only(top: 35.0),
                alignment: Alignment.center,
                child: Hero(
                  tag: 'profilepic',
                  child: CircleAvatar(
                    radius: 65.0,
                    backgroundImage: _image == null
                        ? AssetImage('images/ronaldo.jpg') as ImageProvider
                        : FileImage(File(_image.path)),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(top: 10.0),
                child: GestureDetector(
                  onTap: () {
                    showModalBottomSheet(context: context, builder: ((builder) => changepicwidget()));
                  },
                  child: Container(
                    alignment: Alignment.center,
                    child: Text(
                      'Change Profile',
                      style: TextStyle(
                        fontSize: 12.0,
                        color: Colors.blueAccent,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 25.0, 20.0, 10.0),
                child: Textfield(
                  controller: dispname_control,
                  labeltext: 'Display Name',
                  error: dispname_error,
                  selhtext: false,
                  hinttext: '',
                  selicon: true,
                  icon: Icons.person,
                  obscuretext: false,
                  align_centre: false,
                  errortext: 'Display Name is required',
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20.0, 10.0, 20.0, 10.0),
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
              SelectionButton(top: 35.0, onpressed: Selection, text: 'Sign Up', color: Colors.blueAccent),
            ],
          ),
        ),
      ),
    );
  }

  Widget changepicwidget() {
    return Container(
      height: 120.0,
      width: MediaQuery.of(context).size.width,
      color: Colors.black87,
      child: Column(
        children: [
          SizedBox(height: 17.0,),
          Text(
            'Change Profile Picture',
            style: TextStyle(
              color: Colors.white,
              fontSize: 18.0,
            ),
          ),
          SizedBox(height: 17.0),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              TextButton.icon(
                onPressed: () {
                  capture(ImageSource.camera);
                },
                icon: Icon(Icons.camera, color: Colors.blueAccent),
                label: Text('Camera', style: TextStyle(color: Colors.white),),
              ),
              SizedBox(width: 80.0,),
              TextButton.icon(
                onPressed: () {
                  capture(ImageSource.gallery);
                },
                icon: Icon(Icons.image, color: Colors.blueAccent,),
                label: Text('Gallery', style: TextStyle(color: Colors.white),),
              ),
            ],
          ),
        ],
      ),
    );
  }

  void capture(ImageSource imageSource) async {
    final capt_image = await _picker.getImage(source: imageSource);
    setState(() {
      _image = capt_image;
    });
  }

  Future<void> Selection() async {
    setState(() {
      password_control.text.isEmpty
          ? password_error = true
          : password_error = false;
      email_control.text.isEmpty
          ? email_error = true
          : email_error = false;
      dispname_control.text.isEmpty
          ? dispname_error = true
          : dispname_error = false;
    });
    if (password_error == false && email_error == false && dispname_error == false){
      setState(() {
        spinner = true;
      });
      try {
        final newaccount = await _auth.createUserWithEmailAndPassword(email: email_control.text, password: password_control.text);
        await newaccount.user.updateDisplayName(dispname_control.text);
        if (_image!=null){
          await newaccount.user.updatePhotoURL(_image.path);

          final image_file = File(_image.path);
          final destination = 'Profile/${email_control.text}';
          await Firebase_up.upload_profile(destination, image_file);
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Selection_page(image: FileImage(image_file),)
            ),
          );
          Navigator.pop(context);
        }
        else {
          await Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => Selection_page(image: AssetImage('images/ronaldo.jpg'),)
            ),
          );
          Navigator.pop(context);
        }
        setState(() {
          spinner = false;
        });
      }on FirebaseAuthException catch (e) {
        if (e.code == 'weak-password') {
          setState(() {
            pass_errotext = 'The password should be at least 6 characters long';
            password_error = true;
            spinner = false;
          });
        } else if (e.code == 'email-already-in-use') {
          setState(() {
            email_errortext = 'The account already exists for that email.';
            email_error = true;
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

class Firebase_up {
  static UploadTask upload_profile(String destination, File file) {
    try {
      final ref = FirebaseStorage.instance.ref(destination);
      return ref.putFile(file);
    } on FirebaseException catch (e) {
      print(e);
      return null;
    }
  }
}