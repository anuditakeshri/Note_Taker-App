import 'dart:math';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:note_taking_app/Screens/individual_note.dart';
import 'package:note_taking_app/Utils/data_model.dart';
import 'package:note_taking_app/Utils/encryption.dart';
import 'package:note_taking_app/main.dart';

class NoteScreen extends StatefulWidget {
  NoteScreen({this.myUserID});

  static String? id = 'notes';
  String? myUserID;

  @override
  _NoteScreenState createState() => _NoteScreenState();
}

class _NoteScreenState extends State<NoteScreen> {
  final _firestore = FirebaseFirestore.instance;
  List<MyNote> notes = <MyNote>[];
  List<MyNote> searchedNotes = <MyNote>[];
  bool isSearch = false;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        floatingActionButton: FloatingActionButton(
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(builder: (context) => Note()),
            );
          },
          backgroundColor: Color(0xff3B3B3B),
          child: Icon(
            Icons.add,
            color: Colors.white,
          ),
        ),
        backgroundColor: Color(0xff252525),
        body: Container(
          margin: EdgeInsets.symmetric(horizontal: 20.0),
          child: Column(
            children: [
              SizedBox(
                height: 20.0,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  isSearch
                      ? SizedBox()
                      : Text(
                          'Notes',
                          style: TextStyle(
                              fontSize: 40.0,
                              fontWeight: FontWeight.w400,
                              color: Colors.white),
                        ),
                  isSearch
                      ? ConstrainedBox(
                          constraints: BoxConstraints(
                              maxWidth: MediaQuery.of(context).size.width - 40,
                              maxHeight: 50),
                          child: TextField(
                            autofocus: true,
                            cursorColor: Colors.white,
                            style: TextStyle(color: Colors.white, fontSize: 25),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.all(10.0),
                              filled: true,
                              fillColor: Color(0xff3B3B3B),
                              focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(20),
                                  borderSide: BorderSide(color: Colors.grey)),
                              border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey),
                                  borderRadius: BorderRadius.circular(20)),
                              suffix: IconButton(
                                onPressed: () {
                                  setState(() {
                                    isSearch = false;
                                  });
                                },
                                icon: Icon(
                                  Icons.close,
                                  color: Colors.red,
                                ),
                              ),
                            ),
                            onChanged: (value) {
                              // print(value);
                              searchedNotes = [];
                              notes.forEach(
                                (element) {
                                  bool isContain = element.title
                                          ?.toLowerCase()
                                          .contains(value.toLowerCase()) ??
                                      false;
                                  if (isContain) {
                                    searchedNotes.add(element);
                                  }
                                },
                              );
                              setState(() {});
                            },
                          ),
                        )
                      : GestureDetector(
                          onTap: () {
                            setState(() {
                              isSearch = true;
                            });
                          },
                          child: Container(
                            padding: EdgeInsets.all(10.0),
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.circular(12.0),
                              color: Color(0xff3B3B3B),
                            ),
                            child: Icon(
                              Icons.search,
                              color: Colors.white,
                              size: 20.0,
                            ),
                          ),
                        ),
                ],
              ),
              SizedBox(
                height: 30.0,
              ),
              Expanded(
                child: isSearch
                    ? GridLayout(searchedNotes: searchedNotes)
                    : StreamBuilder(
                        stream: _firestore
                            .collection('users')
                            .doc(widget.myUserID)
                            .collection('notes')
                            .snapshots(),
                        builder: (context, AsyncSnapshot snapshot) {
                          if (snapshot.hasData) {
                            EncryptionService encryptionService =
                                getIt<EncryptionService>();
                            notes = [];
                            snapshot.data.docs.forEach(
                              (element) {
                                // print(element.data());
                                // bool foundNote = false;
                                // for (var i = 0; i < notes.length; i++) {
                                //   print(notes[i].title);
                                //   if (notes[i].id == element.id) {
                                //     print(notes[i].title);
                                //     notes[i] = MyNote(
                                //       title: (element.data() as Map)['title'],
                                //       description: encryptionService.decrypt(
                                //           (element.data() as Map)['description']),
                                //       date: (element.data() as Map)['date'],
                                //       id: (element.id),
                                //     );
                                //     foundNote = true;
                                //     break;
                                //   }
                                // }
                                // if (foundNote == false) {
                                notes.add(MyNote(
                                  color: Colors.primaries[Random()
                                      .nextInt(Colors.primaries.length)],
                                  title: (element.data() as Map)['title'],
                                  description: encryptionService.decrypt(
                                      (element.data() as Map)['description']),
                                  date: (element.data() as Map)['date'],
                                  id: (element.id),
                                ));
                                // }
                                ;
                              },
                            );
                            searchedNotes = notes;
                            return GridLayout(searchedNotes: searchedNotes);
                          } else {
                            return Center(child: CircularProgressIndicator());
                          }
                        },
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class GridLayout extends StatelessWidget {
  const GridLayout({
    Key? key,
    required this.searchedNotes,
    // required this.notes,
  }) : super(key: key);

  final List<MyNote> searchedNotes;
  // final List<MyNote> notes;

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      shrinkWrap: true,
      crossAxisCount: 2,
      children: List.generate(searchedNotes.length, (index) {
        return GestureDetector(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => Note(
                  mynote: searchedNotes[index],
                ),
              ),
            );
          },
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20.0),
              color: searchedNotes[index].color,
            ),
            margin: EdgeInsets.all(8.0),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    height: 100.0,
                    width: 120.0,
                    child: Text(
                      searchedNotes[index].title!,
                      overflow: TextOverflow.ellipsis,
                      maxLines: null,
                      style: TextStyle(color: Colors.black, fontSize: 30.0),
                    ),
                  ),
                  Expanded(child: SizedBox()),
                  Text(
                    searchedNotes[index].date!,
                    style: TextStyle(color: Colors.white),
                  )
                ],
              ),
            ),
          ),
        );
      }),
    );
  }
}
