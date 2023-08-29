import 'package:academyteacher/Chat/teacherMessagingScreen.dart';
import 'package:academyteacher/myHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class TeachersListScreen extends StatelessWidget {
  const TeachersListScreen({super.key});



  Future<List<Teacher>> fetchTeachers() async {
    final FirebaseAuth _auth = FirebaseAuth.instance;
    List<Teacher> teachers = [];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection('teachers').get();

    for (QueryDocumentSnapshot docSnapshot in querySnapshot.docs) {
      Map<String, dynamic> data = docSnapshot.data() as Map<String, dynamic>;
      Teacher teacher = Teacher(
        id: docSnapshot.id,
        name: data['name'] ?? '',  // Provide a default value if 'name' is null
        number: data['number'] ?? '',
        teachingExperience: data['teachingExperience'] ?? '',
        qualification: data['qualification'] ?? '',
        profilePhotoUrl: data['profilePhoto'] ?? '',
        teachingSubject: data ['teachingSubject']??'',
      );
      teachers.add(teacher);
    }

    return teachers;
  }


  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid))); // This pops the current page
        return false;
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Our faculty members'),
        leading: BackButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid))); // This pops the current page
            },
        ),
        ),
        body: FutureBuilder<List<Teacher>>(
          future: fetchTeachers(),
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return Center(
                child: CircularProgressIndicator() ,
              );// Loading indicator
            } else if (snapshot.hasError) {
              return Text('Error: ${snapshot.error}');
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return Text('No teachers found.');
            } else {
                return ListView.builder(
                  itemCount: snapshot.data!.length,
                  itemBuilder: (context, index) {
                    Teacher teacher = snapshot.data![index];
                    return Card(
                      child: Padding(
                        padding: EdgeInsets.all(16.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            // Left section: Teacher's image
                            Container(
                              width: 100,
                              height: 100,
                              decoration: BoxDecoration(
                                shape: BoxShape.circle,
                                image: DecorationImage(
                                  image: NetworkImage(teacher.profilePhotoUrl),
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(width: 16), // Add space between the sections
                            // Right section: Teacher's information
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    teacher.name,
                                    style: TextStyle(
                                      fontSize: 18,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.black,
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Teaching Subject: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          fontWeight: FontWeight.w600,

                                        ),
                                      ),
                                      Text(
                                        ' ${teacher.teachingSubject} ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Qualification:',
                                        style: TextStyle(
                                          fontSize: 14,
                                           fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      Text(
                                        '  ${teacher.qualification} ',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: 8),
                                  Row(
                                    children: [
                                      Text(
                                        'Experience: ',
                                        style: TextStyle(
                                          fontSize: 14,
                                         fontWeight: FontWeight.w600
                                        ),
                                      ),
                                      Text(
                                        '${teacher.teachingExperience}',
                                        style: TextStyle(
                                          fontSize: 14,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ],
                                  ),
                                  SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      IconButton(onPressed: (){
                                        // Navigator.pushReplacement(context,
                                        //     MaterialPageRoute(builder: (context)=>TeacherMessagingScreen(currentUser:  FirebaseAuth.instance.currentUser.uid.toString(), otherUser: '')));
                                      },
                                          icon:  Icon(Icons.chat_outlined))

                                    ],
                                  )

                                  // Add more information about the teacher here
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                );
            }
          },
        ),
      ),
    );
  }
}


class Teacher {
  final String id;
  final String name;
  final String number;
  final String teachingExperience;
  final String qualification;
  final String profilePhotoUrl;
  final String teachingSubject;

  Teacher({
    required this.teachingSubject,
    required this.id,
    required this.name,
    required this.number,
    required this.teachingExperience,
    required this.qualification,
    required this.profilePhotoUrl,
  });
}
