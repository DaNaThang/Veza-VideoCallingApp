import 'dart:async';
import 'package:flutter/material.dart';
import 'package:agora_rtc_engine/rtc_engine.dart';
import 'package:agora_rtc_engine/rtc_local_view.dart' as RtcLocalView;
import 'package:agora_rtc_engine/rtc_remote_view.dart' as RtcRemoteView;
import 'package:modal_progress_hud/modal_progress_hud.dart';
import 'Chat_screen.dart';
import 'Selection_Screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:random_string/random_string.dart';
import 'dart:math';

const APP_ID = 'a1d6ded5873b4800a1c59a338de92086';

class Call_screen extends StatefulWidget {

  final String meeting_id;
  final int sel_type;
  final bool isJoin;
  final ImageProvider image;
  final bool fromChat;

  const Call_screen({@required this.image, @required this.meeting_id ,@required this.sel_type,@required this.isJoin, this.fromChat = false});

  @override
  _Call_screenState createState() => _Call_screenState();
}

class _Call_screenState extends State<Call_screen> with SingleTickerProviderStateMixin{

  var engine;
  var role;
  final _uid = <int>[];
  final _disp_names = <String>[];
  final _showvid = <bool>[];
  bool mic = false;
  bool camera = false;
  var istapped = true;
  var isjoin;
  VideoEncoderConfiguration config = VideoEncoderConfiguration();
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  User cur_user;
  String randomizer = '';

  @override
  void dispose() {
    engine.leaveChannel();
    engine.destroy();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    randomizer = randomAlphaNumeric(4);
    isjoin = widget.isJoin;
    initVideo();
    setRole();
    setCurrentUser();
  }

  Future <void> setCurrentUser() async {
    final user = await _auth.currentUser;
    try{
      if (user!= null) {
        cur_user = user;
        String Collection= 'MeetID_${widget.meeting_id}';
        await _firestore.collection(Collection).doc(user.email).set({
          'part_disp': user.displayName,
          'part_email': user.email,
          'part_type': widget.sel_type,
        });
      }

    }
    catch (e) {
      print(e);
    }
  }

  void setRole(){
    if (widget.sel_type == 0){
      role = ClientRole.Broadcaster;
    }
    else if (widget.sel_type == 1){
      role = ClientRole.Audience;
    }
  }

  Future<void> initVideo() async {


    engine = await RtcEngine.create(APP_ID);
    await engine.enableVideo();
    await engine.setChannelProfile(ChannelProfile.LiveBroadcasting);
    await engine.setClientRole(role);

    engine.setEventHandler(
        RtcEngineEventHandler(
          joinChannelSuccess: (channel, uid, elapsed) {
            setState(() {
              _uid.add(uid);
              _disp_names.add(cur_user.displayName);
              _showvid.add(true);
              print('goooo ${_disp_names}');
            });
          },
          leaveChannel: (stats) {
            setState(() {
              _uid.clear();
              _disp_names.clear();
              _showvid.clear();
            });
          },
          userInfoUpdated: (uid, userinfo) {
            setState(() {
              istapped = true;
              _uid.add(userinfo.uid);
              final name = userinfo.userAccount.substring(4);
              _disp_names.add(name);
              _showvid.add(true);
              print('DOOOOO ${_disp_names}');
            });
          },
          remoteVideoStateChanged: (uid, state, reason, elapsed) {
            setState(() {
              final index = _uid.indexOf(uid);
              if (state == VideoRemoteState.Stopped){
                _showvid[index] = false;
              }
              else{
                _showvid[index] = true;
              }
            });
          },
          userOffline: (uid, elapsed) {
            setState(() {
              istapped = true;
              final index = _uid.indexOf(uid);
              _disp_names.remove(_disp_names[index]);
              _uid.remove(uid);
              _showvid.remove(_showvid[index]);
              print('FOOOOOO ${_disp_names}');
            });
          },
        ));
    engine.leaveChannel();
    set_resolution(1920, 1080);
    // await engine.joinChannel(APP_ID, widget.meeting_id, null, 0);
    await engine.joinChannelWithUserAccount(APP_ID, widget.meeting_id,randomizer+cur_user.displayName);

  }

  Future<void> set_resolution(int width, int height) async {
    config.dimensions = VideoDimensions(width, height);
    await engine.setVideoEncoderConfiguration(config);
  }

