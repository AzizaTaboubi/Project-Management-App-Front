import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:managementappfront/constants/constants.dart' as constants;
import 'package:managementappfront/resetpwd.dart';
import 'package:pin_code_fields/pin_code_fields.dart';
import 'package:http/http.dart' as http;

class PinCodeVerificationScreen extends StatefulWidget {
  const PinCodeVerificationScreen({
    Key? key,
    required this.email,
  }) : super(key: key);

  final String email;
 

  @override
  State<PinCodeVerificationScreen> createState() =>
      _PinCodeVerificationScreenState();
}

class _PinCodeVerificationScreenState extends State<PinCodeVerificationScreen> {
  TextEditingController textEditingController = TextEditingController();
  
  late String? _otp;
  final String _baseUrl = constants.constants.BaseUrl;
  final formKey = GlobalKey<FormState>();

  Future<void> verifyOTP() async {
    if (formKey.currentState!.validate()) {
      formKey.currentState!.save();
      try {
        var url = Uri.parse("$_baseUrl/user/confirmationOtp");

        // Create the request body with the email and OTP
        var body = {'otp': _otp};

        // Send the POST request
        var response = await http.post(url, body: body);

        // Check the response status code
        if (response.statusCode == 200) {
          // Successful verification
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => resetPwd(
                email: widget.email,
                otp: '$_otp',
              ),
              
            ),
            
          );
        } else {
          // Verification failed
          snackBar("Invalid OTP");
        }
      } catch (error) {
        print(error);
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

  // ignore: close_sinks
  StreamController<ErrorAnimationType>? errorController;

  bool hasError = false;
  String currentText = "";

  @override
  void initState() {
    errorController = StreamController<ErrorAnimationType>();
    super.initState();
  }

  @override
  void dispose() {
    errorController!.close();

    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GestureDetector(
        onTap: () {},
        child: SizedBox(
          height: MediaQuery.of(context).size.height,
          width: MediaQuery.of(context).size.width,
          child: ListView(
            children: <Widget>[
              const SizedBox(height: 30),
              SizedBox(
                height: MediaQuery.of(context).size.height / 3,
                child: ClipRRect(
                  borderRadius: BorderRadius.circular(30),
                  child: Image.asset('assets/reset.jpg'),
                ),
              ),
              const SizedBox(height: 8),
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0),
                child: Text(
                  'OTP Verification',
                  style: TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
                  textAlign: TextAlign.center,
                ),
              ),
              Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30.0, vertical: 8),
                child: RichText(
                  text: TextSpan(
                    text: "Enter the code sent to ",
                    children: [
                      TextSpan(
                        text: "${widget.email}",
                        style: const TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                          fontSize: 15,
                        ),
                      ),
                    ],
                    style: const TextStyle(
                      color: Colors.black54,
                      fontSize: 15,
                    ),
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Form(
                key: formKey,
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    vertical: 4.0,
                    horizontal: 20,
                  ),
                  child: PinCodeTextField(
                    appContext: context,
                    pastedTextStyle: TextStyle(
                      color: Colors.grey.shade300,
                      fontWeight: FontWeight.bold,
                    ),
                    length: 4,
                    obscureText: false,
                    blinkWhenObscuring: true,
                    animationType: AnimationType.fade,
                    validator: (v) {
                      if (v!.length < 3) {
                        return "cell cant be empty";
                      } else {
                        return null;
                      }
                    },
                    pinTheme: PinTheme(
                      shape: PinCodeFieldShape.box,
                      borderRadius: BorderRadius.circular(5),
                      fieldHeight: 50,
                      fieldWidth: 50,
                      activeFillColor: Colors.white,
                    ),
                    cursorColor: Colors.black,
                    animationDuration: const Duration(milliseconds: 300),
                    enableActiveFill: true,
                    errorAnimationController: errorController,
                    controller: textEditingController,
                    keyboardType: TextInputType.number,
                    onSaved: (String? value) {
                      _otp = value;
                    },
                    boxShadows: const [
                      BoxShadow(
                        offset: Offset(0, 1),
                        color: Colors.black12,
                        blurRadius: 10,
                      )
                    ],
                    onCompleted: (v) {
                      debugPrint("Completed");
                    },
                    onChanged: (value) {
                      debugPrint(value);
                      setState(() {
                        currentText = value;
                      });
                    },
                    beforeTextPaste: (text) {
                      debugPrint("Allowing to paste $text");
                      return true;
                    },
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 30.0),
                child: Text(
                  hasError ? "*Please fill up all the cells properly" : "",
                  style: const TextStyle(
                    color: Color.fromARGB(255, 229, 115, 115),
                    fontSize: 12,
                    fontWeight: FontWeight.w400,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    "Didn't receive the code? ",
                    style: TextStyle(color: Colors.black54, fontSize: 15),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pushNamed(context, '/forgot');
                    },
                    child: const Text(
                      "RESEND",
                      style: TextStyle(
                        color: Color.fromARGB(255, 188, 84, 84),
                        fontWeight: FontWeight.bold,
                        fontSize: 16,
                      ),
                    ),
                  )
                ],
              ),
              const SizedBox(
                height: 14,
              ),
              Container(
                margin:
                    const EdgeInsets.symmetric(vertical: 16.0, horizontal: 30),
                child: ButtonTheme(
                  height: 50,
                  child: TextButton(
                    onPressed: () {
                      verifyOTP();
                    },
                    child: Center(
                      child: Text(
                        "VERIFY".toUpperCase(),
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
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
              const SizedBox(
                height: 16,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
