import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_taking_app/Screens/login.dart';
import 'package:note_taking_app/Utils/constants.dart';
import 'package:note_taking_app/Utils/encryption.dart';
import 'package:note_taking_app/Utils/rounded_button.dart';

import '../main.dart';

class RegisterScreen extends StatefulWidget {
  static String? id = 'register';

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _firestore = FirebaseFirestore.instance;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController passController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff3B3B3B),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 24.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Flexible(
              child: Hero(
                tag: 'logo',
                child: Container(
                  height: 200.0,
                  child: Image.asset('images/logo.png'),
                ),
              ),
            ),
            SizedBox(
              height: 48.0,
            ),
            TextField(
              keyboardType: TextInputType.text,
              textAlign: TextAlign.center,
              controller: nameController,
              style: TextStyle(color: Colors.white),
              decoration: kTextFieldDecoration.copyWith(
                  hintText: 'Enter your Name',
                  hintStyle: TextStyle(color: Colors.white.withOpacity(0.5))),
            ),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                controller: phoneController,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter your phone number",
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.5)))),
            SizedBox(
              height: 8.0,
            ),
            TextField(
                obscureText: true,
                textAlign: TextAlign.center,
                controller: passController,
                style: TextStyle(color: Colors.white),
                decoration: kTextFieldDecoration.copyWith(
                    hintText: "Enter your password",
                    hintStyle:
                        TextStyle(color: Colors.white.withOpacity(0.5)))),
            SizedBox(
              height: 24.0,
            ),
            RoundedButton(
              // 1.encrypt the password 2. Save the encrypted password, name & phone number in database 3. check if user is already registered.
              onPressed: () async {
                try {
                  bool isRegistered = false;
                  await _firestore.collection('users').get().then(
                    (value) {
                      value.docs.forEach(
                        (element) {
                          if (element.id == phoneController.text) {
                            // print("Inside Loop");
                            isRegistered = true;
                          }
                          // print(element.id);
                        },
                      );
                    },
                  );
                  // print(isRegistered);
                  if (!isRegistered) {
                    EncryptionService encryptionService =
                        getIt<EncryptionService>();

                    await _firestore
                        .collection('users')
                        .doc(phoneController.text)
                        .set(
                      {
                        'phone_number': phoneController.text,
                        'name': nameController.text,
                        'password':
                            encryptionService.encrypt(passController.text)
                      },
                    );
                    // print("Reached IF");
                    FocusScope.of(context).unfocus();
                    final snackBar = SnackBar(
                      content: Text(
                          'New User Registered! Redirecting to Login Page'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    Navigator.pushReplacementNamed(context, LoginScreen.id!);
                  } else {
                    FocusScope.of(context).unfocus();
                    final snackBar = SnackBar(
                      content: Text(
                          'User already Registered! Redirecting to Login Page'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    await Future.delayed(Duration(seconds: 3));
                    // print("Reached Else");
                    Navigator.pushReplacementNamed(context, LoginScreen.id!);
                  }
                } catch (e) {
                  print(e);
                }
              },
              color: Colors.blueAccent,
              title: 'Register',
            )
          ],
        ),
      ),
    );
  }
}
