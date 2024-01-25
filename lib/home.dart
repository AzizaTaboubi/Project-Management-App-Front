import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter/src/widgets/framework.dart';
import 'package:flutter/src/widgets/placeholder.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:managementappfront/cards.dart';
import 'package:managementappfront/classes/user.dart';
import 'package:managementappfront/eventManager.dart';
import 'package:managementappfront/eventcalendar.dart';
import 'package:managementappfront/login.dart';
import 'package:managementappfront/newboard.dart';
import 'package:managementappfront/newcard.dart';
import 'package:managementappfront/newworkspace.dart';
import 'package:managementappfront/profile.dart';
import 'package:managementappfront/settings.dart';
import 'package:managementappfront/workspaces.dart';
import 'button.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;

import 'classes/board.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  late String? _workspaceName;
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();
  final String _baseUrl = constants.constants.BaseUrl;
  User? currentUser;


  List<Board> boards = [];
  late Future<bool> fetchedBS;


  Future<bool> fetchBoards(String userId) async {
    final response = await http.get(
      Uri.parse('$_baseUrl/board/boards/user/$userId'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? responseData = jsonDecode(response.body);
      if (responseData != null && responseData.containsKey('Boards')) {
        List<dynamic> workspaceData = responseData['Boards'];
        setState(() {
          workspaceData.forEach((element) {
            List<dynamic> userData = element['Users'];
            List<String> userIds = userData.map((user) => user.toString()).toList();
            boards.add(Board(
              id: element["_id"],
              Name: element["Name"],
              Workspace: element["Workspace"],
              createdAt: DateTime.parse(element["createdAt"]),
              Users: userIds,
            ));
            print("User Fields : ");
            print(userIds);
          });
        });
        return true;
      }
    }
    throw Exception('Failed to fetch workspaces');
  }

  Future<bool> deleteBoards(String boardId) async {
    final response = await http.delete(
      Uri.parse('$_baseUrl/board/boards/$boardId'),
    );
    if (response.statusCode == 200) {
      Map<String, dynamic>? responseData = jsonDecode(response.body);
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
              builder: (BuildContext context) => super.widget));
      return true;
    }
    throw Exception('Failed to fetch workspaces');
  }
  

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
    getUserData().then((_) {
      fetchedBS = fetchBoards(currentUser!.id);
    });
  }

  Future<void> getUserData() async {
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

  Future<void> addWorkspace() async {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();

      try {
        final Uri url = Uri.parse("$_baseUrl/workspace/workspaces");

        final http.Response response = await http.post(url, body: {
          'Name': _workspaceName,
          'Owner': currentUser!.id,
        });
        if (response.statusCode == 200) {
          // Workspace added successfully
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("Workspace Added Successfully!"),
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
          print('Workspace added');
        } else {
          // Error adding workspace
          print('Error adding workspace: ${response.statusCode}');
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
                  'Boards',
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
            child: Column(
              children: [
                if (boards.isNotEmpty)
                  FutureBuilder<bool>(
                    future: fetchedBS,
                    builder: (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        // Show a loading indicator while fetching workspaces
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        // Show an error message if fetching workspaces failed
                        return Text('Error: ${snapshot.error}');
                      } else {
                        // Show the ListView when workspaces are fetched successfully
                        return ListView.builder(
                          shrinkWrap: true,
                          itemCount: boards.length,
                          itemBuilder: (BuildContext context, int index) {
                            final board = boards[index];
                            return ListTile(
                              title: Text(board.Name), // Workspace name
                              trailing: Row(
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  IconButton(
                                    icon: Icon(Icons.edit),
                                    onPressed: () {
                                      print(board.id);
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => newBoard(board: board),
                                        ),
                                      );
                                    },
                                  ),
                                  IconButton(
                                    icon: Icon(Icons.delete),
                                    onPressed: () {
                                      deleteBoards(board.id);
                                    },
                                  ),
                                ],
                              ),
                              onTap: () {
                                showDialog(
                                  context: context,
                                  builder: (BuildContext context) {
                                    return AlertDialog(
                                      title: Text(board.Name),
                                      content: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text('Workspace: ${board.Workspace}'),
                                          Text('Created At: ${board.createdAt.toString()}'),
                                          Text('Users: ${board.Users.join(", ")}'),
                                        ],
                                      ),
                                      actions: [
                                        TextButton(
                                          onPressed: () {
                                            Navigator.of(context).pop();
                                          },
                                          child: Text('Close'),
                                        ),
                                      ],
                                    );
                                  },
                                );
                              },
                            );
                          },
                        );
                      }
                    },
                  ),
                if (boards.isEmpty)
                  Text('No boards available'),
              ],
            ),
          ),
          floatingActionButton: ExpandableFab(
            distance: 112,
            children: [
              ActionButton(
                onPressed: () {
                  showModalBottomSheet<void>(
                    context: context,
                    builder: (BuildContext context) {
                      return Container(
                        height: 300,
                        color: Colors.white,
                        child: Center(
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                              const Text(
                                'Create New Workspaces',
                                style: TextStyle(
                                  fontSize: 17,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 1,
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.all(20),
                                child: Text(
                                  'Workspaces help you organize and boost your works. So you can be more productive.',
                                  style: TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w300,
                                    letterSpacing: 1,
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 45,
                                width: 310,
                                child: Form(
                                  key: _keyForm,
                                  child: TextFormField(
                                    style: TextStyle(),
                                    obscureText: false,
                                    decoration: InputDecoration(
                                        fillColor: Colors.transparent,
                                        filled: true,
                                        hintText: "Workspace name",
                                        border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(10),
                                            borderSide:
                                                BorderSide(color: Colors.red))),
                                    onSaved: (String? value) {
                                      _workspaceName = value;
                                    },
                                    validator: (String? value) {
                                      if (value == null || value.isEmpty) {
                                        return "Le nom du workspace est obligatoire";
                                      } else {
                                        return null;
                                      }
                                    },
                                  ),
                                ),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 35,
                                width: 290,
                                child: ElevatedButton(
                                    style: ElevatedButton.styleFrom(
                                        shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(30),
                                    )),
                                    child: const Text(
                                      'Create',
                                    ),
                                    onPressed: () {
                                      addWorkspace();
                                    }),
                              ),
                              SizedBox(
                                height: 15,
                              ),
                              SizedBox(
                                height: 35,
                                width: 290,
                                child: ElevatedButton(
                                  style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(30),
                                      )),
                                  child: const Text(
                                    'Cancel',
                                    style: TextStyle(color: Colors.black38),
                                  ),
                                  onPressed: () => Navigator.pop(context),
                                ),
                              )
                            ],
                          ),
                        ),
                      );
                    },
                  );
                },
                icon: const Icon(LineAwesomeIcons.people_carry),
                text: Text('Workspaces'),
              ),
              ActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => newCard()),
                  );
                },
                icon: const Icon(LineAwesomeIcons.clipboard),
                text: Text('Cards'),
              ),
              ActionButton(
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(builder: (context) => newBoard()),
                  );
                },
                icon: const Icon(LineAwesomeIcons.home),
                text: Text('Boards'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
