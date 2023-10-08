import 'package:flutter/material.dart';

class Dashboard extends StatelessWidget {
  const Dashboard({super.key,   });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: MediaQuery.of(context).size.width,
        decoration: const BoxDecoration(
          color: Colors.lightBlueAccent,
          borderRadius: BorderRadius.only(
            topLeft: Radius.circular(60),
            topRight: Radius.circular(60),
          ),
        ),
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: ListView(
            children: [
              const Padding(
                padding: EdgeInsets.all(8.0),
                child: Text("Dashboard", style: TextStyle(fontWeight: FontWeight.w500, fontSize: 25),),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const ProfileScreen(),
                      //   ),
                      // );
                    },
                    icon: Icons.question_answer,
                    iconColor: Colors.cyanAccent,
                    title: "Take Quiz",
                  ),
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const AssignmentScreen(),
                      //   ),
                      // );
                    },
                    icon: Icons.edit_note_sharp,
                    iconColor: Colors.yellow,
                    title: "Assignment",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const MyProfile(),
                      //   ),
                      // );
                    },
                    icon: Icons.list,
                    iconColor: Colors.red,
                    title: "Syllabus",
                  ),
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const MyProfile(),
                      //   ),
                      // );
                    },
                    icon: Icons.person,
                    iconColor: Colors.black,
                    title: "Profile",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const MyProfile(),
                      //   ),
                      // );
                    },
                    icon: Icons.monetization_on,
                    iconColor: Colors.grey,
                    title: "Fees",
                  ),
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const AssignmentScreen(),
                      //   ),
                      // );
                    },
                    icon: Icons.calendar_month,
                    iconColor: Colors.green,
                    title: "Time-table",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const MyProfile(),
                      //   ),
                      // );
                    },
                    icon: Icons.analytics,
                    iconColor: Colors.greenAccent,
                    title: "Rank",
                  ),
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const AssignmentScreen(),
                      //   ),
                      // );
                    },
                    icon: Icons.groups_outlined,
                    iconColor: Colors.black,
                    title: "Class Mates",
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const MyProfile(),
                      //   ),
                      // );
                    },
                    icon: Icons.video_collection_outlined,
                    iconColor: Colors.deepOrange,
                    title: "Videos",
                  ),
                  HomeCard(
                    onPress: () {
                      // Navigator.push(
                      //   context,
                      //   MaterialPageRoute(
                      //     builder: (context) => const AssignmentScreen(),
                      //   ),
                      // );
                    },
                    icon: Icons.event_note_outlined,
                    iconColor: Colors.redAccent,
                    title: "Notice",
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class HomeCard extends StatelessWidget {
  const HomeCard({
    required this.onPress,
    required this.icon,
    required this.title,
    this.iconColor = Colors.blueAccent, // Default icon color
    Key? key,
  }) : super(key: key);

  final VoidCallback onPress;
  final IconData icon;
  final String title;
  final Color iconColor; // Icon color property

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onPress,
      child: Container(
        margin: const EdgeInsets.only(top: 15),
        width: MediaQuery.of(context).size.width / 2.5,
        height: MediaQuery.of(context).size.height / 6,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(20),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Icon(
              icon,
              size: 70,
              color: iconColor, // Use the specified icon color
            ),
            Text(
              title,
              style: const TextStyle(fontSize: 20),
            ),
          ],
        ),
      ),
    );
  }
}

