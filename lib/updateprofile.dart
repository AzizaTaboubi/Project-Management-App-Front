import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';
import 'package:managementappfront/cards.dart';
import 'package:managementappfront/classes/user.dart';
import 'package:managementappfront/home.dart';
import 'package:managementappfront/login.dart';
import 'package:managementappfront/settings.dart';
import 'package:managementappfront/workspaces.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;

class UpdateProfileScreen extends StatefulWidget {
  const UpdateProfileScreen({Key? key}) : super(key: key);

  @override
  State<UpdateProfileScreen> createState() => _UpdateProfileScreenState();
}

class _UpdateProfileScreenState extends State<UpdateProfileScreen> {
  late String? _email;
  late String? _password;
  late String? _fullname;
  User? currentUser;
  late File imageFile = File('');
  late File _image;

  TextEditingController _emailController = TextEditingController();
  TextEditingController _passwordController = TextEditingController();
  TextEditingController _fullnameController = TextEditingController();

  final String _baseUrl = constants.constants.BaseUrl;
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();

  Future<void> _getImage() async {
    final ImagePicker _picker = ImagePicker();
    final XFile? pickedImage =
    await _picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        imageFile = File(pickedImage.path);
        _image = imageFile;
      });
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

  @override
  void initState() {
    super.initState();
    getUserData();
    _emailController.text = currentUser?.email ?? '';
    _fullnameController.text = currentUser?.fullname ?? '';
    _passwordController.text = currentUser?.password ?? '';
  }

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _fullnameController.dispose();
    super.dispose();
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

  Future<void> updateUserProfile() async {
    if (_keyForm.currentState!.validate()) {
      _keyForm.currentState!.save();
      try {
        final Uri url = Uri.parse("$_baseUrl/user/update");
        final http.Response response = await http.post(
          url,
          body: {
            'email': _email,
            'fullname': _fullname,
            'password': _password,
          },
        );

        if (response.statusCode == 200) {
          final data = json.decode(response.body);
          // Handle the response data if needed
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("Profile updated Successfuly!"),
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
          print(data);
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
          print('Failed to update profile');
        }
      } catch (error) {
        // Handle network or any other error
        print('An error occurred: $error');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: Colors.white,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          backgroundColor: Color.fromARGB(255, 244, 67, 54),
          title: Text(
            'Edit Profile',
            style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w500,
                letterSpacing: 1,
                color: Colors.white),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: const EdgeInsets.all(20),
            child: Column(
              children: [
                // -- IMAGE with ICON
                Stack(
                  children: [
                    SizedBox(
                      width: 120,
                      height: 120,
                      child: ClipRRect(
                          borderRadius: BorderRadius.circular(100),
                          child:
                          Image(image: NetworkImage(currentUser!.image))),
                    ),
                    Positioned(
                      bottom: 0,
                      right: 0,
                      child: GestureDetector(
                        onTap: () {
                          _getImage();
                        },
                        child: Container(
                          width: 35,
                          height: 35,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(100),
                            color: Colors.red,
                          ),
                          child: const Icon(
                            LineAwesomeIcons.alternate_pencil,
                            color: Colors.black,
                            size: 20,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 50),

                // -- Form Fields
                Form(
                  key: _keyForm,
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _fullnameController,
                        decoration: InputDecoration(
                            label: Text(currentUser!.fullname),
                            prefixIcon: Icon(LineAwesomeIcons.user)),
                        onSaved: (String? value) {
                          _fullname = value;
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Le nom ne doit pas etre vide";
                          } else if (value.length < 5) {
                            return "Le nom doit avoir au moins 5 caractères";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 20),
                      TextFormField(
                        enabled: false,
                        controller: _emailController,
                        decoration: InputDecoration(
                            label: Text(currentUser!.email),
                            prefixIcon: Icon(LineAwesomeIcons.envelope_1)),
                        onSaved: (String? value) {
                          _email = value;
                        },
                      ),
                      const SizedBox(height: 20),

                      TextFormField(
                        controller: _passwordController,
                        obscureText: true,
                        decoration: InputDecoration(
                          label: Text('Password'),
                          prefixIcon: const Icon(Icons.fingerprint),
                          suffixIcon: IconButton(
                              icon: const Icon(LineAwesomeIcons.eye_slash),
                              onPressed: () {}),
                        ),
                        onSaved: (String? value) {
                          _password = value;
                        },
                        validator: (String? value) {
                          if (value == null || value.isEmpty) {
                            return "Le mot de passe ne doit pas etre vide";
                          } else if (value.length < 5) {
                            return "Le mot de passe doit avoir au moins 5 caractères";
                          } else {
                            return null;
                          }
                        },
                      ),
                      const SizedBox(height: 40),

                      // -- Form Submit Button
                      SizedBox(
                        width: double.infinity,
                        child: ElevatedButton(
                          onPressed: () async {
                            updateUserProfile();
                          },
                          style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.grey.shade100,
                              side: BorderSide.none,
                              shape: const StadiumBorder()),
                          child: const Text('Edit',
                              style: TextStyle(color: Colors.black)),
                        ),
                      ),
                      const SizedBox(height: 40),

                      // -- Created Date and Delete Button
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text.rich(
                            TextSpan(
                              text: 'Joined: ',
                              style: TextStyle(
                                  fontSize: 12, color: Colors.red.shade400),
                              children: [
                                TextSpan(
                                    text: currentUser!.createdAt,
                                    style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 11))
                              ],
                            ),
                          ),
                          ElevatedButton(
                            onPressed: () {},
                            style: ElevatedButton.styleFrom(
                                backgroundColor:
                                Colors.redAccent.withOpacity(0.1),
                                elevation: 0,
                                foregroundColor: Colors.red,
                                shape: const StadiumBorder(),
                                side: BorderSide.none),
                            child: const Text('Delete'),
                          ),
                        ],
                      )
                    ],
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
