import 'package:extended_image/extended_image.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/models/custom_user.dart';
import 'package:flutter/material.dart';

class ProfileDetails extends StatefulWidget {
  final CustomUser selectedUser;

  ProfileDetails({@required this.selectedUser});

  @override
  _ProfileDetailsState createState() => _ProfileDetailsState();
}

class _ProfileDetailsState extends State<ProfileDetails> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            floating: true,
            pinned: true,
            expandedHeight: 250.0,
            flexibleSpace: FlexibleSpaceBar(
                title: Text(widget.selectedUser.displayName),
                background: Hero(
                  tag: 'profile_pic',
                  child: widget.selectedUser.photoUrl != null
                      ? ExtendedImage.network(widget.selectedUser.photoUrl,
                          fit: BoxFit.cover, cache: true)
                      : Image.asset(
                          'images/profile.jpg',
                          fit: BoxFit.cover,
                        ),
                )),
            actions: FirebaseAuth.instance.currentUser.uid ==
                    widget.selectedUser.uid
                ? [
                    IconButton(
                      icon: Icon(Icons.add_a_photo_outlined),
                      onPressed: () {},
                    ),
                    IconButton(icon: Icon(Icons.more_vert), onPressed: () {}),
                  ]
                : [
                    IconButton(
                      icon: Icon(Icons.more_vert),
                      onPressed: () {},
                    ),
                  ],
          ),
          SliverPadding(
            padding: EdgeInsets.symmetric(vertical: 20.0, horizontal: 10.0),
            sliver: SliverToBoxAdapter(
              child: Text('Shared Contents'),
            ),
          ),
          SliverGrid(
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount:
                    MediaQuery.of(context).orientation == Orientation.portrait
                        ? 2
                        : 3,
                crossAxisSpacing: 10.0),
            delegate: SliverChildBuilderDelegate(
              (context, index) {
                List<MaterialColor> colors = [
                  Colors.lightBlue,
                  Colors.purple,
                  Colors.deepOrange,
                  Colors.brown
                ];
                List<Widget> children = [
                  Text('Images'),
                  Text('Videos'),
                  Text('Files'),
                  Text('Links')
                ];
                return Padding(
                  padding: const EdgeInsets.only(bottom: 10.0),
                  child: Container(
                    color: colors[index % 4],
                    alignment: Alignment.center,
                    child: children[index % 4],
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}
