import 'dart:io';

import 'package:academyteacher/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class EditProfilePage extends StatefulWidget {
  final String userId;


  EditProfilePage({required this.userId});

  @override
  _EditProfilePageState createState() => _EditProfilePageState();
}

class _EditProfilePageState extends State<EditProfilePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _teachingSubjectController = TextEditingController();
  final TextEditingController _teachingExperienceController = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();

  final ImagePicker _imagePicker = ImagePicker();
  File? selectedImageFile;
  String? profilePhotoUrl;
  bool isFetchingProfilePhoto = false;

  @override
  void initState() {
    super.initState();
    // Fetch user's existing data from Firestore and set the controllers
    fetchProfilePhoto();
    _fetchUserData();
  }
  void fetchProfilePhoto() async {
    setState(() {
      isFetchingProfilePhoto = true;
    });
    String uid = FirebaseAuth.instance.currentUser!.uid;
    DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teachers').doc(uid).get();
    setState(() {
      profilePhotoUrl = snapshot.get('profilePhoto');
      isFetchingProfilePhoto = false;
    });
  }

  Future<void> pickImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      setState(() {
        selectedImageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> uploadProfilePhoto() async {
    String uid = FirebaseAuth.instance.currentUser!.uid;
    Reference storageReference = FirebaseStorage.instance.ref().child('profile_photos/$uid');
    UploadTask uploadTask = storageReference.putFile(selectedImageFile!);
    await uploadTask.whenComplete(() async {
      String photoUrl = await storageReference.getDownloadURL();
      await FirebaseFirestore.instance.collection('teachers').doc(uid).update({
        'profilePhoto': photoUrl,
      });
      fetchProfilePhoto();
      print(profilePhotoUrl.toString());
    });
  }

  void _fetchUserData() async {
    try {
      DocumentSnapshot snapshot = await FirebaseFirestore.instance.collection('teachers').doc(widget.userId).get();
      if (snapshot.exists) {
        Map<String, dynamic> userData = snapshot.data() as Map<String, dynamic>;

        setState(() {
          _nameController.text = userData['name'];
          _emailController.text = userData['email'];
          _teachingSubjectController.text = userData['teachingSubject'];
          _teachingExperienceController.text = userData['teachingExperience'];
          _qualificationController.text = userData['qualification'];
        });
      }
    } catch (e) {
      print("Error fetching user data: $e");
      // Handle error
    }
  }

  void _updateProfile() async {
    try {
      await FirebaseFirestore.instance.collection('teachers').doc(widget.userId).update({
        'name': _nameController.text,
        'email': _emailController.text,
        'teachingSubject': _teachingSubjectController.text,
        'teachingExperience': _teachingExperienceController.text,
        'qualification': _qualificationController.text,


      }).then((value) {
        Fluttertoast.showToast(msg: 'Update Successfully');
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid)));
      });

      // Show a success message or navigate back to the previous screen
    } catch (e) {
      print("Error updating user profile: $e");
      // Handle error
    }


  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: BackButton(
          onPressed: (){
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid.toString())));
          },
        ),
        title: const Text("Edit Profile"),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: pickImage,
                child: CircleAvatar(
                  radius: 70,
                  // backgroundColor: Colors.transparent,
                  backgroundImage: selectedImageFile != null
                      ? FileImage(selectedImageFile!)
                      : (profilePhotoUrl != null
                      ? NetworkImage(profilePhotoUrl!)
                      :   NetworkImage('https://firebasestorage.googleapis.com/v0/b/academy-643bb.appspot.com/o/teacher_images%2Fdefaultprofilepicture.jpg?alt=media&token=42220e88-e2b3-45ae-9c99-dde7c0d759f0') as ImageProvider),
                ),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: selectedImageFile != null ? uploadProfilePhoto : null,
                child: const Text('Update Profile Photo'),
              ),

              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(labelText: "Name"),
              ),
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(labelText: "Email"),
              ),
              TextFormField(
                controller: _teachingSubjectController,
                decoration: const InputDecoration(labelText: "Teaching Subject"),
              ),
              TextFormField(
                controller: _teachingExperienceController,
                decoration: const InputDecoration(labelText: "Teaching Experience"),
              ),
              TextFormField(
                controller: _qualificationController,
                decoration: const InputDecoration(labelText: "Qualification"),
              ),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: (){
          _updateProfile();
          selectedImageFile != null ? uploadProfilePhoto : null;
        },
        child: const Icon(Icons.check),
      ),
    );
  }
}
