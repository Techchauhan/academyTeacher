import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';

class EditProfileScreen extends StatefulWidget {
  final Map<String, dynamic> userData;

  EditProfileScreen(this.userData);

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final TextEditingController _firstNameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _academicYearYearController = TextEditingController();
  final TextEditingController _admissionClassController = TextEditingController();
  final TextEditingController _dobController = TextEditingController();
  final TextEditingController _fatherNameController = TextEditingController();
  final TextEditingController _motherNameController = TextEditingController();
  final TextEditingController _numberController = TextEditingController();
  // Add more controllers for other fields if needed

  @override
  void initState() {
    super.initState();
    _firstNameController.text = widget.userData['firstName'] ?? '';
    _emailController.text = widget.userData['email'] ?? '';
    _academicYearYearController.text = widget.userData['academicYear'] ?? '';
    _admissionClassController.text = widget.userData['admissionClass'] ?? '';
    _dobController.text = widget.userData['dob'] ?? '';
    _fatherNameController.text = widget.userData['fatherName'] ?? '';
    _motherNameController.text = widget.userData['motherName'] ?? '';
    _numberController.text = widget.userData['number'] ?? '';
  }





  void _updateProfile() {
    FirebaseFirestore.instance
        .collection('users')
        .doc(widget.userData['uid'])
        .update({
      'firstName': _firstNameController.text,
      'email': _emailController.text,
      'academicYear': _academicYearYearController.text,
      'admissionClass': _admissionClassController.text,
      'dob': _dobController.text,
      'fatherName': _fatherNameController.text,
      'motherName': _motherNameController.text,
      'number': _numberController.text,
      // Update other fields as needed
    }).then((_) {
      Fluttertoast.showToast(msg: "Update Successfully");
      Navigator.pop(context); // Navigate back to the user details screen
    }).catchError((error) {
      print('Error updating profile: $error');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Edit Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: [
              TextField(
                controller: _firstNameController,
                decoration: InputDecoration(labelText: 'First Name'),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: _emailController,
                decoration: InputDecoration(labelText: 'email'),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: _academicYearYearController,
                decoration: InputDecoration(labelText: 'Academic Year'),
              ),SizedBox(height: 20,),
              TextField(
                controller: _admissionClassController,
                decoration: InputDecoration(labelText: 'Admission Class'),
              ),
              SizedBox(height: 20,),
              TextField(
                keyboardType: TextInputType.datetime,
                controller: _dobController,
                decoration: InputDecoration(labelText: 'DOB'),
              ),SizedBox(height: 20,),
              TextField(
                controller: _fatherNameController,
                decoration: InputDecoration(labelText: 'Father Name'),
              ),
              SizedBox(height: 20,),
              TextField(
                controller: _motherNameController,
                decoration: InputDecoration(labelText: 'Mother Name'),
              ),SizedBox(height: 20,),
              TextField(
                controller: _numberController,
                decoration: InputDecoration(labelText: 'Number'),
              ),
              // Add more text fields for other fields
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateProfile,
                child: Text('Save Changes'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
