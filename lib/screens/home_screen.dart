import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/left_drawer.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

final auth = FirebaseAuth.instance;
final fs = FirebaseFirestore.instance;

MaterialColor meColor;

class HomeScreen extends StatefulWidget {
  static const String id = "home_screen";

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  User currentUser = auth.currentUser;
  Stream<QuerySnapshot> chats = fs.collection('users').snapshots();
  String currentUsername;

  void _getCurrentUsername() async {
    final docref = await fs.collection('users').doc('${currentUser.uid}').get();
    String uname = docref.data()['name'];
    setState(() {
      currentUsername = uname;
    });
  }

  @override
  void initState() {
    super.initState();
    _getCurrentUsername();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('⚡️Chat'),
        actions: [
          IconButton(
            icon: Icon(
              Icons.search,
              color: Colors.white,
            ),
            onPressed: () {},
          ),
          IconButton(
            icon: Icon(
              Icons.logout,
              color: Colors.white,
            ),
            tooltip: "Logout",
            onPressed: () {
              auth.signOut();
              Navigator.pop(context);
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: StreamBuilder<QuerySnapshot>(
            stream: chats,
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (!snapshot.hasData) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                );
              }
              if (snapshot.hasError) {
                return Text(
                    'Something went wrong, check your internet connection');
              }
              List<String> chatFriends =
                  snapshot.data.docs.reversed.map((doc) => doc.id).toList();
              chatFriends.remove(currentUser.uid);
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return FutureBuilder<String>(
                      future: _getName(chatFriends[index]),
                      builder: (BuildContext context,
                          AsyncSnapshot<String> snapshot) {
                        if (!(snapshot.connectionState ==
                            ConnectionState.done)) {
                          return Center(
                            child: CircularProgressIndicator(),
                          );
                        }
                        MaterialColor anotherColor = kAccountColors
                            .elementAt(Random().nextInt(kAccountColors.length));
                        return ListTile(
                          onTap: () {
                            Navigator.push(context,
                                MaterialPageRoute(builder: (context) {
                              return ChatScreen(
                                  meColor: Colors.blue,
                                  anotherColor: anotherColor,
                                  uid: chatFriends[index],
                                  friendUsername: snapshot.data);
                            }));
                          },
                          leading: Container(
                            height: 50,
                            width: 50,
                            alignment: Alignment.center,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(25),
                              color: anotherColor,
                            ),
                            child: Text(
                              '${snapshot.data[0].toUpperCase()}',
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 24.0,
                              ),
                            ),
                          ),
                          title: Text(
                            snapshot.data != null ? snapshot.data : "",
                            style: TextStyle(
                              fontSize: 20.0,
                            ),
                          ),
                        );
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: chatFriends.length);
            }),
      ),
      drawer: LeftDrawerWidget(user: currentUsername),
    );
  }

  Future<String> _getName(String id) async {
    DocumentSnapshot doc = await fs.collection('users').doc('$id').get();
    String name = doc.data()['name'];
    return name;
  }
}
