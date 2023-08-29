import 'package:academyteacher/main.dart';
import 'package:academyteacher/student/editUserDetail.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class RegisterStudent extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text('Registered Users'),
        leading: BackButton(
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyApp()));
          },
        ),
      ),
      body: UsersList(),
    );
  }
}

class UsersList extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    CollectionReference users = FirebaseFirestore.instance.collection('users');

    return FutureBuilder<QuerySnapshot>(
      future: users.get(),
      builder: (BuildContext context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return const Text("Something went wrong");
        }

        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        }

        List<QueryDocumentSnapshot> userDocs = snapshot.data!.docs;

        return ListView.builder(
          itemCount: userDocs.length,
          itemBuilder: (context, index) {
            Map<String, dynamic> userData =
                userDocs[index].data() as Map<String, dynamic>;

            return ListTile(
              leading: CircleAvatar(
                backgroundImage:
                    NetworkImage(userData['photoURL'] ?? 'fallback_image_url'),
              ),
              title: Text(userData['firstName'] ?? 'Unknown'),
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => EditProfileScreen(userData),
                  ),
                );
              },
            );
          },
        );
      },
    );
  }
}

class UserDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> userData;

  UserDetailsScreen(this.userData);

  @override
  Widget build(BuildContext context) {
    // Implement the layout to display user details using userData
    return Scaffold(
      appBar: AppBar(title: Text('User Details')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircleAvatar(
              backgroundImage:
                  NetworkImage(userData['photoURL'] ?? 'fallback_image_url'),
              radius: 50,
            ),
            const SizedBox(height: 20),
            Text('Name: ${userData['firstName'] ?? 'Unknown'}'),
            // Display other user data here
          ],
        ),
      ),
    );
  }
}
