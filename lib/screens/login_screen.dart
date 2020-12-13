import 'package:firebase_auth/firebase_auth.dart';
import 'package:flash_chat/components/rounded_button.dart';
import 'package:flash_chat/constants.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:flutter/cupertino.dart';
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
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: ModalProgressHUD(
        inAsyncCall: showSpinner,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Center(
            child: Form(
              key: _formKey,
              autovalidateMode: AutovalidateMode.onUserInteraction,
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
                  TextFormField(
                    keyboardType: TextInputType.emailAddress,
                    textAlign: TextAlign.center,
                    onChanged: (value) {
                      email = value;
                    },
                    validator: (value) {
                      return value == null
                          ? 'Email is required*'
                          : !value.contains('@') || !value.contains('.')
                              ? 'Email invalid '
                              : null;
                    },
                    decoration: kInputFieldDecoration.copyWith(
                        hintText: 'Enter your email', errorText: emailError),
                  ),
                  SizedBox(
                    height: 8.0,
                  ),
                  TextFormField(
                    textAlign: TextAlign.center,
                    obscureText: true,
                    validator: (value) {
                      if (value == null) {
                        return 'Password is required*';
                      } else if (value.length < 6) {
                        return 'Minimum password length 6';
                      } else {
                        return null;
                      }
                    },
                    onChanged: (value) {
                      password = value;
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
                            setState(() {
                              _clearField();
                              showSpinner = true;
                            });
                            try {
                              final userCredential =
                                  await _auth.signInWithEmailAndPassword(
                                      email: email, password: password);
                              if (userCredential != null) {
                                Navigator.pushReplacementNamed(
                                    context, HomeScreen.id);
                              }
                              setState(() {
                                showSpinner = false;
                              });
                            } on FirebaseAuthException catch (e) {
                              switch (e.code) {
                                case 'invalid-email':
                                  emailError = "Invalid email";
                                  break;
                                case 'user-disabled':
                                  genericError = "User is temporarily disabled";
                                  break;
                                case 'user-not-found':
                                  genericError =
                                      "No such account, please register";
                                  break;
                                case 'wrong-password':
                                  passwordError =
                                      "Email and/or Password is incorrect";
                                  break;
                                case 'network-request-failed':
                                  genericError = "No internet connection";
                                  break;
                                default:
                                  genericError = "Error encountered";
                              }
                              setState(() {});
                            } catch (e) {
                              setState(() {
                                genericError = "Error encountered";
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
    genericError = null;
  }

  bool _hasError() {
    return passwordError != null || emailError != null;
  }
}
