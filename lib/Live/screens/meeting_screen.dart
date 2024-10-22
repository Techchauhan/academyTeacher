import 'dart:math';
import 'package:academyteacher/LIve/resources/jitsi_meet_wrapper_method.dart';
import 'package:academyteacher/LIve/screens/video_call_screen.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:core';

import '../widgets/home_meeting_button.dart';

class MeetingScreen extends StatefulWidget {
  const MeetingScreen({Key? key}) : super(key: key);

  @override
  State<MeetingScreen> createState() => _MeetingScreenState();
}
class _MeetingScreenState extends State<MeetingScreen> {


  User? currentUser = FirebaseAuth.instance.currentUser;
  final JitsiMeetMethod _jitsiMeetMethods = JitsiMeetMethod();


  createNewMeeting() async {
    var random = Random();
    String roomName = (random.nextInt(10000000) + 10000000).toString();
    _jitsiMeetMethods.createMeeting(
        roomName: roomName, isAudioMuted: true, isVideoMuted: true);
  }

  joinMeeting(BuildContext context) {
    Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>VideoCallScreen()));
  }

  @override
  Widget build(BuildContext context) {

    return SafeArea( 
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              HomeMeetingButton(
                onPressed: () {
                  createNewMeeting();
                },
                text: 'New Meeting',
                icon: Icons.videocam,
              ),
              HomeMeetingButton(
                onPressed: () => joinMeeting(context),
                text: 'Join Meeting',
                icon: Icons.add_box_rounded,
              ),
              HomeMeetingButton(
                onPressed: () {},
                text: 'Schedule',
                icon: Icons.calendar_today,
              ),
              HomeMeetingButton(
                onPressed: () {},
                text: 'Share Screen',
                icon: Icons.arrow_upward_rounded,
              ),
            ],
          ),
          Container(
            child: Text(currentUser!.displayName.toString()),
          ),
          const Expanded(
              child: Center(
            child: Text(
              'Create/Join Meeting with just a click',
              style: TextStyle(
                  color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
            ),
          ))
        ],
      ),
    );
  }


}
