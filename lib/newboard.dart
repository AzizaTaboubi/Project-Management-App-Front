import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import 'classes/board.dart';
import 'classes/user.dart';
import 'package:managementappfront/constants/constants.dart' as constants;

class newBoard extends StatefulWidget {
  final Board? board;

  newBoard({Key? key, this.board}) : super(key: key);

  @override
  State<newBoard> createState() => _newBoardState();
}

class _newBoardState extends State<newBoard> {
  final String _baseUrl = constants.constants.BaseUrl;
  List<String> workspaceNames = [];
  late Future<bool> fetchedWorkspaces;
  String dropdownValue = '';
  User? currentUser;
  TextEditingController boardNameController = TextEditingController();
  TextEditingController coworkerController = TextEditingController();

  Future<void> editBoardInDatabase() async {
    try {
      final token = await getToken();
      final List<String> userEmails = List<String>.from(widget.board!.Users);
      print("userEmails");
      print(userEmails);
      final body = {
        "Name": boardNameController.text,
        "Workspace": dropdownValue,
        "Users": userEmails,
      };
      final url = Uri.parse('http://10.0.2.2:9095/board/boards/update/${widget.board?.id}');
      final response = await http.put(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        // Error updating board
        throw Exception('Failed to update board');
      }
    } catch (error) {

    }
  }

  Future<void> addBoardToDatabase() async {
    try {
      final token = await getToken();
      final body = {
        "Name": boardNameController.text,
        "Workspace": dropdownValue,
        "Users":
        coworkerController.text.split(',').map((e) => e.trim()).toList(),
      };
      final url = Uri.parse('http://10.0.2.2:9095/board/boards');
      final response = await http.post(
        url,
        headers: {
          'Authorization': 'Bearer $token',
          'Content-Type': 'application/json'
        },
        body: jsonEncode(body),
      );

      if (response.statusCode == 200) {
        // Board added successfully
        print('Board added successfully');
        Navigator.pushReplacementNamed(context, "/home");
      } else {
        // Error adding board
        throw Exception('Failed to add board');
      }
    } catch (error) {
      print('Error adding board: $error');
    }
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

  Future<bool> fetchWorkspaces(String userid) async {
    final response = await http.get(
      Uri.parse('http://10.0.2.2:9095/workspace/workspaces/user/$userid'),
    );

    if (response.statusCode == 200) {
      Map<String, dynamic> responseData = jsonDecode(response.body);
      if (responseData.containsKey('Workspaces')) {
        List<dynamic> workspaceData = responseData['Workspaces'];
        workspaceNames =
            workspaceData.map<String>((element) => element["Name"]).toList();
        dropdownValue = workspaceNames.first;
        return true;
      }
    }

    throw Exception('Failed to fetch workspaces');
  }

  @override
  void initState() {
    super.initState();
    getUserData().then((_) {
      fetchedWorkspaces = fetchWorkspaces(currentUser!.id);
    });
    if (widget.board != null) {
      boardNameController.text = widget.board!.Name;
      coworkerController.text = widget.board!.Users.join(", ");
      dropdownValue = widget.board!.Workspace;
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isEditing = widget.board != null;
    return Container(
      decoration: BoxDecoration(color: Colors.white),
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 244, 67, 54),
          title: Row(
            children: [
              SizedBox(
                width: 15,
              ),
              Text(
                'New Boards',
                style: TextStyle(
                    fontSize: 20,
                    fontWeight: FontWeight.w500,
                    letterSpacing: 1,
                    color: Colors.white),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            margin: EdgeInsets.all(20),
            child: Column(
              children: [
                const SizedBox(
                  height: 20,
                ),
                TextField(
                  controller: boardNameController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    fillColor: Colors.transparent,
                    filled: false,
                    hintText: "Board name",
                    border:
                    UnderlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                SizedBox(
                  width: 370,
                  height: 60,
                  child: FutureBuilder<bool>(
                    future: fetchedWorkspaces,
                    builder:
                        (BuildContext context, AsyncSnapshot<bool> snapshot) {
                      if (snapshot.connectionState == ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (snapshot.hasError) {
                        return Text('Error: ${snapshot.error}');
                      } else {
                        return DropdownButton(
                          value: dropdownValue,
                          onChanged: (String? value) {
                            setState(() {
                              dropdownValue = value!;
                            });
                          },
                          underline: Container(
                            height: 1,
                            color: Colors.grey,
                          ),
                          items: workspaceNames
                              .map<DropdownMenuItem<String>>((String value) {
                            return DropdownMenuItem<String>(
                              value: value,
                              child: Text(value),
                            );
                          }).toList(),
                        );
                      }
                    },
                  ),
                ),
                TextField(
                  controller: coworkerController,
                  style: const TextStyle(
                    color: Colors.black,
                  ),
                  decoration: const InputDecoration(
                    fillColor: Colors.transparent,
                    filled: false,
                    hintText: "Coworkers",
                    border:
                    UnderlineInputBorder(borderRadius: BorderRadius.zero),
                  ),
                ),
                SizedBox(
                  height: 40,
                ),
                ElevatedButton(
                  onPressed: () {
                    isEditing ? editBoardInDatabase() : addBoardToDatabase();
                  },
                  style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.grey.shade100,
                      side: BorderSide.none,
                      shape: const StadiumBorder()),
                  child: Text(
                    isEditing ? 'Edit Board' : 'Add Board',
                    style: TextStyle(color: Colors.black),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}