  Widget NameConatiner(int index, double bottom) {
    if (istapped) {
      return Container(
        alignment: Alignment.bottomLeft,
        padding: EdgeInsets.fromLTRB(10.0, 0.0, 0.0, bottom),
        child: Container(
          height: 22.0,
          width: 100.0,
          decoration: BoxDecoration(
            color: Color(0xFF292B2D).withOpacity(0.6),
            borderRadius: BorderRadius.circular(8.0),
          ),
          child: Text(
            _disp_names[index],
            textAlign: TextAlign.center,
            style: TextStyle(
              color: Colors.white70,
              fontSize: 15.0,
            ),
          ),
        ),
      );
    }
    else {
      return Container();
    }
  }

  Color rand_color(){
    var rnd = Random();
    var r = rnd.nextInt(10) * 16;
    var g = rnd.nextInt(10) * 16;
    var b = rnd.nextInt(10) * 16;
    Color color = Color.fromARGB(255, r, g, b);
    return color;
  }

  Widget CamOffWidget(int index) {
    return Center(
      child: Container(
        decoration: BoxDecoration(
          color: rand_color(),
          shape: BoxShape.circle,
        ),
        height: 100.0,
        width: 100.0,
        child: Center(
          child: Text(
            _disp_names[index][0].toString().toUpperCase(),
            style: TextStyle(
              fontSize: 60.0,
              color: Colors.white,
            ),
          ),
        ),
      ),
    );
  }
  
