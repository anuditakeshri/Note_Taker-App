import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get_it/get_it.dart';
import 'package:note_taking_app/Utils/locator.dart';

import 'Screens/login.dart';
import 'Screens/notes_screen.dart';
import 'Screens/register.dart';
import 'Screens/welcome.dart';
import 'Utils/encryption.dart';

GetIt getIt = GetIt.instance;

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  setUpLocator();
  EncryptionService encryptionService = getIt<EncryptionService>();
  await encryptionService.initialise();
  runApp(NoteTakingApp());
}

class NoteTakingApp extends StatelessWidget {
  const NoteTakingApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      initialRoute: WelcomeScreen.id!,
      routes: {
        WelcomeScreen.id!: (context) => WelcomeScreen(),
        LoginScreen.id!: (context) => LoginScreen(),
        RegisterScreen.id!: (context) => RegisterScreen(),
        NoteScreen.id!: (context) => NoteScreen(),
        // Note.id!: (context) => Note()
      },
    );
  }
}
