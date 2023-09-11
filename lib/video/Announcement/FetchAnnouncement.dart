import 'dart:io';

import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';

class AnnouncementMainPage extends StatefulWidget {
  const AnnouncementMainPage({super.key, Key});

  @override
  State<AnnouncementMainPage> createState() => _AnnouncementMainPageState();
}

class _AnnouncementMainPageState extends State<AnnouncementMainPage> {
  final ImagePicker _imagePicker = ImagePicker();
  final PageController _pageController = PageController();
  int currentPage = 0;
  List<String> videoUrls = [];

  @override
  void initState() {
    super.initState();
    initializeSecondFirebaseApp();
    fetchVideoUrls();
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }

  Future<void> initializeSecondFirebaseApp() async {
    await Firebase.initializeApp(
      name: 'Social_Academy',
      options: FirebaseOptions(
        appId: '1:893108344546:android:994fe039ef7555fcfc70bb',
        apiKey: 'AIzaSyDebDv_AGtNFRUsCChkciHUpceDNbeFSBw',
        messagingSenderId: 'your_messaging_sender_id',
        projectId: 'socialacademy-9758f',
        storageBucket: 'socialacademy-9758f.appspot.com',
      ),
    );
  }

  Future<void> fetchVideoUrls() async {
    try {
      await initializeSecondFirebaseApp();
      Reference storageReference = FirebaseStorage.instanceFor(
        app: Firebase.app('Social_Academy'),
      ).ref().child('videos');

      ListResult result = await storageReference.listAll();

      for (var item in result.items) {
        String videoUrl = await item.getDownloadURL();
        setState(() {
          videoUrls.add(videoUrl);
        });
      }

      if (videoUrls.isNotEmpty) {
        print('Video URLs: $videoUrls'); // Print video URLs for debugging
      }
    } catch (e) {
      print('Error fetching video URLs: $e');
    }
  }



  Future<void> _uploadVideo() async {
    final XFile? video = await _imagePicker.pickVideo(source: ImageSource.gallery);

    if (video != null) {
      // Initialize Firebase for the second project
      await initializeSecondFirebaseApp();

      // Generate a unique filename for the uploaded video
      final String timestamp = DateTime.now().millisecondsSinceEpoch.toString();
      final String fileName = 'video_$timestamp.mp4';

      // Reference the Firebase Storage instance for the second project
      Reference storageReference = FirebaseStorage.instanceFor(
        app: Firebase.app('Social_Academy'),
      ).ref().child('videos/$fileName');

      UploadTask uploadTask = storageReference.putFile(File(video.path));

      // Wait for the upload to complete
      await uploadTask.whenComplete(() async {
        // Retrieve the download URL of the uploaded video
        String videoUrl = await storageReference.getDownloadURL();

        // TODO: Save the videoUrl to another Firebase database
        print('Video URL: $videoUrl');
      });
    }
  }

  void onPageChanged(int page) {
    setState(() {
      currentPage = page;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.white,
        title: Text(
          'Reels',
          style: TextStyle(
            color: Colors.black,
          ),
        ),
        leading: BackButton(
          onPressed: (){

          },
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt),
            onPressed: () {
              _uploadVideo();
              // Add your camera button functionality here
            },
            color: Colors.black,
          ),
        ],
        // ... (app bar code remains the same)
      ),
      body: PageView.builder(
        scrollDirection: Axis.vertical,
        controller: _pageController,
        itemCount: videoUrls.length,
        itemBuilder: (BuildContext context, int index) {
          return FetchReels(
            videoUrl: videoUrls[index],
          );
        },
        onPageChanged: onPageChanged,
      ),
    );
  }
}

class FetchReels extends StatefulWidget {
  final String videoUrl;

  const FetchReels({
    required this.videoUrl,
    Key? key,
  }) : super(key: key);

  @override
  State<FetchReels> createState() => _FetchReelsState();
}

class _FetchReelsState extends State<FetchReels> {
  late VideoPlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.network(widget.videoUrl)
      ..initialize().then((_) {
        setState(() {});
        _controller.play();
      });
  }

  @override
  void dispose() {
    _controller.dispose(); // Dispose the VideoPlayerController
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Stack(
          alignment: Alignment.center,
          children: [
            _controller.value.isInitialized
                ? AspectRatio(
              aspectRatio: _controller.value.aspectRatio,
              child: VideoPlayer(_controller),
            )
                : CircularProgressIndicator(),
            Align(
              alignment: Alignment.bottomRight,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.remove_red_eye_outlined),
                        onPressed: () {
                          // Add your like functionality here
                        },
                        color: Colors.white,
                      ),
                      Text("14.5K", style: TextStyle(color: Colors.white),)
                    ],
                  ),
                  SizedBox(height: 30,),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.thumb_up),
                        onPressed: () {
                          // Add your like functionality here
                        },
                        color: Colors.white,
                      ),
                      Text("6K", style: TextStyle(color: Colors.white),)
                    ],
                  ),
                  SizedBox(height: 30,),
                  Column(
                    children: [
                      IconButton(
                        icon: Icon(Icons.comment),
                        onPressed: () {
                          // Add your comment functionality here
                        },
                        color: Colors.white,
                      ),
                      Text("2k", style: TextStyle(color: Colors.white),)
                    ],
                  ),
                  SizedBox(height: 30,),
                  IconButton(
                    icon: Icon(Icons.share),
                    onPressed: () {
                      // Add your share functionality here
                    },
                    color: Colors.white,
                  ),
                  SizedBox(height: 30,)
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
