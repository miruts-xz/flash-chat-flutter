import 'package:flutter/material.dart';

class NewGroup extends StatefulWidget {
  @override
  _NewGroupState createState() => _NewGroupState();
}

class _NewGroupState extends State<NewGroup> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.group_add,
          size: 120.0,
          color: Colors.orange,
        ),
      ),
    );
  }
}
