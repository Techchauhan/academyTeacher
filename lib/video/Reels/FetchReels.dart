import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class FetchReels extends StatefulWidget {
  @override
  State<FetchReels> createState() => _FetchReelsState();
}

class _FetchReelsState extends State<FetchReels> {
  List<String> videoUrls = [];
  VideoPlayerController? _controller;

  @override
  void initState() {
    super.initState();
    initializeSecondFirebaseApp();
    fetchVideoUrls();
  }

  @override
  void dispose() {
    _controller?.dispose(); // Dispose of the video controller when not needed
    super.dispose();
  }

  Future<void> initializeSecondFirebaseApp() async {
    // Initialize Firebase for the second project (replace with your new project's configuration).
    await Firebase.initializeApp(
      name: 'Social_Academy',
      options: FirebaseOptions(
        appId: '1:893108344546:android:994fe039ef7555fcfc70bb',
        apiKey: 'AIzaSyDebDv_AGtNFRUsCChkciHUpceDNbeFSBw',
        messagingSenderId: 'your_messaging_sender_id',
        projectId: 'socialacademy-9758f',
        storageBucket: "socialacademy-9758f.appspot.com",
      ),
    );
  }

  Future<void> fetchVideoUrls() async {
    try {
      await initializeSecondFirebaseApp();
      // Reference the Firebase Storage instance for the second project
      Reference storageReference = FirebaseStorage.instanceFor(
        app: Firebase.app('Social_Academy'), // Replace with your second project's app name
      ).ref().child('videos');

      // List all items (videos) in the 'videos' directory
      ListResult result = await storageReference.listAll();

      // Extract video download URLs and add them to the list
      for (var item in result.items) {
        String videoUrl = await item.getDownloadURL();
        setState(() {
          videoUrls.add(videoUrl);
        });
      }

      // Play the first video when the video URLs are fetched
      if (videoUrls.isNotEmpty) {
        playVideo(videoUrls[0]);
      }
    } catch (e) {
      print('Error fetching video URLs: $e');
    }
  }

  Future<void> playVideo(String videoUrl) async {
    // Dispose of the previous video controller if it exists
    _controller?.dispose();

    // Initialize and play the video
    _controller = VideoPlayerController.network(videoUrl)
      ..initialize().then((_) {
        // Ensure the first frame is shown and play the video
        setState(() {
          _controller?.play();
        });
      });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _controller != null
          ? AspectRatio(
        aspectRatio: _controller!.value.aspectRatio,
        child: VideoPlayer(_controller!),
      )
          : Center(
        child: CircularProgressIndicator(),
      ),
    );
  }
}


