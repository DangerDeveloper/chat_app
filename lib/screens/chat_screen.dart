import 'package:flutter/material.dart';
import 'package:chat_app/constants.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

final _fireStore = Firestore.instance;
FirebaseUser loginedUser;
const rad = Radius.circular(30.0);

class ChatScreen extends StatefulWidget {
  static String id = 'chat_screen';

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController textEditingController = TextEditingController();
  final _auth = FirebaseAuth.instance;
  String message;

  @override
  void initState() {
    super.initState();
    getCurrentUser();
  }

  void getCurrentUser() async {
    try {
      final user = await _auth.currentUser();
      if (user != null) {
        loginedUser = user;
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
            StreamBuilderBubble(),
            Container(
              decoration: kMessageContainerDecoration,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Expanded(
                    child: TextField(
                      controller: textEditingController,
                      onChanged: (value) {
                        message = value;
                      },
                      decoration: kMessageTextFieldDecoration,
                    ),
                  ),
                  FlatButton(
                    onPressed: () {
                      textEditingController.clear();
                      _fireStore.collection('messages').add({
                        'text': message,
                        'sender': loginedUser.email,
                        'date': DateTime.now()
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

class StreamBuilderBubble extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: _fireStore.collection('messages').orderBy('date').snapshots(),
      builder: (context, snapshots) {
        if (!snapshots.hasData) {
          return Center(
            child: CircularProgressIndicator(
              backgroundColor: Colors.grey,
            ),
          );
        }
        var messages = snapshots.data.documents.reversed;
        List<TextBubble> textBubbles = [];
        for (var message in messages) {
          var messageText = message.data['text'];
          var messageSender = message.data['sender'];
          var textbubble = TextBubble(
            text: messageText,
            sender: messageSender,
            isMe: loginedUser.email == messageSender,
          );
          textBubbles.add(textbubble);
        }
        return Expanded(
          child: ListView(
            padding: EdgeInsets.symmetric(vertical: 15.0, horizontal: 5.0),
            reverse: true,
            children: textBubbles,
          ),
        );
      },
    );
  }
}

class TextBubble extends StatelessWidget {
  final text;
  final sender;
  final bool isMe;

  TextBubble({
    @required this.text,
    @required this.sender,
    @required this.isMe,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.all(10.0),
      child: Column(
        crossAxisAlignment:
            isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
        children: <Widget>[
          Text(
            sender,
            style: TextStyle(color: Colors.black54, fontSize: 12.0),
          ),
          SizedBox(
            height: 3.0,
          ),
          Material(
            color: isMe ? Colors.greenAccent : Colors.white,
            elevation: 5.0,
            borderRadius: isMe
                ? BorderRadius.only(
                    bottomLeft: rad,
                    bottomRight: rad,
                    topLeft: rad,
                  )
                : BorderRadius.only(
                    bottomLeft: rad,
                    bottomRight: rad,
                    topRight: rad,
                  ),
            child: Padding(
              padding: const EdgeInsets.all(10.0),
              child: Text(
                text,
                style: TextStyle(
                    color: isMe ? Colors.white : Colors.black54,
                    fontSize: 15.0),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

//  void getMessage() async {
//    final messages = await _fireStore.collection('messages').getDocuments();
//    for (var message in messages.documents) {
//      print(message.data);
//    }
//  }
//
void getMessageStream() async {
  await for (var snapshot in _fireStore.collection('messages').snapshots()) {
    for (var message in snapshot.documents) {
      print(message.data);
    }
  }
}
