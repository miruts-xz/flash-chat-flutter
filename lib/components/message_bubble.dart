import 'package:flash_chat/models/text_message.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:true_time/true_time.dart';

class MessageBubble extends StatelessWidget {
  final TextMessage message;
  final MaterialColor meColorcs;
  final bool isMe;

  MessageBubble({
    Key key,
    this.message,
    this.isMe,
    this.meColorcs,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.all(2.0),
      child: Row(
        mainAxisAlignment:
            isMe ? MainAxisAlignment.end : MainAxisAlignment.start,
        children: [
          Card(
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(15),
            ),
            elevation: 1.0,
            color: isMe ? Color(0xff1A233B) : Colors.white,
            child: Padding(
              padding:
                  const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
              child: Column(
                crossAxisAlignment:
                    isMe ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                children: [
                  Container(
                    constraints: BoxConstraints(maxWidth: size.width - 45),
                    child: Text(
                      message.text,
                      style: TextStyle(
                        fontSize: 16.0,
                        color: isMe ? Colors.white : Color(0xff525C73),
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
                              .difference(message.timestamp.toDate())
                              .inHours;
                          int minutes = snapshot.data
                              .difference(message.timestamp.toDate())
                              .inMinutes;
                          int seconds = snapshot.data
                              .difference(message.timestamp.toDate())
                              .inSeconds;
                          final color = Color(0xff9DA5B4);
                          return Text(
                            hours > 23
                                ? '${DateFormat.MMMd().add_jm().format(message.timestamp.toDate())}'
                                : hours > 0
                                    ? '${hours}h ago'
                                    : minutes > 0
                                        ? '${minutes}m ago'
                                        : seconds > 30
                                            ? '1m ago'
                                            : 'Just now',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 12.0,
                              color: color,
                            ),
                          );
                        } else {
                          return Container();
                        }
                      }),
                ],
              ),
            ),
          )
        ],
      ),
    );
  }

  Future<DateTime> _getTime() async {
    return await TrueTime.now();
  }
}
