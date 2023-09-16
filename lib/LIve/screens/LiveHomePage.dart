import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:academyteacher/LIve/screens/meeting_screen.dart';
import 'package:academyteacher/LIve/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'history_meeting_screen.dart';

class LiveHomeScreen extends StatefulWidget {
  const LiveHomeScreen({Key? key}) : super(key: key);

  @override
  State<LiveHomeScreen> createState() => _LiveHomeScreenState();
}

class _LiveHomeScreenState extends State<LiveHomeScreen> {
  @override
  int _page = 0;

  onPagedChanged(int page) {
    _page = page;
    setState(() {});
  }

  List<Widget> pages = [
    const MeetingScreen(),
    const HostoryMeetingScreen(),
    const Text('Shubham '),
    const Text('Settings'),
  ];

  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid)));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          leading: BackButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid)));
            },
          ),
          // backgroundColor: backgroundColor,
          title: const Text('Meet & Chat'),
          centerTitle: true,
        ),
        body: pages[_page],
        bottomNavigationBar: BottomNavigationBar(
          type: BottomNavigationBarType.fixed,
          backgroundColor: footerColor,
          selectedFontSize: 14,
          unselectedFontSize: 14,
          selectedItemColor: Colors.white,
          unselectedItemColor: Colors.grey,
          currentIndex: _page,
          onTap: onPagedChanged,
          items: const [
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.comment_bank,
                ),
                label: 'Meet & Chat'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.lock_clock,
                ),
                label: 'Meetings'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.person_outline,
                ),
                label: 'Contacts'),
            BottomNavigationBarItem(
                icon: Icon(
                  Icons.settings,
                ),
                label: 'Settings'),
          ],
        ),
      ),
    );
  }
}
