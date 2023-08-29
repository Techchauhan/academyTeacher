import 'package:academyteacher/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class UpdateScreen extends StatelessWidget {


  final user = FirebaseAuth.instance.currentUser;
  final String courseId;
  final String initialTitle;
  final String initialDescription;
  final String initalprice;
  final DatabaseReference _databaseReference =
      FirebaseDatabase.instance.reference();

  UpdateScreen(
      {required this.initialTitle,
      required this.initialDescription,
      required this.initalprice,
      required this.courseId});

  //Update Course Function

  @override
  Widget build(BuildContext context) {
    final TextEditingController titleController =
        TextEditingController(text: initialTitle);
    final TextEditingController descriptionController =
        TextEditingController(text: initialDescription);
    final TextEditingController priceController =
        TextEditingController(text: initalprice);

    void _updateCourse() {
      final updatedTitle = titleController.text;
      final updatedDescription = descriptionController.text;
      final updatedPrice = priceController.text;

      if (updatedTitle.isNotEmpty &&
          updatedDescription.isNotEmpty &&
          updatedPrice.isNotEmpty) {
        _databaseReference.child('courses/$courseId').update({
          'title': updatedTitle,
          'description': updatedDescription,
          'price': updatedPrice,
        });
        Fluttertoast.showToast(msg: 'Course Updated Successfully');
        Navigator.pushReplacement(
            context,
            MaterialPageRoute(
                builder: (context) =>
                    MyHomePage(user: user!.uid))); // Return to the previous screen after update
      }
    }

    return Scaffold(
      appBar: AppBar(title: Text('Update Course')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 25),
          child: Column(
            children: [
              // _selectedImage != null
              //     ? Container(
              //   height: 200, width: 400,
              //   child:   Image.file(_selectedImage!),
              // )
              //     : ElevatedButton(onPressed: _pickImage, child: Container(
              //     height: 200, width: 400,
              //     child: Icon(Icons.image))),
              SizedBox(height: 16),
              const SizedBox(
                height: 10,
              ),
              TextFormField(
                controller: titleController,
                decoration: const InputDecoration(
                    label: Text("Course Name"),
                    hintText: "Basic Electrical",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.book)),
              ),
              const SizedBox(
                height: 20,
              ),
              TextFormField(
                controller: descriptionController,
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
                    // hintText: "Enter Amount",
                    border: OutlineInputBorder(),
                    suffixIcon: Icon(Icons.currency_bitcoin)),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(onPressed: _updateCourse, child: Text("Update"))
            ],
          ),
        ),
      ),


    );
  }
}
