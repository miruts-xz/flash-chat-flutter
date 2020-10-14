import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

import 'menu_list_tile.dart';

class LeftDrawerWidget extends StatefulWidget {
  final String user;

  const LeftDrawerWidget({Key key, this.user}) : super(key: key);

  @override
  _LeftDrawerWidgetState createState() => _LeftDrawerWidgetState();
}

class _LeftDrawerWidgetState extends State<LeftDrawerWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: () {},
            currentAccountPicture: GestureDetector(
              onTap: () {},
              child: Container(
                height: 60,
                width: 60,
                alignment: Alignment.center,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(40),
                  color: Colors.white,
                ),
                child: Icon(
                  Icons.add_a_photo,
                  color: Colors.lightBlueAccent,
                  size: 32.0,
                ),
                /*Text(
                  '${widget.user[0].toUpperCase()}',
                  style: TextStyle(
                    color: Colors.lightBlueAccent,
                    fontSize: 30.0,
                  ),
                ),*/
              ),
            ),
            accountName: Text(
              widget.user,
              style: TextStyle(fontSize: 24.0),
            ),
            accountEmail: Text('${auth.currentUser.email}'),
            otherAccountsPictures: <Widget>[
              Icon(
                Icons.bookmark_border,
                color: Colors.white,
              )
            ],
            decoration: BoxDecoration(
              color: Colors.lightBlue,
            ),
          ),
          const MenuListTileWidget(),
        ],
      ),
    );
  }
}
