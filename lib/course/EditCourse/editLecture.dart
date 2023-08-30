import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart' as firebase_storage;
import 'dart:io';

class EditLecturePage extends StatefulWidget {
  final String courseId;
  final String chapterId;
  final String lectureId;
  final String oldVideoUrl;
  final String oldLectureTitle;

  EditLecturePage({
    required this.courseId,
    required this.chapterId,
    required this.lectureId,
    required this.oldVideoUrl,
    required this.oldLectureTitle,
  });

  @override
  _EditLecturePageState createState() => _EditLecturePageState();
}

class _EditLecturePageState extends State<EditLecturePage> {

  double _uploadProgress = 0.0;
  late TextEditingController lectureTitleController;

  String lectureTitle = '';
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchLectureTitle(); // Fetch the lecture title when the page loads
    lectureTitleController = TextEditingController(text: widget.oldLectureTitle);
    videoUrl = widget.oldVideoUrl;
  }

  void _fetchLectureTitle() async {
    // Fetch the lecture title from Firebase and update the lectureTitle variable
    DatabaseReference lectureRef = FirebaseDatabase.instance
        .reference()
        .child('courses')
        .child(widget.courseId)
        .child('chapters')
        .child(widget.chapterId)
        .child('lectures')
        .child(widget.lectureId);

    DatabaseEvent snapshot = await lectureRef.once();

    if (snapshot.snapshot.value != null) {
      setState(() {
        lectureTitle = (snapshot.snapshot.value as Map<dynamic, dynamic>)['title'] ?? '';
        lectureTitleController.text = lectureTitle;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Lecture'),
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextFormField(
              decoration: const InputDecoration(labelText: 'Lecture Title'),
              controller: lectureTitleController,
              onChanged: (value) {
                setState(() {
                  lectureTitleController.text = value;
                });
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: TextField(
              decoration: const InputDecoration(labelText: 'YouTube Link'),
              controller: TextEditingController(text: videoUrl),
              readOnly: true,
            ),
          ),
          LinearProgressIndicator(
            value: _uploadProgress,
            semanticsLabel: 'Upload Progress',
          ),
          ElevatedButton(
            onPressed: () {
              _pickAndUploadVideo();
            },
            child: const Text('Upload Video'),
          ),
          ElevatedButton(
            onPressed: () {
              _updateLecture();
            },
            child: const Text('Save Changes'),
          ),
        ],
      ),
    );
  }

  void _updateLecture() async {
    String newLectureTitle = lectureTitleController.text;

    FirebaseDatabase.instance
        .reference()
        .child('courses')
        .child(widget.courseId)
        .child('chapters')
        .child(widget.chapterId)
        .child('lectures')
        .child(widget.lectureId)
        .set({
      'title': newLectureTitle,
      'videoUrl': videoUrl,
    });

    Navigator.pop(context); // Return to the previous page
  }

  Future<void> _pickAndUploadVideo() async {
    final XFile? pickedVideo =
    await ImagePicker().pickVideo(source: ImageSource.gallery);

    if (pickedVideo != null) {
      String videoPath =
          'videos/${widget.courseId}/${widget.chapterId}/${widget.lectureId}/${pickedVideo.name}';
      firebase_storage.Reference storageRef =
      firebase_storage.FirebaseStorage.instance.ref().child(videoPath);

      firebase_storage.UploadTask uploadTask =
      storageRef.putFile(File(pickedVideo.path));

      uploadTask.snapshotEvents.listen((firebase_storage.TaskSnapshot snapshot) {
        setState(() {
          _uploadProgress = snapshot.bytesTransferred / snapshot.totalBytes;
        });
      });

      await uploadTask.whenComplete(() async {
        String downloadUrl = await storageRef.getDownloadURL();
        setState(() {
          videoUrl = downloadUrl;
          _uploadProgress = 0.0; // Reset progress indicator
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Video uploaded successfully.'),
        ));
      });
    }
  }
}
