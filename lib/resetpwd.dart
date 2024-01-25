import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;

class resetPwd extends StatefulWidget {
  final String email;
  final String otp;

  resetPwd({required this.email, required this.otp});

  @override
  _resetPwdState createState() => _resetPwdState();
}

class _resetPwdState extends State<resetPwd> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();

  final String _baseUrl = constants.constants.BaseUrl;
  late String? _password;

  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();

  bool passwordsMatch = false;

  void checkPasswordMatch() {
    String newPassword = newPasswordController.text;
    String confirmPassword = confirmPasswordController.text;

    if (newPassword == confirmPassword) {
      resetPassword();
    } else {
      // Show an alert dialog indicating that the passwords don't match
      showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
                title: Text('Passwords Don\'t Match'),
                content: Text('Please make sure the passwords match.'),
                actions: <Widget>[
                  TextButton(
                    child: Text('OK'),
                    onPressed: () {
                      Navigator.of(context).pop();
                    },
                  ),
                ]);
          });
    }
  }

  Future<void> resetPassword() async {
    /*Map<String, String> data = {
      'newPass': _password!,
      'email':widget.email,
      'otp':widget.otp,
    };

    String jsonData = json.encode(data);*/
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        var url = Uri.parse("$_baseUrl/user/resetPassword");
        var body = {
          'email': widget.email,
          'newPass': _password!,
          'otp': widget.otp
        };
        var response = await http.post(url, body: body);

        // Handle the response
        if (response.statusCode == 200) {
          // Password reset was successful
          print('Password reset successful');
          showDialog(
            context: context,
            builder: (BuildContext context) {
              return AlertDialog(
                title: const Text("Success"),
                content: const Text("Your password has been reset"),
                actions: <Widget>[
                  TextButton(
                    child: const Text("OK"),
                    onPressed: () {
                      Navigator.of(context).pop();
                      Navigator.pushReplacementNamed(context, "/");
                    },
                  ),
                ],
              );
            },
          );
        } else {
          // Password reset failed
          print('Password reset failed');
          snackBar("Invalid OTP");
        }
      } catch (e) {
        // Handle any errors during the request
        print('Error: $e');
      }
    }
  }

  void snackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
        child: Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              SizedBox(
                  height: MediaQuery.of(context).size.height,
                  width: MediaQuery.of(context).size.width,
                  child: ListView(children: <Widget>[
                    const SizedBox(height: 30),
                    SizedBox(
                      height: MediaQuery.of(context).size.height / 3,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(30),
                        child: Image.asset('assets/changepwd.jpg'),
                      ),
                    ),
                    SizedBox(height: 30),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                          padding: EdgeInsets.only(top: 20),
                          child: Text(
                            'Enter your new password',
                            style: TextStyle(
                                color: Colors.black,
                                fontSize: 22.0,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ])),
              SingleChildScrollView(
                child: Container(
                  padding: EdgeInsets.only(
                    top: 380,
                    left: 35,
                    right: 35,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        SizedBox(
                          height: 50,
                        ),
                        TextFormField(
                            controller: newPasswordController,
                            style: TextStyle(color: Colors.grey.shade700),
                            obscureText: true,
                            onSaved: (String? value) {
                              _password = value;
                            },
                            decoration: InputDecoration(
                              labelText: 'Pssword',
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade700),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "le mot de passe ne doit pas etre vide";
                              }
                            }),
                        SizedBox(height: 10.0),
                        TextFormField(
                            controller: confirmPasswordController,
                            style: TextStyle(color: Colors.grey.shade700),
                            obscureText: true,
                            decoration: InputDecoration(
                              labelText: 'ConfirmPassword',
                              labelStyle:
                                  TextStyle(color: Colors.grey.shade700),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.grey.shade700,
                                ),
                              ),
                            ),
                            validator: (String? value) {
                              if (value == null || value.isEmpty) {
                                return "il faut confirmer votre mot de passe";
                              }
                            }),
                        SizedBox(
                          height: 20,
                        ),
                        Container(
                          margin: const EdgeInsets.symmetric(
                              vertical: 6.0, horizontal: 15),
                          child: ButtonTheme(
                            height: 50,
                            child: TextButton(
                              onPressed: () {
                                checkPasswordMatch();
                              },
                              child: Center(
                                child: Text(
                                  "Reset password",
                                  style: const TextStyle(
                                    color: Colors.white,
                                    fontSize: 18,
                                    fontWeight: FontWeight.w400,
                                  ),
                                ),
                              ),
                            ),
                          ),
                          decoration: BoxDecoration(
                              color: Colors.red.shade400,
                              borderRadius: BorderRadius.circular(5),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.transparent,
                                    offset: const Offset(1, -2),
                                    blurRadius: 5),
                                BoxShadow(
                                    color: Colors.transparent,
                                    offset: const Offset(-1, 2),
                                    blurRadius: 5)
                              ]),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
