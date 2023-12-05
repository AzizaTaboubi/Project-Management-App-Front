import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:managementappfront/cards.dart';
import 'package:managementappfront/classes/user.dart';
import 'package:managementappfront/eventcalendar.dart';
import 'package:managementappfront/home.dart';
import 'package:managementappfront/login.dart';
import 'package:managementappfront/profile.dart';
import 'package:managementappfront/workspaces.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;
import 'package:supercharged/supercharged.dart';

class eventManager extends StatefulWidget {
  const eventManager({super.key});

  @override
  State<eventManager> createState() => _eventManagerState();
}

class _eventManagerState extends State<eventManager> {
  late String? _title;
  late String? _year;
  late String? _month;
  late String? _day;
  late String? _link;
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  final String _baseUrl = constants.constants.BaseUrl;
  User? currentUser;

  Future<User> fetchUser(String? token) async {
    final token = await getToken();
    if (token != null) {
      final url = Uri.parse('$_baseUrl/user/userget');
      final response = await http.post(
        url,
        headers: {'Authorization': 'Bearer $token'},
      );

      if (response.statusCode == 200) {
        final jsonResponse = json.decode(response.body);
        final user = User.fromJson(jsonResponse['user']);
        return user;
      } else {
        throw Exception('Failed to fetch user');
      }
    } else {
      throw Exception('Token not found');
    }
  }

  Future<String?> getToken() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString('token');
  }

  @override
  void initState() {
    super.initState();
    getUserData();
  }

  void getUserData() async {
    try {
      final token = await getToken();
      final user = await fetchUser(token);
      setState(() {
        currentUser = user;
      });
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  Future<void> addMeet() async {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      try {
        final Uri url = Uri.parse("$_baseUrl/meet/meet");
        final http.Response response = await http.post(
          url,
          body: {
            'Day': _day,
            'Month': _month,
            'Year': _year,
            'Link': _link,
            'Description': _title,
            'User': currentUser!.id,
          },
        );
        if (response.statusCode == 200) {
          // Meet added successfully
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("Meet Added Successfully!"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, "/calendar");
                    },
                  ),
                ],
              );
            },
          );
          print('Meet added');
        } else {
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Error"),
                content: const Text("An error occurred. Please try again!"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ],
              );
            },
          );
          // Error adding meet
          print('Error adding meet: ${response.statusCode}');
        }
      } catch (e) {
        // Error connecting to the server
        print('Error connecting to the server: $e');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        // Disable the back button press
        return false;
      },
      child: Container(
          decoration: BoxDecoration(color: Colors.white),
          child: Scaffold(
            backgroundColor: Colors.white,
            drawer: Drawer(
              backgroundColor: Colors.white,
              child: ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/espritlogo.png',
                        width: 90,
                        height: 90,
                      ),
                      SizedBox(
                        width: 5,
                      ),
                      Text(
                        'Esprit\'s shelf',
                        style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.w600,
                            letterSpacing: 1,
                            color: Colors.black),
                      )
                    ],
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.home,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Boards',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Home(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.people_carry,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Workspaces',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => Workspaces(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.clipboard,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Cards',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => cards(),
                        ),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.calendar,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Calendar',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => Calendar()),
                      );
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.facebook_messenger,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Chats',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black),
                    ),
                    onTap: () {
                      // Update the state of the app.
                      // ...
                      Navigator.pop(context);
                    },
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.calendar_with_day_focus,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Event Manager',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.black),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => eventManager()),
                      );
                    },
                  ),
                  SizedBox(
                    height: 170,
                  ),
                  ListTile(
                    leading: Icon(
                      LineAwesomeIcons.alternate_sign_out,
                      color: Colors.black,
                    ),
                    title: const Text(
                      'Logout',
                      style: TextStyle(
                          fontSize: 17,
                          fontWeight: FontWeight.w500,
                          letterSpacing: 1,
                          color: Colors.red),
                    ),
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MyLogin(),
                        ),
                      );
                    },
                  ),
                ],
              ),
            ),
            appBar: AppBar(
              backgroundColor: Colors.white60,
              title: Row(
                children: [
                  Text(
                    'Event Manager',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Colors.black87),
                  ),
                  SizedBox(
                    width: 27,
                  ),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(LineAwesomeIcons.search),
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 2),
                  IconButton(
                    onPressed: () {},
                    icon: Icon(LineAwesomeIcons.bell_1),
                    color: Colors.black87,
                  ),
                  const SizedBox(width: 2),
      
                  InkWell(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfileScreen(),
                        ),
                      );
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(shape: BoxShape.circle),
                      child: Ink(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          image: DecorationImage(
                            image: NetworkImage(currentUser!.image),
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                    ),
                  )
                  //CircleAvatar(backgroundImage: AssetImage('assets/login.jpg'), radius: 15,)
                ],
              ),
            ),
            body: SingleChildScrollView(
              child: Container(
                  margin: EdgeInsets.all(20),
                  child: Form(
                    key: _keyForm,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 40,
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: false,
                              hintText: "Event Title",
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              )),
                          onSaved: (String? value) {
                            _title = value;
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Le titre est obligatoire";
                            } else if (value.length < 3) {
                              return "Le titre ne doit pas avoir moins que 3 caractères";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: false,
                              hintText: "Day",
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              )),
                          onSaved: (String? value) {
                            _day = value;
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Le jour est obligatoire";
                            } else if (value.toInt() == null) {
                              return "Le jour est un nombre";
                            } else if (value.toInt()! > 31) {
                              return "Le jour est entre 1 et 31";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: false,
                              hintText: "Month",
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              )),
                          onSaved: (String? value) {
                            _month = value;
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Le mois est obligatoire";
                            } else if (value.toInt() == null) {
                              return "Le mois est un nombre";
                            } else if (value.toInt()! > 12) {
                              return "Le mois est entre 1 et 12";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: false,
                              hintText: "Year",
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              )),
                          onSaved: (String? value) {
                            _year = value;
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "L'année est obligatoire";
                            } else if (value.toInt() == null) {
                              return "L'année est un nombre";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 13,
                        ),
                        TextFormField(
                          style: TextStyle(
                            color: Colors.black,
                          ),
                          decoration: InputDecoration(
                              fillColor: Colors.transparent,
                              filled: false,
                              hintText: "Link",
                              border: UnderlineInputBorder(
                                borderRadius: BorderRadius.zero,
                              )),
                          onSaved: (String? value) {
                            _link = value;
                          },
                          validator: (String? value) {
                            if (value == null || value.isEmpty) {
                              return "Le lien est obligatoire";
                            } else if (value.length < 9) {
                              return "Le lien ne doit pas avoir moins que 9 caractères";
                            } else {
                              return null;
                            }
                          },
                        ),
                        SizedBox(
                          height: 23,
                        ),
                        ElevatedButton(
                          onPressed: () {
                            addMeet();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text('Add Event To Calendar',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ],
                    ),
                  )),
            ),
          )),
    );
  }
}
