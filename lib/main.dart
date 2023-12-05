import 'package:flutter/material.dart';
import 'package:managementappfront/cards.dart';
import 'package:managementappfront/classes/calendar.dart';
import 'package:managementappfront/eventManager.dart';
import 'package:managementappfront/eventcalendar.dart';
import 'package:managementappfront/home.dart';
import 'package:managementappfront/newboard.dart';
import 'package:managementappfront/newcard.dart';
import 'package:managementappfront/newworkspace.dart';
import 'package:managementappfront/pin.dart';
import 'package:managementappfront/profile.dart';
import 'package:managementappfront/register.dart';
import 'package:managementappfront/reset.dart';
import 'package:managementappfront/resetpwd.dart';
import 'package:managementappfront/settings.dart';
import 'package:managementappfront/updateprofile.dart';
import 'package:managementappfront/workspaces.dart';
import 'login.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  Future<bool> checkLoginStatus() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    String? token = prefs.getString('token');
    return token != null && token.isNotEmpty;
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Esprit\'s Shelf App',
      theme: ThemeData(
        primarySwatch: Colors.red,
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
      ),
      home: MyLogin(),  //MyLogin(),
      routes: {
        '/register': (context) => MyRegister(),
        '/home': (context) => Home(),
        '/newCard': (context) => newCard(),
        '/newboard': (context) => newBoard(),
        '/workspaces': (context) => Workspaces(),
        '/cards': (context) => cards(),
        '/forgot': (context) => resetPassword(),
        '/pin': (context) => PinCodeVerificationScreen(email: '',),
        '/calendar': (context) => Calendar(),
        '/eventmanager': (context) => eventManager(),
        '/settings': (context) => SettingsPage1(),
        '/pwdchange': (context) => resetPwd(email: '', otp: '',),
      },
    );
  }
}