import 'package:academyteacher/course/EditCourse/editChapter.dart';
import 'package:academyteacher/course/EditCourse/editLecture.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';

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
        title: const Text('Chapters'),
      ),
      body: StreamBuilder<QuerySnapshot>(
        stream: FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId)
            .collection('chapters')
            .snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          }

          if (snapshot.hasError) {
            return Text('Error: ${snapshot.error}');
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return const Center(
              child: Text('No chapters available.'),
            );
          }

          final chaptersData = snapshot.data!.docs;

          return ListView(
            children: chaptersData.map((chapterDoc) {
              final chapterInfo = chapterDoc.data() as Map<String, dynamic>;
              final chapterId = chapterDoc.id;

              return ExpansionTile(
                title: Text(
                  chapterInfo['title'],
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
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
                        _deleteChapter(chapterId); // Call delete chapter function
                      },
                    ),
                  ],
                ),
                children: chapterInfo['lectures'] != null
                    ? (chapterInfo['lectures'] as List<dynamic>)
                    .map((lectureInfo) {
                  final lectureId = lectureInfo['id']; // You may need to adjust this based on your data structure

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


  void _addChapter() async {
    try {
      final DocumentReference courseRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId);

      final newChapterRef = courseRef.collection('chapters').doc();

      await newChapterRef.set({
        'title': 'New Chapter', // Default title, you can allow the teacher to input this
        'lectures': [],
      });
    } catch (e) {
      // Handle errors, if any
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
  void _addLecture(String chapterId) async {
    try {
      final DocumentReference chapterRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('chapters')
          .doc(chapterId);

      final newLectureRef = chapterRef.collection('lectures').doc();

      await newLectureRef.set({
        'title': 'New Lecture', // Default title, you can allow the teacher to input this
        'videoUrl': 'https://www.youtube.com/', // Default URL, you can allow the teacher to input this
      });
    } catch (e) {
      // Handle errors, if any
      Fluttertoast.showToast(msg: "Error: $e");
    }
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

  void _performDeleteChapter(String chapterId) async {
    try {
      final chapterRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('chapters')
          .doc(chapterId);

      await chapterRef.delete();
    } catch (e) {
      // Handle errors, if any
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _performDeleteLecture(String chapterId, String lectureId) async {
    try {
      final lectureRef = FirebaseFirestore.instance
          .collection('courses')
          .doc(widget.courseId)
          .collection('chapters')
          .doc(chapterId)
          .collection('lectures')
          .doc(lectureId);

      await lectureRef.delete();
    } catch (e) {
      // Handle errors, if any
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

}



