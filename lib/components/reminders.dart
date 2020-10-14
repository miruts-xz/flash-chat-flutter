import 'package:flutter/material.dart';

class Contacts extends StatefulWidget {
  @override
  _ContactsState createState() => _ContactsState();
}

class _ContactsState extends State<Contacts> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Icon(
          Icons.person,
          size: 120.0,
          color: Colors.purple,
        ),
      ),
    );
  }
}
