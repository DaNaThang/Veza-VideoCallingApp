import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import 'EditName.dart';
import 'Selection_Screen.dart';
import 'EditPassword.dart';
import 'First_page.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path/path.dart' as path;
import 'package:modal_progress_hud/modal_progress_hud.dart';

class EditProfile extends StatefulWidget {
  EditProfile({@required this.image});
  final ImageProvider image;

  @override
  _EditProfileState createState() => _EditProfileState();
}

class _EditProfileState extends State<EditProfile> {

  User cur_user;
  final _auth = FirebaseAuth.instance;
  String Disp_name = '';
  String picURL;
  String email = '';
  PickedFile image;
  final ImagePicker _picker = ImagePicker();
  bool spinner = false;
  bool do_delete = false;

  @override
  void initState() {
    super.initState();
    getCurrentUser();

  }

  Future <void> getCurrentUser() async {
    setState(() {
      spinner = true;
    });
    final user = await _auth.currentUser;
    try{
      if (user!= null) {
        cur_user = user;
        Disp_name = cur_user.displayName;
        picURL = cur_user.photoURL;
        email = cur_user.email;
      }
    }
    catch (e) {
      print(e);
    }
    setState(() {
      spinner = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        bottom: PreferredSize(
          child: Container(
            color: Colors.white70,
            height: 0.2,
          ),
          preferredSize: Size.fromHeight(0.2),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Selection_page(image: widget.image),
                  ),
                );
                Navigator.pop(context);
              },
              child: Icon(Icons.arrow_back_ios_new, size: 20.0, color: Colors.white,),
            );
          },
        ),
        title: Text('Edit Profile'),
        centerTitle: true,
        backgroundColor: Color(0xFF161616),
        actions: [
          Padding(
            padding: const EdgeInsets.fromLTRB(0.0, 17.0, 20.0, 0.0),
            child: GestureDetector(
              onTap: () {
                Done();
              },
              child: Text(
                'Done',
                style: TextStyle(fontSize: 18.0, color: Colors.blue, fontWeight: FontWeight.w500),
              ),
            ),
          ),
        ],
      ),
      body: ModalProgressHUD(
        inAsyncCall: spinner,
        child: SingleChildScrollView(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 10.0),
                child: Hero(
                  tag: 'profilepic',
                  child: CircleAvatar(
                    radius: 50.0,
                    backgroundImage: !do_delete
                      ? (image == null
                          ? widget.image
                          : FileImage(File(image.path)))
                      : AssetImage('images/ronaldo.jpg'),
                  ),
                ),
              ),
              GestureDetector(
                onTap: () {
                  showModalBottomSheet(context: context, builder: ((builder) => changepicwidget()));
                },
                child: Text(
                  'Change Profile Photo',
                  style: TextStyle(
                    color: Colors.blue,
                    fontSize: 12.0,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              SizedBox(height: 10.0,),
              Divider(color: Colors.white70, thickness: 0.1,),
              infoWidget(info: email, title: 'Account', ontap: UpdateName,),
              Divider(color: Colors.white70, thickness: 0.1,),
              infoWidget(info: Disp_name, title: 'Display Name', change: true, ontap: UpdateName,),
              Divider(color: Colors.white70, thickness: 0.1,),
              infoWidget(info: '', title: 'Change Password', change: true, ontap: UpdatePassword,),
              Divider(color: Colors.white70, thickness: 0.1,),
              SizedBox(height: 50.0,),
              Divider(color: Colors.white70, thickness: 0.1,),
              GestureDetector(
                onTap: () {
                  SignOut();
                },
                child: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Text(
                    'Sign Out',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 18.0, color: Colors.red,),
                  ),
                ),
              ),
              Divider(color: Colors.white70, thickness: 0.1,),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> UpdateName() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DispName(image: widget.image,),
      ),
    );
  }

  Future<void> UpdatePassword() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => Password(image: widget.image,),
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
    Future.delayed(Duration.zero, () {
      Navigator.of(context).popUntil(ModalRoute.withName('First_page'));
    });
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
                  setState(() {
                    do_delete = false;
                  });
                },
                icon: Icon(Icons.camera, color: Colors.blueAccent),
                label: Text('Camera', style: TextStyle(color: Colors.white),),
              ),
              SizedBox(width: 40.0,),
              TextButton.icon(
                onPressed: () {
                  capture(ImageSource.gallery);
                  setState(() {
                    do_delete = false;
                  });
                },
                icon: Icon(Icons.image, color: Colors.blueAccent,),
                label: Text('Gallery', style: TextStyle(color: Colors.white),),
              ),
              SizedBox(width: 40.0,),
              TextButton.icon(
                onPressed: () {
                  setState(() {
                    do_delete = true;
                  });
                },
                icon: Icon(Icons.delete, color: Colors.redAccent,),
                label: Text('Delete', style: TextStyle(color: Colors.white),),
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
      image = capt_image;
    });
  }

  Future<void> Done() async {
    setState(() {
      spinner = true;
    });

    if (do_delete){
      delete();
    }


    if (image != null) {
      await cur_user.updatePhotoURL(image.path);

      final image_file = File(image.path);
      final destination = 'Profile/${cur_user.email}';
      await Firebase_up.upload_profile(destination, image_file);

    }

    setState(() {
      spinner = false;
    });
    await Navigator.push(
      context,
      MaterialPageRoute(
          builder: (context) => Selection_page(
            image: !do_delete
                ? (image == null
                ? widget.image
                : FileImage(File(image.path)))
                : AssetImage('images/ronaldo.jpg'),
          )
      ),
    );
    Navigator.pop(context);

  }

  Future<void> delete() async {
    image = null;
    picURL = null;
    await cur_user.updatePhotoURL(null);
    final destination = 'Profile/${cur_user.email}';
    try {
      await FirebaseStorage.instance.ref(destination).delete();
    } on FirebaseException catch (e) {
      print(e);
    }
  }
}

class infoWidget extends StatefulWidget {
  infoWidget({@required this.info, @required this.title, this.change = false, @required this.ontap});

  final String info;
  final String title;
  final bool change;
  final Function ontap;

  @override
  _infoWidgetState createState() => _infoWidgetState();
}

class _infoWidgetState extends State<infoWidget> {

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        if (widget.change == true) {
          widget.ontap();
        }
      },
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Container(
            alignment: Alignment.centerLeft,
            padding: const EdgeInsets.fromLTRB(12.0, 8.0, 100.0, 8.0),
            child: Text(
              widget.title,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16.0,
              ),
            ),
          ),
          Row(
            children: [
              Text(
                widget.info,
                style: TextStyle(
                  color: Colors.white70,
                  fontSize: 15.0,
                ),
              ),
              Container(
                padding: const EdgeInsets.fromLTRB(5.0, 0.0, 12.0, 0.0),
                child: widget.change
                    ? Icon(
                        Icons.arrow_forward_ios,
                        color: Colors.white70,
                        size: 14.0,
                      )
                    : null,
              ),
            ],
          ),
        ],
      ),
    );
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