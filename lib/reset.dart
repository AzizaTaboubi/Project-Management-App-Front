import 'dart:convert';

import 'package:email_validator/email_validator.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:managementappfront/constants/constants.dart' as constants;
import 'package:managementappfront/pin.dart';

class resetPassword extends StatefulWidget {
  const resetPassword({Key? key}) : super(key: key);

  @override
  _resetPasswordState createState() => _resetPasswordState();
}

class _resetPasswordState extends State<resetPassword> {

   late String? _email;
  final String _baseUrl =constants.constants.BaseUrl;
  final GlobalKey<FormState> _keyForm = GlobalKey<FormState>();


   Future<void> forgotPassword() async {
 if (_keyForm.currentState!.validate()) {
    _keyForm.currentState!.save();
    try {
      final http.Response response = await http.post(Uri.parse("$_baseUrl/user/forgotPassword"),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'email': _email!}),
        
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
          Navigator.push(
              context,
              MaterialPageRoute(builder: (context) =>  PinCodeVerificationScreen(email: '$_email',)),
               );
        // Handle the success response
        print(data);
        // Display a success message or perform any other actions
      } else {
        final error = jsonDecode(response.body);
        // Handle the error response
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
        print(error);
        }
    } catch (error) {
     print(error);
     }}
  }
  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Container(
       
        child: Form(
          key: _keyForm,
          child: Scaffold(
            backgroundColor: Colors.white,
            body: SingleChildScrollView(
              child: Stack(
                children: [
                  SizedBox(
              height: MediaQuery.of(context).size.height,
              width: MediaQuery.of(context).size.width,
              child: ListView(
                children: <Widget>[
                  const SizedBox(height: 20),
                  SizedBox(
                    height: MediaQuery.of(context).size.height / 3,
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(30),
                      child: Image.asset('assets/pin.jpg'),
                    ),
                  ),
                  SizedBox(height:30),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Container(
                        padding: EdgeInsets.only( top: 0.5),
                        child: Text(
                          'FORGOT YOUR PASSWORD?',
                          style: TextStyle(
                            color: Colors.black,
                            fontSize: 22.0,
                            fontWeight: FontWeight.bold
                          ),
                        ),
                      ),
                    ],
                  ),])),
                  SingleChildScrollView(
                    child: Container(
                      padding: EdgeInsets.only(
                        top: 380,
                        left: 35,
                        right: 35,
                      ),
                      child: Column(
                        children: [
                          Container(
                            child: Text(
                              'Enter your email and we will send you a code in order to reset it. ',
                              style: TextStyle(
                                color: Colors.black54,
                                fontSize: 19,
                                fontWeight: FontWeight.w800,
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 40,
                          ),
                          TextFormField(
                            style: TextStyle(color: Colors.red.shade600),
                            decoration: InputDecoration(
                              labelText: 'Email',
                              labelStyle: TextStyle(color: Colors.red.shade600),
                              prefixIcon: Icon(
                                Icons.email_outlined,
                                color: Colors.red.shade600,
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(10),
                                borderSide: BorderSide(
                                  color: Colors.red.shade600,
                                ),
                              ),
                            ),
                             onSaved:(String? value) {
                                    _email = value;
                                  },
                                  validator: (String? value) {
                                    if (value == null || value.isEmpty) {
                                      return "L'email' ne doit pas etre vide";
                                    } else if (EmailValidator.validate(value) ==
                                        false) {
                                      return "Ce champs est reservé pour un email";
                                    } else {
                                      return null;
                                    }
                                  },
                          ),
                          SizedBox(height: 10.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              TextButton(
                                  onPressed: () {
                                    forgotPassword();
                                  },
                                  child: Text(
                                    'Get Code',
                                    style: TextStyle(
                                      fontWeight: FontWeight.w700,
                                      color: Colors.red.shade600,
                                      fontSize: 20,
                                    ),
                                  ))
                            ],
                          ),
                          SizedBox(height: 30.0),
                          Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/register');
                                },
                                child: Text(
                                  'Register',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                              TextButton(
                                onPressed: () {
                                  Navigator.pushNamed(context, '/');
                                },
                                child: Text(
                                  'LOGIN',
                                  style: TextStyle(
                                      color: Colors.black,
                                      fontSize: 18,
                                      decoration: TextDecoration.underline),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
