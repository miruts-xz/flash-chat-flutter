import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flash_chat/%20models/custom_user.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_time/true_time.dart';

class MessageBubble extends StatelessWidget {
  final CustomUser sender;
  final String text;
  final Timestamp timestamp;
  final MaterialColor meColorcs;
  final bool isMe;
  final AnimationController controller;

  MessageBubble({
    Key key,
    this.sender,
    this.text,
    this.timestamp,
    this.isMe,
    this.meColorcs,
    this.controller,
  }) : super(key: key);

  Widget _buildOtherMessageBubble(context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: controller, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 25.0,
            backgroundImage:
                sender.photoUrl != null ? NetworkImage(sender.photoUrl) : null,
            backgroundColor:
                sender.photoUrl != null ? null : Colors.lightBlueAccent,
            child: sender.photoUrl == null
                ? Text(
                    '${sender.displayName[0].toUpperCase()}',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 30.0,
                    ),
                  )
                : null,
          ),
          SizedBox(
            width: 10.0,
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Colors.white,
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Color(0xff525C73),
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
                        int hours = snapshot.data
                            .difference(timestamp.toDate())
                            .inHours;
                        int minutes = snapshot.data
                            .difference(timestamp.toDate())
                            .inMinutes;
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
                        return Container();
                      }
                    }),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildMeMessageBubble(context) {
    return SizeTransition(
      sizeFactor: CurvedAnimation(parent: controller, curve: Curves.easeOut),
      axisAlignment: 0.0,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Material(
                  borderRadius: BorderRadius.all(Radius.circular(20.0)),
                  color: Color(0xff1A233B),
                  elevation: 2.0,
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Text(
                      text,
                      style: TextStyle(
                        fontSize: 18.0,
                        color: Colors.white,
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
                        int minutes = snapshot.data
                            .difference(timestamp.toDate())
                            .inMinutes;
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
                        return Container();
                      }
                    }),
              ],
            ),
          ),
          SizedBox(
            width: 10.0,
          ),
          CircleAvatar(
              radius: 25.0,
              backgroundImage:
                  sender.photoUrl != null ? NetworkImage(sender.photoUrl) : null,
              backgroundColor:
                  sender.photoUrl == null ? Colors.lightBlueAccent : null,
              child: sender.photoUrl == null
                  ? Text(
                      '${sender.displayName[0].toUpperCase()}',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 30.0,
                      ),
                    )
                  : null),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        vertical: 10,
        horizontal: 8.0,
      ),
      child: isMe
          ? _buildMeMessageBubble(context)
          : _buildOtherMessageBubble(context),
    );
  }
}

Future<DateTime> _getTime() async {
  return await TrueTime.now();
}
