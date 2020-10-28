import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';

import 'menu_list_tile.dart';

class LeftDrawerWidget extends StatefulWidget {
  @override
  _LeftDrawerWidgetState createState() => _LeftDrawerWidgetState();
}

class _LeftDrawerWidgetState extends State<LeftDrawerWidget> {
  FirebaseAuth auth = FirebaseAuth.instance;
  File _image;
  bool _isLoading = false;
  User loggedInUser;
  String photoUrl;
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  storage.FirebaseStorage firebaseStorage = storage.FirebaseStorage.instance;

  Future _getImageGallery() async {
    var image = await ImagePicker.pickImage(source: ImageSource.gallery);
    setState(() {
      _image = image;
    });
  }

  Future _getImageCamera() async {
    var image = await ImagePicker.pickImage(source: ImageSource.camera);
    setState(() {
      _image = image;
    });
  }

  @override
  void initState() {
    setState(() {
      loggedInUser = auth.currentUser;
      photoUrl = auth.currentUser.photoURL;
    });
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: ListView(
        children: <Widget>[
          UserAccountsDrawerHeader(
            onDetailsPressed: () {},
            currentAccountPicture: GestureDetector(
              onTap: () async {
                await _getImageGallery();
                if (_image != null) {
                  String type =
                      _image.path.substring(_image.path.lastIndexOf('.'));
                  storage.StorageReference ref = firebaseStorage
                      .ref()
                      .child('users')
                      .child(loggedInUser.uid)
                      .child('images')
                      .child('profile$type');
                  storage.StorageUploadTask uploadTask = ref.putFile(_image);
                  uploadTask.events.listen((event) async {
                    if (event.type != storage.StorageTaskEventType.success &&
                        event.type != storage.StorageTaskEventType.failure) {
                      if (!_isLoading) {
                        setState(() {
                          _isLoading = true;
                        });
                      }
                    } else if (event.type ==
                        storage.StorageTaskEventType.failure) {
                      setState(() {
                        _isLoading = false;
                      });
                      return;
                    } else if (event.type ==
                        storage.StorageTaskEventType.success) {
                      String url = await (await uploadTask.onComplete)
                          .ref
                          .getDownloadURL();
                      firestore
                          .collection('users')
                          .doc(loggedInUser.uid)
                          .update({'photoUrl': url});
                      auth.currentUser.updateProfile(photoURL: url);
                      setState(() {
                        _isLoading = false;
                        photoUrl = url;
                      });
                    }
                  });
                }
              },
              child: photoUrl != null
                  ? CircleAvatar(
                      radius: 35.0,
                      backgroundImage: NetworkImage(photoUrl),
                    )
                  : CircleAvatar(
                      radius: 35.0,
                      backgroundColor: Colors.white,
                      child: _isLoading
                          ? CircularProgressIndicator(
                              backgroundColor: Colors.white,
                            )
                          : Icon(
                              Icons.add_a_photo,
                              color: Colors.lightBlueAccent,
                              size: 32.0,
                            ),
                    ),
            ),
            accountName: Text(
              loggedInUser.displayName ?? "",
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
