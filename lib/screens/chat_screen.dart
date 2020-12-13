import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/custom_user.dart';
import 'package:flash_chat/models/text_message.dart';
import 'package:flash_chat/components/message_bubble.dart';
import 'package:flash_chat/components/message_composer.dart';
import 'package:flash_chat/components/profile_details.dart';
import 'package:flutter/material.dart';
import 'package:true_time/true_time.dart';

final fs = FirebaseFirestore.instance;
final auth = FirebaseAuth.instance;
MaterialColor _meColorcs;
MaterialColor _anotherColorcs;

class ChatScreen extends StatefulWidget {
  static const String id = 'chat_screen';
  final MaterialColor meColor;
  final MaterialColor anotherColor;
  final CustomUser selectedUser;

  ChatScreen({this.selectedUser, this.meColor, this.anotherColor});

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> with TickerProviderStateMixin {
  TextEditingController messageTextController = TextEditingController();
  CollectionReference chatMessages;
  final loggedInUser = auth.currentUser;
  List<TextMessage> messages = [];

  GlobalKey<AnimatedListState> _listKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    WidgetsBinding.instance.addPostFrameCallback(initiateConnection);
    _getChatMessages();
    _anotherColorcs = widget.anotherColor;
    _meColorcs = widget.meColor;
  }

  void initiateConnection(Duration dur) {
    var subscription = chatMessages.orderBy('timestamp').snapshots();
    subscription.listen(handleDocChanges);
  }

  void handleDocChanges(QuerySnapshot snapshot) {
    Future ft = Future(() {});
    snapshot.docChanges.forEach((DocumentChange docChange) {
      ft = ft.then((value) {
        Future.delayed(Duration(milliseconds: 300), () {
          TextMessage message = TextMessage.fromDoc(docChange.doc);
          if (messages.length == 0) {
            messages.add(message);
            _listKey.currentState.insertItem(messages.length - 1);
          } else {
            messages.insert(0, message);
            _listKey.currentState.insertItem(0);
          }
        });
      });
    });
  }

  void _initPlatformState() async {
    await TrueTime.init(ntpServer: 'time.google.com');
  }

  Future<DateTime> _getCurrentTime() async {
    return await TrueTime.now();
  }

  void _getChatMessages() {
    int cmp = auth.currentUser.uid.compareTo(widget.selectedUser.uid);
    bool mineGreater = cmp == 1;

    chatMessages = mineGreater
        ? fs
            .collection('messages')
            .doc('${widget.selectedUser.uid}_${auth.currentUser.uid}')
            .collection('chats')
        : fs
            .collection('messages')
            .doc('${auth.currentUser.uid}_${widget.selectedUser.uid}')
            .collection('chats');
  }

  void _onSendCallback(String message) async {
    chatMessages.add({
      'text': message,
      'sender': loggedInUser?.uid,
      'timestamp': Timestamp.fromDate(await _getCurrentTime()),
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xffF3F6FB),
      appBar: AppBar(
        leading: IconButton(
            icon: Icon(Icons.arrow_back),
            onPressed: () {
              Navigator.pop(context);
            }),
        title: GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => ProfileDetails(
                        selectedUser: widget.selectedUser,
                      )),
            );
          },
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              ClipRRect(
                borderRadius: BorderRadius.circular(25.0),
                child: Container(
                  height: 50,
                  width: 50,
                  child: Hero(
                    tag: 'profile_pic',
                    child: widget.selectedUser.photoUrl != null ? ExtendedImage.network(
                      widget.selectedUser.photoUrl,
                      fit: BoxFit.cover,
                      cache: true,
                    ) : Image.asset('images/profile.jpg', fit: BoxFit.cover,),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Text(widget.selectedUser.displayName),
            ],
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {},
            icon: Icon(Icons.more_vert),
          ),
        ],
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: <Widget>[
          Expanded(
            child: AnimatedList(
              reverse: true,
              key: _listKey,
              initialItemCount: messages.length,
              itemBuilder: (context, index, animation) {
                TextMessage message = messages[index];
                return SizeTransition(
                  sizeFactor: animation,
                  axisAlignment: 0.0,
                  axis: Axis.vertical,
                  child: MessageBubble(
                    isMe: message.senderId == auth.currentUser.uid,
                    message: message,
                    meColorcs: _meColorcs,
                  ),
                );
              },
            ),
          ),
          MessageComposer(onSendPressed: _onSendCallback),
        ],
      ),
    );
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
  }
/*
  MessageBubble buildMessageBubble(DocumentSnapshot doc) {
    CustomUser sender;
    String senderId = doc.data()['sender'];
    if (senderId == loggedInUser.uid)
      sender = CustomUser(
          uid: senderId,
          displayName: loggedInUser.displayName,
          photoUrl: loggedInUser.photoURL,
          email: loggedInUser.email);
    else {
      sender = widget.selectedUser;
    }
    Timestamp timestamp = doc.data()['timestamp'];
    String message = doc.data()['text'];
    AnimationController controller = AnimationController(
      duration: Duration(milliseconds: 500),
      vsync: this,
    );
    controller.forward();
    return MessageBubble(
      key: ValueKey('$message $timestamp'),
      isMe: sender.uid == loggedInUser.uid,
      timestamp: timestamp,
    );
  }
*/
}
