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
              final chapterTitle = chapterInfo['title'];

              return ExpansionTile(
                title: Text(
                  chapterTitle,
                  style: TextStyle(fontWeight: FontWeight.w800),
                ),
                trailing: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.add),
                      onPressed: () {
                        _addLecture(chapterId);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () {
                        _editChapter(chapterId, chapterTitle);
                      },
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete),
                      onPressed: () {
                        _deleteChapter(chapterId);
                      },
                    ),
                  ],
                ),
                children: [
                  StreamBuilder<QuerySnapshot>(
                    stream: FirebaseFirestore.instance
                        .collection('courses')
                        .doc(widget.courseId)
                        .collection('chapters')
                        .doc(chapterId)
                        .collection('lectures')
                        .snapshots(),
                    builder: (context, lectureSnapshot) {
                      if (lectureSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      }

                      if (lectureSnapshot.hasError) {
                        return Text('Error: ${lectureSnapshot.error}');
                      }

                      if (!lectureSnapshot.hasData ||
                          lectureSnapshot.data!.docs.isEmpty) {
                        return const Center(
                          child: Text('No lectures available.'),
                        );
                      }

                      final lecturesData = lectureSnapshot.data!.docs;

                      return Column(
                        children: lecturesData.map((lectureDoc) {
                          final lectureInfo =
                          lectureDoc.data() as Map<String, dynamic>;
                          final lectureId = lectureDoc.id;

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
                                        chapterId, lectureId, lectureInfo['title'], lectureInfo['videoUrl']);
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete),
                                  onPressed: () {
                                    _deleteLecture(chapterId, lectureId);
                                  },
                                ),
                              ],
                            ),
                          );
                        }).toList(),
                      );
                    },
                  ),
                ],
              );
            }).toList(),
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _addChapter();
          Fluttertoast.showToast(msg: 'Adding New Chapter');
        },
        child: Icon(Icons.add),
      ),
    );
  }

  void _addChapter() async {
    String chapterTitle = ''; // Initialize an empty title

    // Show a dialog to get the chapter title from the user
    await showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Add New Chapter'),
          content: TextField(
            decoration: InputDecoration(labelText: 'Chapter Title'),
            onChanged: (value) {
              chapterTitle = value;
            },
          ),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close the dialog
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                Navigator.pop(context, chapterTitle); // Close the dialog with the chapter title
              },
              child: Text('Add'),
            ),
          ],
        );
      },
    );

    if (chapterTitle.isNotEmpty) {
      try {
        final DocumentReference courseRef = FirebaseFirestore.instance
            .collection('courses')
            .doc(widget.courseId);

        final newChapterRef = courseRef.collection('chapters').doc(chapterTitle);

        await newChapterRef.set({
          'title': chapterTitle,
          'lectures': [],
        });
      } catch (e) {
        Fluttertoast.showToast(msg: "Error: $e");
      }
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
        'title': 'New Lecture',
        'videoUrl': 'https://www.youtube.com/',
      });
    } catch (e) {
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }

  void _editChapter(String chapterId, String chapterTitle) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditChapterPage(
          courseId: widget.courseId,
          chapterId: chapterId,
          chapterTitle: chapterTitle,
        ),
      ),
    );
  }

  void _editLecture(String chapterId, String lectureId, String lectureTitle, String videoUrl) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => EditLecturePage(
          courseId: widget.courseId,
          chapterId: chapterId,
          lectureId: lectureId,
          oldLectureTitle: lectureTitle,
          oldVideoUrl: videoUrl,
        ),
      ),
    );
  }

  void _deleteChapter(String chapterId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Chapter'),
          content: Text('Are you sure you want to delete this chapter?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _performDeleteChapter(chapterId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
            ),
          ],
        );
      },
    );
  }

  void _deleteLecture(String chapterId, String lectureId) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: Text('Delete Lecture'),
          content: Text('Are you sure you want to delete this lecture?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context);
              },
              child: Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                _performDeleteLecture(chapterId, lectureId);
                Navigator.pop(context);
              },
              child: Text('Delete'),
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
      Fluttertoast.showToast(msg: "Error: $e");
    }
  }
}
