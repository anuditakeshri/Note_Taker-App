import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:note_taking_app/Utils/data_model.dart';
import 'package:note_taking_app/Utils/encryption.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../main.dart';

class Note extends StatefulWidget {
  Note({this.mynote});
  static String? id = 'note';

  MyNote? mynote;

  @override
  _NoteState createState() => _NoteState();
}

class _NoteState extends State<Note> {
  Future<SharedPreferences> _prefs = SharedPreferences.getInstance();

  final _firestore = FirebaseFirestore.instance;

  TextEditingController? title;
  TextEditingController? description;

  String _timeString = '';

  String _getTime() {
    final String formattedDateTime =
        DateFormat('yMMMd').format(DateTime.now()).toString();
    _timeString = formattedDateTime;
    return _timeString;
  }

  @override
  void initState() {
    super.initState();
    description = TextEditingController(text: widget.mynote?.description ?? '');
    title = TextEditingController(text: widget.mynote?.title ?? '');
  }

  @override
  Widget build(BuildContext context) {
    _getTime();
    return Scaffold(
      floatingActionButton: FloatingActionButton(
        backgroundColor: Color(0xff3B3B3B),
        onPressed: () async {
          final SharedPreferences prefs = await _prefs;
          final userID = prefs.getString('id');
          FocusScope.of(context).unfocus();
          EncryptionService encryptionService = getIt<EncryptionService>();
          await _firestore
              .collection('users')
              .doc(userID)
              .collection('notes')
              .doc(widget.mynote?.id ?? null)
              .set(
            {
              'title': title!.text,
              'description': encryptionService.encrypt(description?.text ?? ''),
              'date': _getTime()
            },
          );
          final snackBar = SnackBar(
            backgroundColor: Colors.blue,
            content: Text('Note Saved!'),
          );
          ScaffoldMessenger.of(context).showSnackBar(snackBar);
        },
        child: Icon(
          Icons.check,
          color: Colors.white,
        ),
      ),
      backgroundColor: Color(0xff252525),
      appBar: AppBar(
        elevation: 0.0,
        backgroundColor: Color(0xff252525),
        automaticallyImplyLeading: false,
        actions: [
          GestureDetector(
            onTap: () {
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(
                  right: 16.0, top: 10.0, bottom: 10.0, left: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Color(0xff3B3B3B),
              ),
              child: Icon(Icons.arrow_back),
            ),
          ),
          Expanded(child: SizedBox()),
          GestureDetector(
            onTap: () async {
              final SharedPreferences prefs = await _prefs;
              final userID = prefs.getString('id');
              await _firestore
                  .collection('users')
                  .doc(userID)
                  .collection('notes')
                  .doc(widget.mynote!.id)
                  .delete();
              Navigator.pop(context);
            },
            child: Container(
              padding: EdgeInsets.all(10.0),
              margin: EdgeInsets.only(
                  right: 16.0, top: 10.0, bottom: 10.0, left: 16.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(12.0),
                color: Color(0xff3B3B3B),
              ),
              child: Icon(Icons.delete),
            ),
          ),
        ],
      ),
      body: Container(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        color: Color(0xff252525),
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                height: 30.0,
              ),
              TextField(
                controller: title,
                maxLines: null,
                cursorColor: Colors.white,
                decoration: InputDecoration(
                    hintText: 'Add Title',
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none),
                style: TextStyle(color: Colors.white, fontSize: 40.0),
              ),
              SizedBox(
                height: 20.0,
              ),
              Text(
                widget.mynote?.date ?? _getTime(),
                style: TextStyle(
                    color: Color(0xff515151),
                    fontSize: 20.0,
                    fontWeight: FontWeight.bold),
              ),
              SizedBox(
                height: 20.0,
              ),
              TextField(
                cursorColor: Colors.white,
                controller: description,
                decoration: InputDecoration(
                    hintStyle: TextStyle(color: Colors.white.withOpacity(0.6)),
                    hintText: 'Start Writing',
                    border: InputBorder.none,
                    focusedBorder: InputBorder.none),
                maxLines: null,
                style: TextStyle(
                    color: Colors.white,
                    fontSize: 20.0,
                    letterSpacing: 1.5,
                    height: 1.5),
              )
            ],
          ),
        ),
      ),
    );
  }
}
