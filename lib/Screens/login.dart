import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_taking_app/Screens/notes_screen.dart';
import 'package:note_taking_app/Screens/register.dart';
import 'package:note_taking_app/Utils/constants.dart';
import 'package:note_taking_app/Utils/encryption.dart';
import 'package:note_taking_app/Utils/rounded_button.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

// import 'notes_screen.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({Key? key}) : super(key: key);

  static String? id = 'login';

  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();
  final _firestore = FirebaseFirestore.instance;

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
                keyboardType: TextInputType.phone,
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.white),
                controller: phoneController,
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
              onPressed: () async {
                try {
                  bool isUserExist = false;
                  await _firestore.collection('users').get().then(
                    (value) {
                      value.docs.forEach(
                        (element) {
                          if (element.id == phoneController.text) {
                            // print("Inside Loop");
                            isUserExist = true;
                          }
                          // print(element.id);
                        },
                      );
                    },
                  );
                  if (isUserExist) {
                    EncryptionService encryptionService =
                        getIt<EncryptionService>();

                    DocumentSnapshot snapshot = await _firestore
                        .collection('users')
                        .doc(phoneController.text)
                        .get();
                    Map snap = snapshot.data() as Map;

                    if (passController.text ==
                        encryptionService.decrypt(snap['password'])) {
                      // print('Passwords match!');
                      final SharedPreferences prefs = await _prefs;
                      await prefs.setString('id', phoneController.text);
                      Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(
                            builder: (context) => NoteScreen(
                              myUserID: prefs.getString('id'),
                            ),
                          ),
                          (route) => false);
                    } else {
                      FocusScope.of(context).unfocus();
                      final snack = SnackBar(
                        content: Text('Passwords not Matched! Try again!'),
                        backgroundColor: Colors.red,
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snack);
                      // await Future.delayed(Duration(seconds: 3));
                      passController.text = '';
                    }
                  } else {
                    FocusScope.of(context).unfocus();
                    final snackBar = SnackBar(
                      content: Text(
                          'User not Registered! Redirecting to Registration Page'),
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                    await Future.delayed(Duration(seconds: 3));
                    Navigator.pushReplacementNamed(context, RegisterScreen.id!);
                  }
                } catch (e) {
                  print(e);
                }
              },
              color: Colors.lightBlueAccent,
              title: 'Log In',
            )
          ],
        ),
      ),
    );
  }
}
