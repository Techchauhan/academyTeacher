import 'dart:io';

import 'package:academyteacher/course/addinglecture.dart';
import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';

import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';

class CreateCourse extends StatefulWidget {
  const CreateCourse({super.key});

  @override
  State<CreateCourse> createState() => _CreateCourseState();
}

class _CreateCourseState extends State<CreateCourse> {
  //Creating Database Reference
  final databaseRef = FirebaseDatabase.instance.ref('Course');
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final user = FirebaseAuth.instance.currentUser;

  //loading State
  bool loading = false;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final courseNameController = TextEditingController();
  final courseForController = TextEditingController();
  final startDateController = TextEditingController();
  final courseDescriptionController = TextEditingController();
  final priceController = TextEditingController();
  File? _selectedImage;

  Future<void> _pickImage() async {
    final pickedImage =
        await ImagePicker().pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
    }
  }

  Future<void> _uploadCourseData() async {
    final name = courseNameController.text;
    final description = courseDescriptionController.text;
    final price = priceController.text;
    final startDate = startDateController.text;
    final courseFor = courseForController.text;

    // Check if required fields are not empty
    if (name.isNotEmpty &&
        description.isNotEmpty &&
        price.isNotEmpty &&
        _selectedImage != null) {
      try {
        // Show the progress indicator
        setState(() {
          loading = true;
        });

        // Upload the image to Firebase Storage
        final Reference storageReference =
        _storage.ref().child('course_images/${DateTime.now()}.png');
        final UploadTask uploadTask = storageReference.putFile(_selectedImage!);
        final TaskSnapshot taskSnapshot = await uploadTask.whenComplete(() {});

        // Retrieve the image URL
        final imageUrl = await taskSnapshot.ref.getDownloadURL();

        // Store course data in Firestore
        await FirebaseFirestore.instance.collection('courses').add({
          'title': name,
          'description': description,
          'courseFor': courseFor,
          'startDate': startDate,
          'price': price,
          'thumbnail': imageUrl,
        });

        // Hide the progress indicator
        setState(() {
          loading = false;
        });

        // Display a success message
        Fluttertoast.showToast(msg: "Course added successfully");

        // Navigate to the next page (e.g., for adding lectures)
        Navigator.push(
            context,
            MaterialPageRoute(
                builder: (context) => AddChapterPage(courseId: user!.uid)));

        // Clear input fields and reset image selection
        courseNameController.clear();
        courseDescriptionController.clear();
        priceController.clear();
        setState(() {
          _selectedImage = null;
        });
      } catch (e) {
        // Hide the progress indicator
        setState(() {
          loading = false;
        });

        // Handle any errors (e.g., Firebase storage or Firestore errors)
        Fluttertoast.showToast(msg: "Error: $e");
      }
    } else {
      // Handle case where required fields are empty
      Fluttertoast.showToast(msg: "Please fill in all required fields");
    }
  }




  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        title: const Center(
          child: Text(
            "ADD COURSE",
            style: TextStyle(fontWeight: FontWeight.w600),
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              _selectedImage != null
                  ? SizedBox(
                      height: 200,
                      width: 400,
                      child: Image.file(_selectedImage!),
                    )
                  : ElevatedButton(
                      onPressed: _pickImage,
                      child: SizedBox(
                          height: 200, width: 400, child: Icon(Icons.image, size: 50,)),
                  style: ElevatedButton.styleFrom(
                    primary: Colors.grey, // Background color
                    onPrimary: Colors.white, // Text color
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10), // Padding
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10), // Border radius
                    ),
                  )
              ),
              SizedBox(height: 16),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: courseNameController,
                decoration: const InputDecoration(
                    label: Text("Course Name"),
                    hintText: "EX: Basic Electrical",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.book)),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: startDateController,
                keyboardType: TextInputType.datetime,
                decoration: const InputDecoration(
                    label: Text("Start Date"),
                    hintText: "DD/MM/YEAR",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.calendar_month)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: courseForController,
                decoration: const InputDecoration(
                    label: Text("Course For"),
                    hintText: "JEE/GATE/SSC",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.book)),
              ),
              SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: courseDescriptionController,
                maxLines: 200,
                minLines: 2,
                decoration: const InputDecoration(
                    hintText: "This course is for Beginners to Advance Level",
                    label: Text('About Course'),
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.edit_note)),
              ),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: priceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    label: Text("Amount"),
                    hintText: "2000",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.currency_bitcoin)),
              ),
              const SizedBox(
                height: 20,
              ),
              Stack(
                children: [
                  ElevatedButton(
                    onPressed: loading ? null : _uploadCourseData, // Disable the button when loading
                    child: Text("Upload"),
                  ),
                  if (loading)
                    Center(
                      child: CircularProgressIndicator(),
                    ),
                ],
              )

            ],
          ),
        ),
      ),
    );
  }
}
