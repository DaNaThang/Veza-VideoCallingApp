import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'Participants.dart';
import 'CallScreen.dart';

final _firestore = FirebaseFirestore.instance;
User loggedInUser;

class ChatScreen extends StatefulWidget {
  ChatScreen({@required this.meeting_id,@ required this.sel_type, @required this.image});

  final String meeting_id;
  final int sel_type;
  final ImageProvider image;

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {

  final message_controller = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String message;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
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
        elevation: 9,
        bottom: PreferredSize(
          child: Container(
            color: Colors.white70,
            height: 0.2,
          ),
          preferredSize: Size.fromHeight(0.2),
        ),
        leading: Builder(
          builder: (BuildContext context) {
            return IconButton(
              color: Colors.blueAccent,
              icon: const Icon(Icons.arrow_back_ios),
              onPressed: () { Navigator.pop(context); },
            );
          },
        ),
        title: Text(widget.meeting_id),
        backgroundColor: Color(0xFF161616),
        actions: [
          StartCall(),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: GestureDetector(
              onTap: () async {
                await Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => Participants(meeting_id: 'MeetID_${widget.meeting_id}', sel_type: widget.sel_type,),
                  ),
                );
              },
              child: Icon(Icons.person_outline_sharp, color: Colors.blueAccent, ),
            ),
          ),
        ],
      ),
      body: SafeArea(
        child: Container(
          constraints: BoxConstraints.expand(),
          decoration: BoxDecoration(
            image: DecorationImage(
              image: AssetImage('images/background.jpg'),
              fit: BoxFit.cover,
            ),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Messages(chan_name: widget.meeting_id),
              Container(
                decoration: BoxDecoration(
                  border: Border(
                    top: BorderSide(color: Colors.white70, width: 1.0),
                  ),
                  color: Color(0xFF161616).withOpacity(1)
                ),
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: message_controller,
                        style: TextStyle(
                          color: Colors.white,
                        ),
                        onChanged: (value) {
                          message = value;
                        },
                        decoration: InputDecoration(
                          contentPadding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
                          hintText: 'Message here...',
                          hintStyle: TextStyle(
                            color: Colors.white54,
                          ),
                          border: InputBorder.none,
                        ),
                      ),
                    ),
                    TextButton(
                      onPressed: () {
                        message_controller.clear();
                        _firestore.collection(widget.meeting_id).add({
                          'text': message,
                          'sender': loggedInUser.displayName,
                          'sender_email': loggedInUser.email,
                          'TimeStamp': FieldValue.serverTimestamp(),
                        });
                      },
                      child: Text(
                        'Send',
                        style: TextStyle(
                          color: Colors.blueAccent,
                          fontWeight: FontWeight.bold,
                          fontSize: 18.0,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget StartCall () {
    if (widget.sel_type != 0) {
      return GestureDetector(
        onTap: () async {
          await Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => widget.sel_type == 2
                  ? Call_screen(image: widget.image, meeting_id: widget.meeting_id, sel_type: 0, isJoin: false, fromChat: true,)
                  : Call_screen(image: widget.image, meeting_id: widget.meeting_id, sel_type: 0, isJoin: false),
            ),
          );
        },
        child: Icon(Icons.video_call_outlined, color: Colors.blueAccent,),
      );
    }
    return Container();
  }
}

class MessageWidget extends StatelessWidget {

  MessageWidget({this.sender, this.text,@required this.isMe});

  final sender;
  final text;
  final bool isMe;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment: isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            sender,
            style: TextStyle(
              fontSize: 12.0,
              color: Colors.white54,
            ),
          ),
          SizedBox(
            height: 3.0,
          ),
          Material(
            borderRadius: isMe ? BorderRadius.only(
              topLeft: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            )
                : BorderRadius.only(
              topRight: Radius.circular(30.0),
              bottomLeft: Radius.circular(30.0),
              bottomRight: Radius.circular(30.0),
            ) ,
            elevation: 7.0,
            color: isMe ? Colors.blueAccent : Color(0xFF2B3E4F),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  fontSize: 15.0,
                  color: Colors.white,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class Messages extends StatelessWidget {
  Messages({@required this.chan_name});

  final String chan_name;
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: _firestore.collection(chan_name).orderBy('TimeStamp').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          final messages = snapshot.data.docs.reversed;
          List<MessageWidget> messagewidgets = [];
          for (var message in messages) {
            Map<String, dynamic> data = message.data() as Map<String, dynamic>;
            final messagetext = data['text'];
            var messagesender = data['sender'].toString();
            var senderemail = data['sender_email'].toString();

            var currentUser = loggedInUser.email;


            final messagewidget = MessageWidget(
              sender: messagesender,
              text: messagetext,
              isMe: currentUser == senderemail,
            );
            messagewidgets.add(messagewidget);
          }
          return Expanded(
            child: ListView(
              reverse: true,
              padding: const EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
              children: messagewidgets,
            ),
          );
        }
    );
  }
}

