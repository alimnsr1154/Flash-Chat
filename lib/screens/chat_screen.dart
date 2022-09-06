import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _store = FirebaseFirestore.instance;
late User loggedin;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final message_controller = TextEditingController();

  final _auth = FirebaseAuth.instance;
  late String message;

  @override
  void initState() {
    // TODO: implement initState

    super.initState();
    getcurrentuser();
  }

  void getcurrentuser() async {
    try {
      final user = await _auth.currentUser;
      if (user != null) {
        loggedin = user;
      }
    } catch (e) {
      print(e);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: null,
        actions: <Widget>[
          IconButton(
              icon: Icon(Icons.close),
              onPressed: () {
                _auth.signOut();
                Navigator.pop(context);
                //Implement logout functionality
              }),
        ],
        title: Text('⚡️Chat'),
        backgroundColor: Colors.lightBlueAccent,
      ),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Messagestream(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: message_controller,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      message_controller.clear();
                      _store.collection('message').add({
                        'text': message,
                        'sender': loggedin.email,
                        'time': DateTime.now(),
                      });
                    },
                    child: Text(
                      'Send',
                      style: kSendButtonTextStyle,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class Messagestream extends StatelessWidget {
  const Messagestream({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _store
          .collection('message')
          .orderBy('time', descending: false)
          .snapshots(),
      builder: (context, snapshot) {
        if (!snapshot.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.lightBlue,
            ),
          );
        }
        final messagess = snapshot.data?.docs.reversed;
        List<Messagebubble> messageslist = [];
        for (var mess in messagess!) {
          final messagetext = mess['text'];
          final sender = mess['sender'];
          final messageTime = mess['time'];
          final currentuser = loggedin.email;
          final messagewidget = Messagebubble(
            text: messagetext,
            sender: sender,
            me: currentuser == sender,
            time: messageTime,
          );
          messageslist.add(messagewidget);
        }
        return Expanded(
          child: ListView(
            reverse: true,
            padding: EdgeInsets.symmetric(horizontal: 10.0, vertical: 20.0),
            children: messageslist,
          ),
        );
      },
    );
  }
}

class Messagebubble extends StatelessWidget {
  Messagebubble(
      {required this.text,
      required this.sender,
      required this.me,
      required this.time});
  late String text;
  late String sender;
  late bool me;
  late final Timestamp time;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            me ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: [
          Text(
            "$sender ${time.toDate()}",
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          Material(
            borderRadius: me
                ? BorderRadius.only(
                    bottomLeft: Radius.circular(35.0),
                    bottomRight: Radius.circular(35.0),
                    topLeft: Radius.circular(35.0),
                  )
                : BorderRadius.only(
                    bottomLeft: Radius.circular(35.0),
                    bottomRight: Radius.circular(35.0),
                    topRight: Radius.circular(35.0),
                  ),
            elevation: 5.0,
            color: me ? Colors.lightBlue : Colors.white,
            child: Padding(
              padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 20.0),
              child: Text(
                text,
                style: TextStyle(
                  color: me ? Colors.white : Colors.black54,
                  fontSize: 15.0,
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
