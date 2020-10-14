import 'package:flutter/material.dart';

class NewChannel extends StatefulWidget {
  @override
  _NewChannelState createState() => _NewChannelState();
}

class _NewChannelState extends State<NewChannel> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: Icon(
        Icons.record_voice_over,
        size: 120.0,
        color: Colors.lightGreen,
      )),
    );
  }
}
