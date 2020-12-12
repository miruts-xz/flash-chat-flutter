import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class LoggedInUserData extends ChangeNotifier {
  final loggedInUser = FirebaseAuth.instance.currentUser;
}
