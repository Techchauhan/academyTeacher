import 'package:academyteacher/course/EditCourse/editChapter.dart';
import 'package:academyteacher/course/EditCourse/editLecture.dart';
import 'package:academyteacher/course/lectureDetails.dart';
import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class ViewChaptersPage extends StatefulWidget {
  final String courseId;
  ViewChaptersPage({super.key, required this.courseId});

  @override
  State<ViewChaptersPage> createState() => _ViewChaptersPageState();
}

class _ViewChaptersPageState extends State<ViewChaptersPage> {

  final DatabaseReference _databaseReference = FirebaseDatabase.instance.reference();

  String oldLectureTitle = '';
  String oldVideoUrl = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=> MyHomePage(user: FirebaseAuth.instance.currentUser!.uid))); // Navigate back when back button is pressed
          },
        ),
       
        title: const Text('Chapters'),
      ),
      body: StreamBuilder(
        stream: _databaseReference
            .child('courses')
            .child(widget.courseId)
            .child('chapters')
            .onValue,
        builder: (context, snapshot) {
          if (snapshot.hasData && snapshot.data != null) {
            final chaptersData = snapshot.data?.snapshot.value;

            if (chaptersData is Map) {
              return ListView(
                children: chaptersData.entries.map((entry) {
                  final chapterId = entry.key;
                  final chapterInfo = entry.value as Map<dynamic, dynamic>;

                  return ExpansionTile(
                    title: Text(chapterInfo['title'], style: TextStyle(fontWeight: FontWeight.w800),), // Handle if lectures are null
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                          icon: const Icon(Icons.add),
                          onPressed: () {
                            _addLecture(chapterId); // Call add lecture function
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.edit),
                          onPressed: () {
                            _editChapter(chapterId); // Call edit function
                          },
                        ),
                        IconButton(
                          icon: const Icon(Icons.delete),
                          onPressed: () {
                            _deleteChapter(
                                chapterId); // Call delete chapter function
                          },
                        ),
                      ],
                    ),
                    children: chapterInfo['lectures'] != null
                        ? (chapterInfo['lectures'] as Map<dynamic, dynamic>)
                        .entries
                        .map((lectureEntry) {

                      final lectureId = lectureEntry.key;
                      final lectureInfo =
                      lectureEntry.value as Map<dynamic, dynamic>;
                      String oldLectureTitle = lectureInfo['title'];
                      String oldVideoUrl = lectureInfo['videoUrl'];

                      return ListTile(
                        title: Text(lectureInfo['title']),
                        subtitle: Text(lectureInfo['videoUrl']),
                        trailing: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            IconButton(
                              icon: const Icon(Icons.edit),
                              onPressed: () {
                                _editLecture(
                                    chapterId, lectureId); // Call edit function
                              },
                            ),
                            IconButton(
                              icon: const Icon(Icons.delete),
                              onPressed: () {
                                _deleteLecture(
                                    chapterId, lectureId); // Call delete function
                              },
                            ),
                          ],
                        ),
                      );
                    }).toList()
                        : [],
                  );
                }).toList(),
              );
            } else {
              return const Center(
                child: Text('No chapters available.'),
              );
            }
          } else {
            return const Center(
              child: CircularProgressIndicator(),
            );
          }
        },
      ),
      floatingActionButton: SpeedDial(

        animatedIcon: AnimatedIcons.menu_close,
        animatedIconTheme: const IconThemeData(size: 22.0),
        curve: Curves.easeInOut,

        children: [
          SpeedDialChild(
              child: const Icon(Icons.info), label: "Report issue", onTap: () {}),

          SpeedDialChild(
              child: const Icon(Icons.edit),
              label: "ADD Lecture",
              onTap: (){
              },
          ),
          SpeedDialChild(
              child: const Icon(Icons.edit),
              label: "ADD Chapter",
              onTap: _addChapter,
          )
        ],
      ),
    );
  }


  void _addChapter() {
    final DatabaseReference courseRef = FirebaseDatabase.instance.reference().child('courses').child(widget.courseId);
    final newChapterRef = courseRef.child('chapters').push();

    newChapterRef.set({
      'title': 'New Chapter', // Default title, you can allow teacher to input this
      'lectures': [],
    });
  }

  void _editChapter(String chapterId) {
    // Navigate to edit chapter page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditChapterPage(
          courseId: widget.courseId,
          chapterId: chapterId,
        ),
      ),
    );
  }

  void _editLecture(String chapterId, String lectureId) {
    // Navigate to edit lecture page
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLecturePage(
          courseId: widget.courseId,
          chapterId: chapterId,
          lectureId: lectureId, oldVideoUrl: oldVideoUrl, oldLectureTitle: oldLectureTitle,
        ),
      ),
    );
  }

  // For deleting lectures and chapters
// For deleting chapters
  void _deleteChapter(String chapterId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Chapter'),
          content: const Text('Are you sure you want to delete this chapter?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _performDeleteChapter(chapterId); // Proceed with the deletion
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }



  //add lectures
  void _addLecture(String chapterId) {
    final DatabaseReference chapterRef = FirebaseDatabase.instance.reference().child('courses').child(widget.courseId).child('chapters').child(chapterId);
    final newLectureRef = chapterRef.child('lectures').push();

    newLectureRef.set({
      'title': 'New Lecture', // Default title, you can allow teacher to input this
      'videoUrl': 'https://www.youtube.com/', // Default URL, you can allow teacher to input this
    });
  }

// For deleting lectures
  void _deleteLecture(String chapterId, String lectureId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Delete Lecture'),
          content: const Text('Are you sure you want to delete this lecture?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _performDeleteLecture(chapterId, lectureId); // Proceed with the deletion
                Navigator.pop(context); // Close the dialog
              },
              child: const Text('Delete'),
            ),
          ],
        );
      },
    );
  }

// Function to actually delete the chapter
  void _performDeleteChapter(String chapterId) {
    FirebaseDatabase.instance.reference().child('courses').child(widget.courseId).child('chapters').child(chapterId).remove();
  }

// Function to actually delete the lecture
  void _performDeleteLecture(String chapterId, String lectureId) {
    FirebaseDatabase.instance.reference().child('courses').child(widget.courseId).child('chapters').child(chapterId).child('lectures').child(lectureId).remove();
  }




}



