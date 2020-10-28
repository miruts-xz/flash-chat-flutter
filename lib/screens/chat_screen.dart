import 'dart:async';
import 'dart:collection';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/%20models/custom_user.dart';
import 'package:flash_chat/components/custom_sliver_appbar.dart';
import 'package:flash_chat/components/custom_sliver_list.dart';
import 'package:flash_chat/components/message_bubble.dart';
import 'package:flash_chat/components/message_composer.dart';
import 'package:flash_chat/constants.dart';
import 'package:flutter/material.dart';
import 'package:flutter/scheduler.dart';
import 'package:intl/intl.dart';
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
  List<DocumentSnapshot> messages = [];
  List<DocumentSnapshot> reversedList = [];
  final ScrollController scrollController = ScrollController();
  StreamSubscription<QuerySnapshot> subscription;

  @override
  void initState() {
    super.initState();
    _initPlatformState();
    _getChatMessages();
    _anotherColorcs = widget.anotherColor;
    _meColorcs = widget.meColor;
  }

  void _initPlatformState() async {
    await TrueTime.init(ntpServer: 'time.google.com');
  }

  Future<DateTime> _getCurrentTime() async {
    return await TrueTime.now();
  }

  Future<void> _getChatMessages() async {
    final friendChats = await fs
        .collection('messages')
        .doc('${widget.selectedUser.uid}')
        .collection('${auth.currentUser.uid}')
        .doc('chats')
        .collection('chats')
        .get();
    if (friendChats.size > 0) {
      chatMessages = fs
          .collection('messages')
          .doc(widget.selectedUser.uid)
          .collection(loggedInUser.uid)
          .doc('chats')
          .collection('chats');
    } else {
      chatMessages = fs
          .collection('messages')
          .doc(loggedInUser.uid)
          .collection('${widget.selectedUser.uid}')
          .doc('chats')
          .collection('chats');
    }
    subscription =
        chatMessages.orderBy('timestamp').snapshots().listen(queryHandler);
  }

  void queryHandler(QuerySnapshot snapshot) {
    snapshot.docChanges.forEach((element) {
      messages.add(element.doc);
    });
    setState(() {
      reversedList = messages.reversed.toList();
    });
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
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Expanded(
              child: NestedScrollView(
                controller: scrollController,
                floatHeaderSlivers: true,
                headerSliverBuilder: (context, scroll) {
                  return [buildSliverAppBar(context)];
                },
                body: ListView.builder(
                  itemBuilder: (context, index) {
                    return buildMessageBubble(reversedList[index]);
                  },
                  itemCount: reversedList.length,
                  // reverse: true,
                ),
              ),
            ),
/*            Expanded(
              child: Container(
                child: CustomScrollView(
                  controller: scrollController,
                  slivers: [
                    buildSliverAppBar(context),
                    buildSliverList(messages),
                  ],
                ),
              ),
            )*/
            MessageComposer(onSendPressed: _onSendCallback),
          ],
        ),
      ),
    );
  }

  SliverList buildSliverList(List<DocumentSnapshot> messages) {
    return SliverList(
      delegate: SliverChildBuilderDelegate((context, index) {
        return buildMessageBubble(messages[index]);
      }, childCount: messages.length),
    );
  }

  SliverAppBar buildSliverAppBar(BuildContext context) {
    return SliverAppBar(
      elevation: 2.0,
      expandedHeight: 200.0,
      pinned: true,
      floating: true,
      // centerTitle: true,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          widget.selectedUser.displayName,
        ),
        background: widget.selectedUser.photoUrl != null
            ? Image.network(
                widget.selectedUser.photoUrl,
                fit: BoxFit.cover,
              )
            : Container(),
      ),
    );
  }

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
      controller: controller,
      sender: sender,
      isMe: sender.uid == loggedInUser.uid,
      timestamp: timestamp,
      text: message,
    );
  }

  @override
  void dispose() {
    subscription.cancel();
    super.dispose();
  }
}
