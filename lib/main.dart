import 'package:firebase_core/firebase_core.dart';
import 'package:flash_chat/components/data_providers.dart';
import 'package:flash_chat/screens/chat_screen.dart';
import 'package:flutter/material.dart';
import 'package:flash_chat/screens/home_screen.dart';
import 'package:flash_chat/screens/login_screen.dart';
import 'package:flash_chat/screens/registration_screen.dart';
import 'package:flash_chat/screens/welcome_screen.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  SystemChrome.setPreferredOrientations(
      [DeviceOrientation.portraitDown, DeviceOrientation.portraitUp]);
  SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(statusBarColor: Colors.lightBlue));
  await Firebase.initializeApp();
  runApp(FlashChat());
}

class FlashChat extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: auth.currentUser == null ? HomeScreen.id : WelcomeScreen.id,
      routes: {
        WelcomeScreen.id: (context) => WelcomeScreen(),
        LoginScreen.id: (context) => LoginScreen(),
        RegistrationScreen.id: (context) => RegistrationScreen(),
        ChatScreen.id: (context) => Provider<LoggedInUserData>(
            create: (ctx) => LoggedInUserData(), child: ChatScreen()),
        HomeScreen.id: (context) =>
            Provider(create: (ctx) => LoggedInUserData(), child: HomeScreen()),
      },
    );
  }
}
