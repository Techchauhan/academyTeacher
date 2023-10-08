import 'package:academyteacher/Authentication/auth_wraper.dart';
import 'package:academyteacher/Authentication/NaivtaorPage.dart';
import 'package:academyteacher/LIve/screens/video_call_screen.dart';
import 'package:academyteacher/provider/userIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:provider/provider.dart';



void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    // options: const FirebaseOptions(
    //   apiKey: "AIzaSyA9UcgzCtABlwfg6CAcFFwkZG7QNTl1VKU",
    //   authDomain: "academy-643bb.firebaseapp.com",
    //   databaseURL: "https://academy-643bb-default-rtdb.firebaseio.com",
    //   projectId: "academy-643bb",
    //   storageBucket: "academy-643bb.appspot.com",
    //   messagingSenderId: "916658043549",
    //   appId: "1:916658043549:web:0b747dbea214df81e07274",
    //   measurementId: "G-MQKMH7YHV7"
    //
    // )
  );
  runApp(
    ChangeNotifierProvider(
      create: (context) => UserIdProvider(),
      child: MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {

    final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
    final userId = userIdProvider.userId;

    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Firebase Auth Example',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.white),
        useMaterial3: true,
      ),
      routes: {
        '/homelive': (context) => const NavigatorPage(),
        '/video-call': (context) => const VideoCallScreen(),
      },
      home: AuthWrapper(),
    );
  }
}
