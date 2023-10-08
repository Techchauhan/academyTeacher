import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:academyteacher/LIve/screens/meeting_screen.dart';
import 'package:academyteacher/LIve/utils/colors.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../LIve/screens/history_meeting_screen.dart';

class NavigatorPage extends StatefulWidget {
  const NavigatorPage({Key? key}) : super(key: key);

  @override
  State<NavigatorPage> createState() => _NavigatorPageState();
}

class _NavigatorPageState extends State<NavigatorPage> {

  @override
  int _page = 0;

  onPagedChanged(int page) {
    _page = page;
    setState(() {});
  }

  List<Widget> pages = [
    MyHomePage(user: FirebaseAuth.instance.currentUser!.uid),
    const Text('No Meeting Scheduled'),
    const MeetingScreen(),
    const HostoryMeetingScreen(),
    // const Text('Settings'),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
              label: 'Meet & Chat'
          ),
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
    );
  }
}
