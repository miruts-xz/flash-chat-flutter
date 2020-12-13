/*
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/%20models/custom_user.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
RenderSliverList list ;
class CustomAppBar extends RenderSliver {
  final CustomUser selectedUser;
  CustomAppBar({this.selectedUser});

  @override
  Widget build(BuildContext context) {
    return SliverAppBar(
      expandedHeight: 180.0,
      leading: IconButton(
        icon: Icon(Icons.arrow_back),
        onPressed: () {
          Navigator.pop(context);
        },
      ),
      flexibleSpace: FlexibleSpaceBar(
        title: Text(
          selectedUser.displayName,
        ),
        background: selectedUser.photoUrl != null
            ? Image.network(
                selectedUser.photoUrl,
                fit: BoxFit.cover,
              )
            : Container(),
      ),
    );
  }

  @override
  void performLayout() {
  }
}
*/
