import 'dart:io';
import 'dart:ui';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart' as storage;
import 'package:flash_chat/models/custom_user.dart';
import 'package:flash_chat/components/profile_details.dart';
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
                if (loggedInUser.photoURL == null && _image != null) {
                  await _getImageGallery();
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
                } else {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ProfileDetails(
                        selectedUser: CustomUser(
                            uid: loggedInUser.uid,
                            displayName: loggedInUser.displayName,
                            photoUrl: loggedInUser.photoURL,
                            email: loggedInUser.email),
                      ),
                    ),
                  );
                }
              },
              child: photoUrl != null
                  ? ClipRRect(
                      borderRadius: BorderRadius.circular(35.0),
                      child: Container(
                        height: 70.0,
                        child: Hero(
                          tag: 'profile_pic',
                          child: ExtendedImage.network(
                            photoUrl,
                            fit: BoxFit.cover,
                            cache: true,
                          ),
                        ),
                      ),
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
              /*photoUrl != null
                  ? CircleAvatar(
                      radius: 35.0,
                      backgroundImage: ExtendedNetworkImageProvider(
                        photoUrl,
                        cache: true,
                      ),
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
                    ),*/
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
