import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:flutter/material.dart';
import 'package:modal_progress_hud/modal_progress_hud.dart';


class LoginScreen extends StatefulWidget {
  static const String id = 'login_screen';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _auth = FirebaseAuth.instance;
  String email, password;
  bool showSpinner = false;
  String emailError;
  String passwordError;
  String genericError;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: SingleChildScrollView(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: <Widget>[
                  Hero(
                    tag: 'logo',
                    child: Container(
                      height: 200.0,
                      child: Image.asset('images/logo.png'),
                    ),
                  ),
                  SizedBox(
                    height: 48.0,
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
                        hintText: 'Enter your email', errorText: emailError),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    onChanged: (value) {
                      password = value;
                      if (passwordError != null) {
                        setState(() {
                          passwordError = null;
                        });
                      }
                    },
                    decoration: kInputFieldDecoration.copyWith(
                      hintText: "Enter your password",
                      errorText: passwordError,
                    ),
                  ),
                  SizedBox(
                    height: 10.0,
                  ),
                  Text(
                    genericError != null ? genericError : "",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(
                    height: 24.0,
                  ),
                  RoundedButton(
                    text: 'Log In',
                    onPressed: () async {
                      _clearField();
                      setState(() {
                        showSpinner = true;
                      });
                      try {
                        final userCredential =
                            await _auth.signInWithEmailAndPassword(
                                email: email, password: password);
                        if (userCredential != null) {
                          Navigator.pushNamed(context, HomeScreen.id);
                        }
                        setState(() {
                          showSpinner = false;
                        });
                      } on FirebaseAuthException catch (e) {
                        print(e.code);
                        switch (e.code) {
                          case 'invalid-email':
                            setState(() {
                              emailError = "Invalid email";
                            });
                            break;
                          case 'user-disabled':
                            setState(() {
                              genericError = "User is temporarily disabled";
                            });
                            break;
                          case 'user-not-found':
                            setState(() {
                              genericError = "No such account, please register";
                            });
                            break;
                          case 'wrong-password':
                            setState(() {
                              passwordError =
                                  "Email and/or Password is incorrect";
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
                                }
                                if (password == null) {
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
                    color: Colors.lightBlueAccent,
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  void _clearField() {
    setState(() {
      genericError = null;
      passwordError = null;
      emailError = null;
    });
  }
}
