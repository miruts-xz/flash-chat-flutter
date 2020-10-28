import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';

class RegistrationScreen extends StatefulWidget {
  static const String id = 'registration_screen';

  @override
  _RegistrationScreenState createState() => _RegistrationScreenState();
}

final fs = FirebaseFirestore.instance;

class _RegistrationScreenState extends State<RegistrationScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password;
  bool showSpinner = false;
  String passwordError;
  String emailError;
  String genericError = "";

  String username;

  String usernameError;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              Flexible(
                child: Hero(
                  tag: 'logo',
                  child: Container(
                    height: 200.0,
                    child: Image.asset('images/logo.png'),
                  ),
                ),
              ),
              SizedBox(
                height: 48.0,
              ),
              TextField(
                keyboardType: TextInputType.name,
                textCapitalization: TextCapitalization.words,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  username = value;
                  if (usernameError != null) {
                    setState(() {
                      usernameError = null;
                    });
                  }
                },
                decoration: kInputFieldDecoration.copyWith(
                  hintText: 'Enter full name',
                  errorText: usernameError,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                keyboardType: TextInputType.emailAddress,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  email = value;
                  if (emailError != null) {
                    setState(() {
                      emailError = null;
                    });
                  }
                },
                decoration: kInputFieldDecoration.copyWith(
                  hintText: 'Enter your email',
                  errorText: emailError,
                ),
              ),
              SizedBox(
                height: 8.0,
              ),
              TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                onChanged: (value) {
                  password = value;
                  if (passwordError != null) {
                    setState(() {
                      passwordError = null;
                    });
                  }
                },
                decoration: kInputFieldDecoration.copyWith(
                  errorText: passwordError,
                  hintText: 'Enter your password',
                ),
              ),
              SizedBox(
                height: 10.0,
              ),
              Text(
                genericError != null ? genericError : "",
                style: TextStyle(color: Colors.red),
                textAlign: TextAlign.center,
              ),
              SizedBox(
                height: 24.0,
              ),
              RoundedButton(
                text: 'Register',
                onPressed: () async {
                  _clearField();
                  setState(() {
                    showSpinner = true;
                  });
                  try {
                    if (username == null || !(username.length > 3)) {
                      throw ArgumentError('invalid-username');
                    }

                    final newUser = await _auth.createUserWithEmailAndPassword(
                        email: email.trim(), password: password);
                    if (newUser != null) {
                      newUser.user.updateProfile(displayName: username.trim());
                      fs.collection('users').doc('${newUser.user.uid}').set(
                          {'displayName': username.trim(), 'email': email, 'uid': newUser.user.uid});
                      Navigator.pushNamed(context, HomeScreen.id);
                    }
                    setState(() {
                      showSpinner = false;
                    });
                  } on ArgumentError {
                    setState(() {
                      if (username == null) {
                        usernameError = "Full name is required*";
                      } else {
                        usernameError =
                            "A minimum 4 characters username required";
                      }
                    });
                  } on FirebaseAuthException catch (e) {
                    print(e.code);
                    switch (e.code) {
                      case 'email-already-in-use':
                        setState(() {
                          emailError = "Email already in use";
                        });
                        break;
                      case 'invalid-email':
                        setState(() {
                          if (email == "") {
                            emailError = "Email is required*";
                          } else {
                            emailError = "Invalid email";
                          }
                        });
                        break;
                      case 'weak-password':
                        setState(() {
                          if (password == "") {
                            passwordError = "password is required*";
                          } else {
                            passwordError =
                                "A minimum 6 characters password required";
                          }
                        });
                        break;
                      case 'network-request-failed':
                        setState(() {
                          genericError = "No internet connection";
                        });
                        break;
                      default:
                        {
                          setState(() {
                            if (email == null) {
                              emailError = "Email is required*";
                            } else if (password == null) {
                              passwordError = "Password is required*";
                            } else {
                              genericError = "Error was encountered";
                            }
                          });
                        }
                    }
                  } catch (e) {
                    setState(() {
                      if (email == null) {
                        emailError = "Email is required*";
                      } else if (password == null) {
                        passwordError = "Password is required*";
                      } else {
                        genericError = "Error was encountered";
                      }
                    });
                  } finally {
                    setState(() {
                      showSpinner = false;
                    });
                  }
                },
                color: Colors.blueAccent,
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _clearField() {
    setState(() {
      genericError = null;
    });
  }
}
