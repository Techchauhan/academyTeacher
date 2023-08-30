import 'package:academyteacher/widgits/animatedButton2.dart';
import 'package:academyteacher/widgits/customProgressIndicator.dart';
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
  late TextEditingController videoUrlController;


  String lectureTitle = '';
  String videoUrl = '';

  @override
  void initState() {
    super.initState();
    _fetchLectureTitle(); // Fetch the lecture title when the page loads
    lectureTitleController = TextEditingController(text: widget.oldLectureTitle);
    videoUrlController = TextEditingController(text: widget.oldVideoUrl);
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
        lectureTitle = (snapshot.snapshot.value as Map<dynamic, dynamic>)['videoUrl'] ?? ''; // Assign to videoUrl variable
        videoUrlController.text = videoUrl; // Update the video URL in the controller
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
              controller:  videoUrlController,
              readOnly: true,
            ),
          ),
          _uploadProgress > 0 ? CustomProgressIndicator(_uploadProgress) : const SizedBox(),

          AnimateButton2(onPress: (){
            _pickAndUploadVideo();
          }, ),

          Padding( padding: const EdgeInsets.all(16.0), // Adjust the padding as needed
            child: SizedBox(
              width:   MediaQuery.of(context).size.width - 32.0,
            ),),

          // ElevatedButton(
          //   onPressed: () {
          //     _updateLecture();
          //   },
          //   child: const Text('Save Changes'),
          // ), //old Button
        ],
      ),
      floatingActionButton: MyStickyButton(onPress: (){
        _updateLecture();
      },  ),
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


    //Code for Deleting the Old Video if the user selected the new video.
    if (videoUrl != widget.oldVideoUrl) {
      firebase_storage.Reference oldVideoRef =
      firebase_storage.FirebaseStorage.instance.refFromURL(videoUrlController.text);
      await oldVideoRef.delete();
    }

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
          videoUrlController.text = videoUrl;
          _uploadProgress = 0.0; // Reset progress indicator
        });

        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
          content: Text('Video uploaded successfully.'),
        ));
      });
    }
  }
}


class MyStickyButton extends StatelessWidget {
  final VoidCallback? onPress;
  final String? title;

  const MyStickyButton({super.key, this.onPress, this.title});


  @override
  Widget build(BuildContext context) {

    double buttonWidth = MediaQuery.of(context).size.width - 32.0; // Adjust the padding as needed

    return Padding(
      padding: const EdgeInsets.only(left: 10), // Adjust the padding as needed
      child: SizedBox(
        width: buttonWidth,
        height: 60,
        child: ElevatedButton(
          onPressed: onPress,
          child: const Text('Save Changes'),
        ),
      ),
    );
  }
}




