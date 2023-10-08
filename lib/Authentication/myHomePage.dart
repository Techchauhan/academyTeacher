import 'dart:math';

import 'package:academyteacher/Basic%20Page/aboutUs.dart';
import 'package:academyteacher/Basic%20Page/helpAndSuppportpage.dart';
import 'package:academyteacher/Books/uploadPdf.dart';
import 'package:academyteacher/Chat/chatScreen.dart';
import 'package:academyteacher/Authentication/NaivtaorPage.dart';
import 'package:academyteacher/LIve/resources/jitsi_meet_wrapper_method.dart';
import 'package:academyteacher/LIve/screens/meeting_screen.dart';
import 'package:academyteacher/Slide%20Show/slideshow.dart';
import 'package:academyteacher/course/addinglecture.dart';
import 'package:academyteacher/course/createCourse.dart';
import 'package:academyteacher/course/viewupdateChapter.dart';
import 'package:academyteacher/live%20course/createLiveCourse.dart';
import 'package:academyteacher/Authentication/loginPage.dart';
import 'package:academyteacher/setting/settingPage.dart';
import 'package:academyteacher/student/registerStudent.dart';
import 'package:academyteacher/teacher/teacherInfo.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.user,  });


  final String user;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  final DatabaseReference _databaseReference =
  FirebaseDatabase.instance.reference();

  final JitsiMeetMethod _jitsiMeetMethods = JitsiMeetMethod();

  createNewMeeting() async {
    var random = Random();
    String roomName = (random.nextInt(10000000) + 10000000).toString();
    _jitsiMeetMethods.createMeeting(
        roomName: roomName, isAudioMuted: true, isVideoMuted: true);
  }

  joinMeeting(BuildContext context) {
    Navigator.pushNamed(context, '/video-call');
  }

  //get
  Future<String?> getTeacherName(String userId) async {
    try {
      DocumentSnapshot teacherSnapshot = await FirebaseFirestore.instance
          .collection('teachers')
          .doc(userId)
          .get();

      if (teacherSnapshot.exists) {
        return teacherSnapshot.get('name');
      }
    } catch (e) {
      print("Error fetching teacher name: $e");
    }
    return null;
  }

  //For LogOut
  Future<void> _logout(BuildContext context) async {
    await FirebaseAuth.instance.signOut();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      drawer: Drawer(
        child: FutureBuilder<DocumentSnapshot>(
          future: FirebaseFirestore.instance
              .collection('teachers')
              .doc(widget.user) // Assuming 'user' is the user's document ID
              .get(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const CircularProgressIndicator();
            } else if (snapshot.hasError) {
              return const Text('Error fetching data');
            } else {
              final teacherData = snapshot.data?.data() as Map<String, dynamic>;
              final teacherName = teacherData['name'] ?? '';

              return SingleChildScrollView(
                child: Column(
                  children: [
                    const Padding(padding: EdgeInsets.only(top: 60)),
                    const Text('Welcome', style: TextStyle(fontSize: 20),),
                    // Text('$teacherName', style: TextStyle(fontSize: 20, fontWeight: FontWeight.w600),),
                    const SizedBox(height: 30),
                    DrawerButton(
                      title: "Setting",
                      onPress: () {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => const SettingPage()));
                      },
                      icon: Icons.settings,
                    ),
                    const SizedBox(height: 10),
                    DrawerButton(
                      title: "Help & Support",
                      onPress: () {
                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => const HelpAndSupportPage()));
                      },
                      icon: Icons.support_agent,
                    ),
                    const SizedBox(height: 10),
                    DrawerButton(
                      title: "About us",
                      onPress: () {

                        Navigator.push(context,
                            MaterialPageRoute(builder: (context) => AboutUsPage()));
                      },
                      icon: Icons.info,
                    ),
                    DrawerButton(
                      title: "Log out",
                      onPress: () {
                        _logout(context);
                        Navigator.pushReplacement(context,
                            MaterialPageRoute(builder: (context) => LoginPage()));
                      },
                      icon: Icons.logout,
                    ),
                  ],
                ),
              );
            }
          },
        ),
      ),
      appBar: AppBar(

        actions: [
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.search),
                onPressed: () {
                  // Add search button onPressed logic here
                },
              ),
              IconButton(
                icon: const Icon(Icons.report),
                onPressed: () {
                  // Add more options button onPressed logic here
                },
              ),
            ],
          )
        ],
        title: const Text("Academy"),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child:  StreamBuilder<QuerySnapshot>(
            stream: FirebaseFirestore.instance.collection('courses').snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const CircularProgressIndicator();
              }

              if (snapshot.hasError) {
                return Text('Error: ${snapshot.error}');
              }

              if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
                return const Text('No data available');
              }

              final courseData = snapshot.data!.docs;

              return Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      children: List.generate(
                        courseData.length,
                            (index) {
                          final courseId = courseData[index].id;
                          final courseInfo =
                          courseData[index].data() as Map<String, dynamic>;
                          return Container(
                            width: 300,
                            margin: const EdgeInsets.all(9),
                            child: Card(
                              margin: const EdgeInsets.only(bottom: 20),
                              child: InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                        // AddChapterPage(courseId: courseId)
                                          ViewChaptersPage(courseId: courseId),
                                    ),
                                  );
                                },
                                child: Column(
                                  children: [
                                    Container(
                                      height: 200,
                                      width: 300,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(20),
                                      ),
                                      child: courseInfo.containsKey('thumbnail')
                                          ? Image.network(
                                        courseInfo['thumbnail'],
                                        width: 250,
                                        height: 80,
                                        fit: BoxFit.cover,
                                      )
                                          : Container(),
                                    ),
                                    ListTile(
                                      title: Text(
                                        // courseId.toString()
                                        courseInfo['title'],
                                        style: const TextStyle(
                                          fontSize: 20,
                                          fontWeight: FontWeight.bold,
                                        ),
                                      ),
                                      subtitle: Text("Price: ₹" + courseInfo['price']),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          );
                        },
                      ),
                    ),
                  ),
                  // Rest of your UI and widgets

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallCard(title: 'Students', icon: Icons.groups_outlined, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>RegisterStudent()));
                      }, iconColor: Colors.deepPurpleAccent,),
                      SmallCard(title: 'Push Notification', icon: Icons.notification_add_outlined, onPress: () {  }, iconColor: Colors.redAccent,),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallCard(title: 'Teachers', icon: Icons.card_membership, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const TeachersListScreen()));
                      }, iconColor: Colors.black87,),
                      SmallCard(title: 'Upload Book', icon: Icons.menu_book, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>UploadPdfPage()));
                      }, iconColor: Colors.orange,),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallCard(title: 'Add Course', icon: Icons.video_collection_outlined, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>const CreateCourse()));
                      }, iconColor: Colors.green,),
                      SmallCard(title: 'Add SlideShow', icon: Icons.slideshow, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>AddingSlideShow()));
                      }, iconColor: Colors.amber,),

                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallCard(title: 'Test Series', icon: Icons.access_alarm, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateLiveCourse( )));
                      }, iconColor: Colors.deepPurpleAccent,),
                      SmallCard(title: 'Live course', icon: Icons.shop, onPress: () {
                        Navigator.push(context, MaterialPageRoute(builder: (context)=>CreateLiveCourse( )));

                      }, iconColor: Colors.blue,),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      SmallCard(title: 'Announcement', icon: Icons.speaker, onPress: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CreateLiveCourse( )));
                      }, iconColor: Colors.deepPurpleAccent,),
                      SmallCard(title: 'Add Reel', icon: Icons.ondemand_video, onPress: () {
                        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>CreateLiveCourse( )));

                      }, iconColor: Colors.blue,),

                    ],
                  ),
                  Column(
                    children: [
                      const SizedBox(width: 30.0),

                      const Center(child: Text("Start Live Session", style: TextStyle(fontSize: 25, fontWeight: FontWeight.w500),),),

                      Container(
                        child: Padding(padding: const EdgeInsets.all(20),
                          child: ElevatedButton(onPressed: (){
                            createNewMeeting();
                          },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.red, // Set the background color
                              padding: const EdgeInsets.all(16.0), // Adjust the padding for size
                            ), child: Container(
                              child: const Row(
                                children: [
                                  Icon(Icons.video_call, color: Colors.white,),
                                  SizedBox(width: 20,),
                                  Text("Start Live Session", style: TextStyle(color: Colors.white,fontSize: 15),)
                                ],
                              ),
                            ),
                          ),
                        ),)

                    ],
                  ),
                ],
              );
            },
          )
        ),
      ),
      floatingActionButton: SpeedDial(

         icon: Icons.chat_outlined,
        onPress: (){
      Navigator.push(context, MaterialPageRoute(builder: (context)=> ChatScreen()));
        },
        animatedIconTheme: const IconThemeData(size: 22.0),
        curve: Curves.easeInOut,

      ),
    );

  }
}



class DrawerButton extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onPress;

  const DrawerButton({super.key, required this.title, required this.icon, required this.onPress,  });

  @override
  Widget build(BuildContext context) {
    return   Padding(
      padding: const EdgeInsets.only(left:8.0, top: 20),
      child: Row(
        children: [
          InkWell(
            onTap:
            onPress

            ,
            child: Row(
              children: [
                Text(title, style: const TextStyle(fontSize: 20),),
                const SizedBox(width: 10,),
                Icon(icon),
              ],
            ),
          ),
          const SizedBox(height: 50,)
        ],
      ),
    );
  }
}

class SmallCard extends StatelessWidget {

  final String title;
  final IconData icon;
  final VoidCallback onPress;
  final Color iconColor;

  const SmallCard({super.key, required this.title, required this.icon, required this.onPress, required this.iconColor});

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: InkWell(
        onTap: onPress,
        child: Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Icon(icon,color: iconColor,),
                const SizedBox(width: 10,),
                Text(title),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
