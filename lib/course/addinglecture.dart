import 'package:academyteacher/Course%20Content/lectureModel.dart';
import 'package:academyteacher/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';


class AddChapterPage extends StatefulWidget {
  final String courseId;

  AddChapterPage({required this.courseId});

  @override
  _AddChapterPageState createState() => _AddChapterPageState();
}

class _AddChapterPageState extends State<AddChapterPage> {
  List<Chapter> chapters = [];

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        appBar: AppBar(
          title: Text('Add Chapters and Lectures'),
        ),
        body: SingleChildScrollView(
          child: Column(
            children: [
              // Create a list of chapter widgets
              Column(
                children: chapters.map((chapter) {
                  return SingleChildScrollView(
                    child: Column(
                      children: [
                        ListTile(
                          title: TextField(
                            decoration: InputDecoration(labelText: 'Chapter Title'),
                            onChanged: (value) {
                              chapter.title = value;
                            },
                          ),
                        ),
                        // Create a list of lecture widgets
                        Column(
                          children: chapter.lectures.map((lecture) {
                            return ListTile(
                              title: TextField(
                                decoration: InputDecoration(labelText: 'Lecture Title'),
                                onChanged: (value) {
                                  lecture.title = value;
                                },
                              ),
                              subtitle: TextField(
                                decoration: InputDecoration(labelText: 'YouTube Link'),
                                onChanged: (value) {
                                  lecture.videoUrl = value;
                                },
                              ),
                            );
                          }).toList(),
                        ),
                        ElevatedButton(
                          onPressed: () {
                            setState(() {
                              chapter.lectures.add(Lecture('', ''));
                            });
                          },
                          child: Row(
                            children: [
                              Text("ADD Lectures"),
                              Icon(Icons.add)
                            ],
                          ),
                        ),
                      ],
                    ),
                  );
                }).toList(),
              ),
              // Add Chapter Button
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    chapters.add(Chapter('', []));
                  });
                },
                child: Row(
                  children: [
                    Icon(Icons.add),
                    Text("Add Chapter")
                  ],
                ),
              ),
              // Save Button
              ElevatedButton(
                onPressed: () {
                  _saveChaptersToFirebase();
                },
                child: Text('Save Chapters and Lectures'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _saveChaptersToFirebase() {
    final DatabaseReference databaseReference =
    FirebaseDatabase.instance.reference();

    for (var chapter in chapters) {
      var chapterRef = databaseReference
          .child('courses')
          .child(widget.courseId)
          .child('chapters')
          .push();
      chapterRef.set({'title': chapter.title});

      for (var lecture in chapter.lectures) {
        chapterRef.child('lectures').push().set(lecture.toMap());
      }
    }

    // Clear the chapters list after saving
    chapters.clear();

    // Update the UI to reflect the changes
    setState(() {});
  }

  Future<bool> _onWillPop() async {
    return await showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Confirm Exit'),
        content: Text('Do you want to exit without saving?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(context).pop(false),
            child: Text('No'),
          ),
          TextButton(
            onPressed: () => Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid))),
            child: Text('Yes'),
          ),
        ],
      ),
    );
  }
  
}

 
