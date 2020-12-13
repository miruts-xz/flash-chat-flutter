import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/custom_user.dart';
import 'package:flash_chat/components/left_drawer.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';

MaterialColor meColor;

class HomeScreen extends StatelessWidget {
  static const String id = "home_screen";
  final auth = FirebaseAuth.instance;
  final CollectionReference chats =
      FirebaseFirestore.instance.collection('users');
  final User currentUser = FirebaseAuth.instance.currentUser;

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
            stream: chats.snapshots(),
            builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
              if (snapshot.hasError) {
                return Text(
                    'Something went wrong, check your internet connection');
              }
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(
                  child: CircularProgressIndicator(
                    backgroundColor: Colors.lightBlueAccent,
                  ),
                );
              }

              List<String> chatFriends = snapshot.data.docs.reversed.map((doc) {
                return doc.id;
              }).toList();
              chatFriends.remove(currentUser.uid);
              return ListView.separated(
                  itemBuilder: (context, index) {
                    return FutureBuilder<CustomUser>(
                      future: _getUser(chatFriends[index]),
                      builder: (BuildContext context,
                          AsyncSnapshot<CustomUser> snapshot) {
                        if (snapshot.hasError) {
                          return Text('Something went wrong');
                        }
                        if (snapshot.connectionState == ConnectionState.done) {
                          MaterialColor anotherColor = kAccountColors.elementAt(
                              Random().nextInt(kAccountColors.length));
                          String photoUrl = snapshot.data.photoUrl;
                          return ListTile(
                            onTap: () {
                              Navigator.push(context,
                                  MaterialPageRoute(builder: (context) {
                                return ChatScreen(
                                    meColor: Colors.blue,
                                    anotherColor: anotherColor,
                                    selectedUser: snapshot.data);
                              }));
                            },
                            leading: CircleAvatar(
                                radius: 25.0,
                                backgroundColor:
                                    photoUrl == null ? anotherColor : null,
                                backgroundImage: photoUrl == null
                                    ? null
                                    : ExtendedNetworkImageProvider(photoUrl,
                                        cache: true)
                                /*photoUrl == null
                                    ? null
                                    : NetworkImage(photoUrl)*/
                                ,
                                child: photoUrl == null
                                    ? Text(
                                        '${snapshot.data.displayName[0].toUpperCase()}',
                                        style: TextStyle(
                                          color: Colors.white,
                                          fontSize: 30.0,
                                        ),
                                      )
                                    : null),
                            title: Text(
                              snapshot.data.displayName ?? "",
                              style: TextStyle(
                                fontSize: 20.0,
                              ),
                            ),
                          );
                        }
                        return SizedBox.shrink();
                      },
                    );
                  },
                  separatorBuilder: (context, index) {
                    return Divider();
                  },
                  itemCount: chatFriends.length);
            }),
      ),
      drawer: LeftDrawerWidget(),
    );
  }

  Future<CustomUser> _getUser(String id) async {
    DocumentSnapshot doc = await fs.collection('users').doc('$id').get();
    return CustomUser.fromJson(doc.data());
  }
}
