import 'package:flutter/material.dart';

class UserDetails extends StatefulWidget {
  @override
  _UserDetailsState createState() => _UserDetailsState();
}

class _UserDetailsState extends State<UserDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 10, horizontal: 15),
          child: Column(
            children: [
              Stack(),
              TabBar(
                tabs: [
                  Text('Images'),
                  Text('Videos'),
                  Text('Files'),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
