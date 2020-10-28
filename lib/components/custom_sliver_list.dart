import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class CustomSliverList extends StatelessWidget {
  final CollectionReference chatMessages;

  CustomSliverList({this.chatMessages});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
        stream: chatMessages.orderBy('timestamp', descending: true).snapshots(),
        builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
          return SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                return ListTile(
                  leading: CircleAvatar(
                    backgroundColor: Colors.blue,
                  ),
                  title: snapshot.data.docs[index].data()['text'],
                );
              },
              childCount: snapshot.data.docs.length,
            ),
          );
        });
  }
}
