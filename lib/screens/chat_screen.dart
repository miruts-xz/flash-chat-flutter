import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_time/true_time.dart';

final fs = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
User loggedInUser;
MaterialColor _meColorcs;
MaterialColor _anotherColorcs;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final MaterialColor meColor;
  final MaterialColor anotherColor;
  final String uid;
  final String friendUsername;

  ChatScreen(
      {Key key, this.uid, this.friendUsername, this.meColor, this.anotherColor})
      : super(key: key);

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  TextEditingController messageTextController = TextEditingController();
  CollectionReference chatMessages;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    _getCurrentUser();
    _anotherColorcs = widget.anotherColor;
    _meColorcs = widget.meColor;
  }

  void _initPlatformState() async {
    await TrueTime.init(ntpServer: 'time.google.com');
  }

  Future<DateTime> _getCurrentTime() async {
    return await TrueTime.now();
  }

  void _getCurrentUser() {
    try {
      final User user = auth.currentUser;
      if (user != null) {
        loggedInUser = user;
      }
    } catch (e) {
      print(e);
    }
  }

  Future<CollectionReference> _getChatMessages() async {
    final friendChats = await fs
        .collection('messages')
        .doc('${widget.uid}')
        .collection('${auth.currentUser.uid}')
        .doc('chats')
        .collection('chats')
        .get();
    if (friendChats.size > 0) {
      chatMessages = fs
          .collection('messages')
          .doc(widget.uid)
          .collection(loggedInUser.uid)
          .doc('chats')
          .collection('chats');
    } else {
      chatMessages = fs
          .collection('messages')
          .doc(loggedInUser.uid)
          .collection('${widget.uid}')
          .doc('chats')
          .collection('chats');
    }
    return chatMessages;
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Color(0xffF3F6FB),
        appBar: PreferredSize(
          preferredSize: Size(double.infinity, 100.0),
          child: Container(
            decoration: BoxDecoration(color: Colors.blue),
            padding: EdgeInsets.only(
              left: 16.0,
              top: 8.0,
              bottom: 8.0,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    GestureDetector(
                      onTap: () {},
                      child: Icon(
                        Icons.account_circle,
                        color: Colors.white,
                        size: 50.0,
                      ),
                    ),
                    SizedBox(
                      width: 10.0,
                    ),
                    Text(
                      widget.friendUsername,
                      style: TextStyle(
                          fontWeight: FontWeight.w700,
                          fontSize: 24.0,
                          color: Colors.white),
                    ),
                  ],
                ),
                IconButton(
                  icon: Icon(
                    Icons.close,
                    color: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                ),
              ],
            ),
          ),
        ),
        body: SafeArea(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              MessagesStream(
                uid: widget.uid,
                future: _getChatMessages,
                friendUsername: widget.friendUsername,
              ),
              Container(
                decoration: kMessageContainerDecoration,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: <Widget>[
                    Expanded(
                      child: TextField(
                        controller: messageTextController,
                        decoration: kMessageTextFieldDecoration,
                      ),
                    ),
                    FlatButton(
                      onPressed: () async {
                        if (messageTextController.text != null &&
                            messageTextController.text != "") {
                          chatMessages.add({
                            'text': messageTextController.text,
                            'sender': loggedInUser?.email,
                            'timestamp':
                                Timestamp.fromDate(await _getCurrentTime()),
                          });
                          messageTextController.clear();
                        }
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
      ),
    );
  }
}

class MessagesStream extends StatelessWidget {
  final String uid;
  final Function future;
  final String friendUsername;

  MessagesStream({Key key, this.uid, this.future, this.friendUsername});

  @override
  Widget build(BuildContext context) {
    return FutureBuilder<CollectionReference>(
        future: future(),
        builder: (context, snapshot) {
          if (!(snapshot.connectionState == ConnectionState.done)) {
            return Center(
              child: CircularProgressIndicator(
                backgroundColor: Colors.lightBlueAccent,
              ),
            );
          }
          return StreamBuilder<QuerySnapshot>(
            stream: snapshot.data
                .orderBy('timestamp', descending: true)
                .snapshots(),
            builder: (context, snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                );
              }
              return Expanded(
                child: ListView.builder(
                  reverse: true,
                  itemBuilder: (context, index) {
                    final m = snapshot.data.docs[index];
                    final messageText = m.data()['text'];
                    final sender = m.data()['sender'];
                    final timestamp = m.data()['timestamp'];
                    final currentUser = loggedInUser?.email;
                    return MessageBubble(
                      key: Key('$messageText$timestamp'),
                      sender: sender,
                      timestamp: timestamp,
                      text: messageText,
                      isMe: currentUser == sender,
                    );
                  },
                  itemCount: snapshot.data.docs.length,
                ),
              );
            },
          );
        });
  }
}

class MessageBubble extends StatelessWidget {
  final String sender, text;
  final Timestamp timestamp;
  final bool isMe;

  MessageBubble({Key key, this.sender, this.text, this.timestamp, this.isMe})
      : super(key: key);

  Widget _buildOtherMessageBubble(context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          height: 60,
          width: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _anotherColorcs,
          ),
          child: Text(
            '${sender[0].toUpperCase()}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
        SizedBox(
          width: 10.0,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 90),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: Colors.white,
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Color(0xff525C73),
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            FutureBuilder<DateTime>(
                future: _getTime(),
                builder: (context, AsyncSnapshot<DateTime> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    int hours =
                        snapshot.data.difference(timestamp.toDate()).inHours;
                    int minutes =
                        snapshot.data.difference(timestamp.toDate()).inMinutes;
                    return Text(
                      hours > 23
                          ? '${DateFormat.MMMd().add_jm().format(timestamp.toDate())}'
                          : hours > 0
                              ? '${hours}h ago'
                              : minutes > 0
                                  ? '${minutes}m ago'
                                  : 'Just now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff9DA5B4),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ],
        ),
      ],
    );
  }

  Widget _buildMeMessageBubble(context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.end,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Column(
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              constraints: BoxConstraints(
                  maxWidth: MediaQuery.of(context).size.width - 90),
              child: Material(
                borderRadius: BorderRadius.all(Radius.circular(20.0)),
                color: Color(0xff1A233B),
                elevation: 2.0,
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Text(
                    text,
                    style: TextStyle(
                      fontSize: 20.0,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            FutureBuilder<DateTime>(
                future: _getTime(),
                builder: (context, AsyncSnapshot<DateTime> snapshot) {
                  if (snapshot.connectionState == ConnectionState.done) {
                    int hours =
                        snapshot.data.difference(timestamp.toDate()).inHours;
                    int minutes =
                        snapshot.data.difference(timestamp.toDate()).inMinutes;
                    return Text(
                      hours > 23
                          ? '${DateFormat.MMMd().add_jm().format(timestamp.toDate())}'
                          : hours > 0
                              ? '${hours}h ago'
                              : minutes > 0
                                  ? '${minutes}m ago'
                                  : 'Just now',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xff9DA5B4),
                      ),
                    );
                  } else {
                    return CircularProgressIndicator();
                  }
                }),
          ],
        ),
        SizedBox(
          width: 10.0,
        ),
        Container(
          height: 60,
          width: 60,
          alignment: Alignment.center,
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(30),
            color: _meColorcs,
          ),
          child: Text(
            '${sender[0].toUpperCase()}',
            style: TextStyle(
              color: Colors.white,
              fontSize: 30.0,
            ),
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(10.0),
      child: isMe
          ? _buildMeMessageBubble(context)
          : _buildOtherMessageBubble(context),
    );
  }
}

Future<DateTime> _getTime() async {
  return await TrueTime.now();
}
