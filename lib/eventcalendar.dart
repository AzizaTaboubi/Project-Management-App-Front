import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_event_calendar/flutter_event_calendar.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:managementappfront/classes/events.dart';
import 'package:managementappfront/classes/user.dart';
import 'package:managementappfront/eventManager.dart';
import 'package:managementappfront/profile.dart';
import 'package:managementappfront/settings.dart';
import 'package:managementappfront/workspaces.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;
import 'cards.dart';
import 'home.dart';
import 'login.dart';

import 'package:url_launcher/url_launcher.dart';

class Calendar extends StatefulWidget {
  const Calendar({super.key});

  @override
  State<Calendar> createState() => _CalendarState();
}

class _CalendarState extends State<Calendar> {
  final String _baseUrl = constants.constants.BaseUrl;
  User? currentUser;
  final Map<DateTime, List<Event>> _events = {};
  

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
      fetchEvents(); // Call fetchEvents after fetching user data
    } catch (error) {
      print('Error fetching user data: $error');
    }
  }

  void fetchEvents() async {
    try {
      if (currentUser == null) {
        print('Error fetching events: User data is not available');
        return;
      }
      final Uri url = Uri.parse("$_baseUrl/meet/meet/user/${currentUser!.id}");
      final http.Response response = await http.get(url);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        if (data != null) {
          final meetsData = data['Meets'];

          List<Meet> meets = [];

          for (var meetData in meetsData) {
            Meet meet = Meet.fromJson(meetData);
            meets.add(meet);
          }

          for (var meet in meets) {
            final meetDate = meet.Date;
            final formattedDate =
                DateTime(meetDate.year, meetDate.month, meetDate.day);
            setState(() {
              // Update the UI with the fetched events
              _events[formattedDate] ??= [];
              _events[formattedDate]!.add(
                Event(
                  child: GestureDetector(
                    onTap: () {
                      launch(meet.Link); // Open the link when tapped
                    },
                    child: Column(
                      children: [
                        Text(meet.Title),
                        SizedBox(
                          height: 8,
                        ),
                        Text(
                        meet.Link,
                        style: TextStyle(
                          color: Colors.blue, // Set the text color as blue to indicate a hyperlink
                          decoration: TextDecoration.underline, // Add underline decoration
                        ),
                      ),
                      ]
                    ),
                  ),
                  dateTime: CalendarDateTime(
                    year: meetDate.year,
                    month: meetDate.month,
                    day: meetDate.day,
                    calendarType: CalendarType.GREGORIAN,
                  ),
                ),
              );
            });

          }


        } else {
          print('Error fetching events: Response data is null');
        }
      } else {
        print('Error fetching events: ${response.statusCode}');
      }
    } catch (error) {
      print('Error fetching events: $error');
    }
  }

  @override
  Widget build(BuildContext context) {

    // Create a List<Event> from _events
    final eventList = _events.entries
        .map((entry) => entry.value.map((event) => event as Event).toList())
        .expand((events) => events)
        .toList();
    return WillPopScope(
      onWillPop: () async {
        // Disable the back button press
        return false;
      },
      child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
          ),
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
                    'Events',
                    style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w500,
                        letterSpacing: 1,
                        color: Colors.black87),
                  ),
                  SizedBox(
                    width: 108,
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
                            image: AssetImage('assets/login.jpg'),
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
              child: Column(
                children: [
                  SizedBox(
                    height: 30,
                  ),
                  EventCalendar(
                    calendarType: CalendarType.GREGORIAN,
                    calendarLanguage: 'en',
                    dayOptions: DayOptions(
                      selectedBackgroundColor: Colors.red.shade300,
                    ),
                    events: eventList,
                  ),
                ],
              ),
            ),
          )),
    );
  }
}