  Widget Call_widget() {
    if (role == ClientRole.Broadcaster && isjoin == false){
      var _uidfinal = <int>[];
      _uidfinal = _uid.toSet().toList();
      switch (_uidfinal.length) {
        case 1:
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    istapped = !istapped;
                  });
                },
                child: _showvid[0]
                    ? RtcLocalView.SurfaceView()
                    : CamOffWidget(0),
              ),
              NameConatiner(0, 80.0),
            ],
          );
        case 2:
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[1]
                        ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                        : CamOffWidget(1),
                      NameConatiner(1, 10.0),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[0]
                        ? RtcLocalView.SurfaceView()
                        : CamOffWidget(0),
                      NameConatiner(0, 80.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        case 3:
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[0]
                                ? RtcLocalView.SurfaceView()
                                : CamOffWidget(0),
                            NameConatiner(0, 10.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[1]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                                : CamOffWidget(1),
                            NameConatiner(1, 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[2]
                          ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                          : CamOffWidget(2),
                      NameConatiner(2, 80.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        case 4 :
        case 5 :
        case 6 :
        case 7 :
        case 8 :
        case 9 :
        case 10:
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[1]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                                : CamOffWidget(1),
                            NameConatiner(1, 10.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[2]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                                : CamOffWidget(2),
                            NameConatiner(2, 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[0]
                                ? RtcLocalView.SurfaceView()
                                : CamOffWidget(0),
                            NameConatiner(0, 80.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[3]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[3])
                                : CamOffWidget(3),
                            NameConatiner(3, 80.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        default:
          return Container();
      }
    }
    else if (role == ClientRole.Broadcaster && isjoin == true){
      var _uidfinal = <int>[];
      _uidfinal = _uid.toSet().toList();

      switch (_uidfinal.length) {
        case 1:
          istapped = false;
          return Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Meeting Not Found',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 27.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  engine.leaveChannel();
                  await _firestore.collection('MeetID_${widget.meeting_id}').doc(cur_user.email).delete();
                  fromchat();
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Selection_page(image: widget.image),
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 30.0, 0.0, 0.0),
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.arrow_back_ios_new, size: 20.0, color: Colors.white,),
                ),
              ),
            ],
          );
        case 2:
          isjoin = false;
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[1]
                          ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                          : CamOffWidget(1),
                      NameConatiner(1, 10.0),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[0]
                          ? RtcLocalView.SurfaceView()
                          : CamOffWidget(0),
                      NameConatiner(0, 80.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        case 3:
          isjoin = false;
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[0]
                                ? RtcLocalView.SurfaceView()
                                : CamOffWidget(0),
                            NameConatiner(0, 80.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[2]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                                : CamOffWidget(2),
                            NameConatiner(2, 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[1]
                          ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                          : CamOffWidget(1),
                      NameConatiner(1, 10.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        case 4:
        case 5:
        case 6:
        case 7:
        case 8:
        case 9:
        case 10:
          isjoin = false;
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[1]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                                : CamOffWidget(1),
                            NameConatiner(1, 10.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[2]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                                : CamOffWidget(2),
                            NameConatiner(2, 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[0]
                                ? RtcLocalView.SurfaceView()
                                : CamOffWidget(0),
                            NameConatiner(0, 80.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[3]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[3])
                                : CamOffWidget(3),
                            NameConatiner(3, 80.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        default:
          return Container();
      }
    }
    else if (role == ClientRole.Audience){
      var _uidfinal = <int>[];
      _uidfinal = _uid.toSet().toList();

      switch (_uidfinal.length) {
        case 1:
          istapped = false;
          return Stack(
            children: [
              Container(
                alignment: Alignment.center,
                child: Text(
                  'Meeting Not Found',
                  style: TextStyle(
                    color: Colors.white70,
                    fontSize: 27.0,
                  ),
                ),
              ),
              GestureDetector(
                onTap: () async {
                  engine.leaveChannel();
                  await _firestore.collection('MeetID_${widget.meeting_id}').doc(cur_user.email).delete();
                  fromchat();
                  await Navigator.push(context, MaterialPageRoute(
                    builder: (context) => Selection_page(image: widget.image),
                  ));
                  Navigator.pop(context);
                },
                child: Container(
                  padding: const EdgeInsets.fromLTRB(10.0, 30.0, 0.0, 0.0),
                  alignment: Alignment.topLeft,
                  child: Icon(Icons.arrow_back_ios_new, size: 20.0, color: Colors.white,),
                ),
              ),
            ],
          );
        case 2:
          return Stack(
            children: [
              GestureDetector(
                onTap: () {
                  setState(() {
                    istapped = !istapped;
                  });
                },
                child: _showvid[1]
                    ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                    : CamOffWidget(1),
              ),
              NameConatiner(1, 20.0),
            ],
          );
        case 3:
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Stack(
                    children: [
                    _showvid[1]
                    ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                  : CamOffWidget(1),
                      NameConatiner(1, 10.0),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[2]
                          ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                          : CamOffWidget(2),
                      NameConatiner(2, 20.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        case 4:
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[1]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                                : CamOffWidget(1),
                            NameConatiner(1, 10.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[2]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                                : CamOffWidget(2),
                            NameConatiner(2, 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Stack(
                    children: [
                      _showvid[3]
                          ? RtcRemoteView.SurfaceView(uid: _uidfinal[3])
                          : CamOffWidget(3),
                      NameConatiner(3, 20.0),
                    ],
                  ),
                ),
              ],
            ),
          );
        case 5 :
        case 6 :
        case 7 :
        case 8 :
        case 9 :
        case 10:
          return GestureDetector(
            onTap: () {
              setState(() {
                istapped = !istapped;
              });
            },
            child: Column(
              children: <Widget> [
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[1]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[1])
                                : CamOffWidget(1),
                            NameConatiner(1, 10.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[2]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[2])
                                : CamOffWidget(2),
                            NameConatiner(2, 10.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Expanded(
                  child: Row(
                    children: <Widget> [
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[3]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[3])
                                : CamOffWidget(3),
                            NameConatiner(3, 20.0),
                          ],
                        ),
                      ),
                      Expanded(
                        child: Stack(
                          children: [
                            _showvid[4]
                                ? RtcRemoteView.SurfaceView(uid: _uidfinal[4])
                                : CamOffWidget(4),
                            NameConatiner(4, 20.0),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
        default :
          return Container();
      }
    }
    else{
      return Container();
    }
  }


  Widget SwitchCam() {
    if (role == ClientRole.Broadcaster && istapped == true) {
      return Container(
        alignment: Alignment.topRight,
        padding: const EdgeInsets.fromLTRB(0.0, 40.0, 13.0, 0.0),
        child: RawMaterialButton(
          onPressed: () => engine.switchCamera(),
          child: Icon(
            Icons.switch_camera,
            color: Colors.white,
            size: 20.0,
          ),
          shape: CircleBorder(),
          fillColor: Color(0xFF292B2D).withOpacity(0.55),
          padding: const EdgeInsets.all(10.0),
        ),
      );
    }
    else if (role == ClientRole.Audience && istapped == true){
      if (_uid.length == 1){
        istapped = false;
        return Container();
      }
      else {
        return Container(
          alignment: Alignment.topRight,
          padding: const EdgeInsets.fromLTRB(0.0, 40.0, 13.0, 0.0),
          child: RawMaterialButton(
            onPressed: () => ToChat(),
            child: Icon(
              Icons.chat,
              color: Colors.white,
              size: 20.0,
            ),
            shape: CircleBorder(),
            fillColor: Color(0xFF292B2D).withOpacity(0.55),
            padding: const EdgeInsets.all(10.0),
          ),
        );
      }
    }
    else {
      return Container();
    }
  }

  Widget bottom_widget() {
    if (role == ClientRole.Audience && istapped == true){
      if (_uid.length == 1){
        istapped = false;
        return Container();
      }
      return Container(
        alignment: Alignment.bottomCenter,
        padding: const EdgeInsets.only(bottom: 30.0),
        child: RawMaterialButton(
          onPressed: () => Call_end(),
          child: Icon(
            Icons.call_end,
            color: Colors.white,
            size: 28.0,
          ),
          shape: CircleBorder(),
          fillColor: Colors.redAccent,
          padding: const EdgeInsets.all(13.0),
        ),
      );
    }
    else if (role == ClientRole.Broadcaster && istapped == true){
      return Container(
        alignment: Alignment.bottomCenter,
        //height: 20.0,
        //color: Colors.black12,
        padding: const EdgeInsets.only(bottom: 0.0),
        child: Container(
          padding: const EdgeInsets.only(bottom: 0.0),
          height: 70.0,
          decoration: BoxDecoration(
            color: Color(0xFF292B2D).withOpacity(0.95),
            borderRadius: BorderRadius.only(topLeft: Radius.circular(8.0), topRight: Radius.circular(10.0)),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: <Widget>[
              RawMaterialButton(
                onPressed: () => ToChat(),
                child: Icon(
                  Icons.chat,
                  color: Colors.white,
                  size: 22.0,
                ),
                shape: CircleBorder(),
                fillColor: Color(0xFF73777B),
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: (){
                  setState(() {
                    mic = !mic;
                  });
                  engine.muteLocalAudioStream(mic);
                },
                child: Icon(
                  mic ? Icons.mic_off : Icons.mic,
                  color: mic ? Colors.black : Colors.white,
                  size: 22.0,
                ),
                shape: CircleBorder(),
                fillColor: mic ? Colors.white : Color(0xFF73777B),
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: Cam_off,
                child: Icon(
                  camera ? Icons.videocam_off : Icons.videocam,
                  color: camera ? Colors.black : Colors.white,
                  size: 22.0,
                ),
                shape: CircleBorder(),
                fillColor: camera ? Colors.white : Color(0xFF73777B),
                padding: const EdgeInsets.all(12.0),
              ),
              RawMaterialButton(
                onPressed: () => Call_end(),
                child: Icon(
                  Icons.call_end,
                  color: Colors.white,
                  size: 22.0,
                ),
                shape: CircleBorder(),
                fillColor: Colors.redAccent,
                padding: const EdgeInsets.all(12.0),
              ),
            ],
          ),
        ),
      );
    }
    else {
      return Container();
    }
  }


  Future<void> Call_end() async {
    engine.leaveChannel();
    await _firestore.collection('MeetID_${widget.meeting_id}').doc(cur_user.email).delete();
    fromchat();
    await Navigator.push(context, MaterialPageRoute(
      builder: (context) => Selection_page(image: widget.image),
    ));
    Navigator.pop(context);
  }

  void Cam_off(){
    setState(() {
      camera = !camera;
      _showvid[0] = !camera;
    });
    engine.muteLocalVideoStream(camera);
  }

  Future<void> fromchat() async {
    if (widget.fromChat){
      await _firestore.collection('MeetID_${widget.meeting_id}').doc(cur_user.email).set({
        'part_disp': cur_user.displayName,
        'part_email': cur_user.email,
        'part_type': 2,
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          children: <Widget>[
            Call_widget(),
            SwitchCam(),
            bottom_widget(),
          ],
        ),
      ),
    );
  }

  Future<void> ToChat() async {
    await Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
            ChatScreen(meeting_id: widget.meeting_id, sel_type: widget.sel_type, image: widget.image,),
      ),
    );
  }
}