import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:academyteacher/video/Reels/reelsMainPage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';


class VideoNavigator extends StatefulWidget {
  @override
  _VideoNavigatorState createState() => _VideoNavigatorState();
}

class _VideoNavigatorState extends State<VideoNavigator> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    // Initialize the TabController with 2 tabs (Paid and Free).
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose(); // Don't forget to dispose of the controller.
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid,)));
        return false;
      },
      child: WillPopScope(
        onWillPop: ()async{
          Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid,)));
          return true;
        },
        child: SafeArea(
          child: Scaffold(
            body: Center(
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: 20.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    SizedBox(height: 20,),
                    Container( // Container with circular border radius
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(20.0),
                        border: Border.all(color: Colors.blue), // Border color
                      ),
                      child: TabBar(
                        controller: _tabController,
                        tabs: [
                          Tab(
                            text: 'Announcement',
                          ),
                          Tab(
                            text: 'Shorts',
                          ),
                        ],
                        indicatorColor: Colors.blue, // Change the indicator color
                      ),
                    ),
                    SizedBox(height: 20.0),
                    Expanded(
                      child: TabBarView(
                        controller: _tabController,
                        children: [
                          // Paid Course content goes here
                         Center(child: Text("Anoucment page"),),
                          // Free Course content goes here
                          ReelsMainPage(),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
