import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:managementappfront/cards.dart';
import 'package:managementappfront/classes/user.dart';
import 'package:managementappfront/home.dart';
import 'package:managementappfront/login.dart';
import 'package:managementappfront/profilewidget.dart';
import 'package:managementappfront/settings.dart';
import 'package:managementappfront/updateprofile.dart';
import 'package:managementappfront/workspaces.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:jwt_decoder/jwt_decoder.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({Key? key}) : super(key: key);

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
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

  Future<void> logout() async {
    try {
      final response = await http.post(
        Uri.parse('$_baseUrl/user/logout'),
        // Add any necessary headers or authentication tokens
      );

      if (response.statusCode == 200) {
        // Logout successful, handle the response or perform any necessary actions
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => MyLogin(),
          ),
        );
        print('Logged out successfully');
      } else {
        // Logout failed, handle the response or display an error message
        print('Logout failed: ${response.body}');
      }
    } catch (error) {
      // An error occurred while sending the request
      print('Error logging out: $error');
    }
  }

  @override
  Widget build(BuildContext context) {
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Container(
      color: Colors.white,
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
                  // Update the state of the app.
                  // ...
                  Navigator.pop(context);
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
                  LineAwesomeIcons.cog,
                  color: Colors.black,
                ),
                title: const Text(
                  'Settings',
                  style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w500,
                      letterSpacing: 1,
                      color: Colors.black),
                ),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => SettingsPage1()),
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
                  logout();
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
                'Profile',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.black87),
              ),
              SizedBox(
                width: 103,
              ),
              IconButton(
                onPressed: () {},
                icon: Icon(LineAwesomeIcons.search),
                color: Colors.black87,
              ),
              const SizedBox(width: 1.5),
              IconButton(
                onPressed: () {},
                icon: Icon(LineAwesomeIcons.bell_1),
                color: Colors.black87,
              ),
              const SizedBox(width: 2.5),
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
                    ),
                    child: Image.network(
                      currentUser!.image,
                      fit: BoxFit.cover,
                      errorBuilder: (context, error, stackTrace) {
                        return FadeInImage.assetNetwork(
                          placeholder: 'assets/profilepic.jpeg',
                          image: currentUser!.image,
                          fit: BoxFit.cover,
                        );
                      },
                    ),
                  ),
                ),
              )
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                /// -- IMAGE
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child: Image(
                            image: NetworkImage(currentUser!.image),
                          )),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: Container(
                        width: 35,
                        height: 35,
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.red),
                        child: const Icon(
                          LineAwesomeIcons.alternate_pencil,
                          color: Colors.black,
                          size: 20,
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 15),
                Text(
                  currentUser!.fullname,
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  currentUser!.email,
                  style: TextStyle(
                    fontSize: 13,
                    color: Colors.grey,
                  ),
                ),
                const SizedBox(height: 70),
                const Divider(),
                const SizedBox(height: 10),

                /// -- MENU
                ProfileMenuWidget(
                    title: "Settings",
                    icon: LineAwesomeIcons.cog,
                    onPress: () {
                      Navigator.pushNamed(context, '/settings');
                    }),
                // ProfileMenuWidget(title: "Billing Details", icon: LineAwesomeIcons.wallet, onPress: () {}),
                ProfileMenuWidget(
                    title: "User Management",
                    icon: LineAwesomeIcons.user_check,
                    onPress: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => UpdateProfileScreen(),
                        ),
                      );
                    }),
                const Divider(),
                const SizedBox(height: 10),
                ProfileMenuWidget(
                    title: "Information",
                    icon: LineAwesomeIcons.info,
                    onPress: () {}),
                ProfileMenuWidget(
                    title: "Logout",
                    icon: LineAwesomeIcons.alternate_sign_out,
                    textColor: Colors.red,
                    endIcon: false,
                    onPress: () {}),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
