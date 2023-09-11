import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:academyteacher/provider/userIdProvider.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:lottie/lottie.dart';
import 'package:provider/provider.dart';

class SignUpPage extends StatefulWidget {
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _teachingSubjectController = TextEditingController();
  final TextEditingController _numberController = TextEditingController(text: "+91 ");
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _teachingExperience = TextEditingController();
  final TextEditingController _qualificationController = TextEditingController();
  final String photourl = 'https://firebasestorage.googleapis.com/v0/b/academy-643bb.appspot.com/o/teacher_images%2Fdefaultprofilepicture.jpg?alt=media&token=42220e88-e2b3-45ae-9c99-dde7c0d759f0';

  final String _selectedSubject = 'Hindi';
  final String _selectedExperience = '1 Year';
  final String _selectedQualification = 'Btech';

  final List<String> _subjects = ['Hindi', 'English', 'Maths', 'Physics', 'Chemistry', 'Bio'];
  final List<String> _experiences = ['1 Year', '2 Years', '3 Years', '4 Years', '5 Years', '6 Years', '7 Years', '8 Years', '9 Years', '10 Years', '11 Years', '12 Years', '13 Years', '15 Years', 'More than 15 Years'];
  final List<String> _qualifications = ['Btech', 'Mtech', 'BSC', 'MSC'];

  void _signUp(BuildContext context) async {
    try {
      final UserCredential userCredential = await FirebaseAuth.instance.createUserWithEmailAndPassword(
        email: _emailController.text,
        password: _passwordController.text,
      );

      await FirebaseFirestore.instance.collection('teachers').doc(userCredential.user!.uid).set({
        'email': _emailController.text,
        'name': _nameController.text,
        'number': _numberController.text,
        'teachingSubject': _teachingSubjectController.text,
        'teachingExperience': _teachingExperience.text,
        'qualification': _qualificationController.text,
        'profilePhoto': photourl,
        // You can add other fields as needed
      });

      final userIdProvider = Provider.of<UserIdProvider>(context, listen: false);
      userIdProvider.setUserId(userCredential.user!.uid); // Set the user ID

      Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => MyHomePage(user: userCredential.user!.uid)));
    } catch (e) {
      print("Error: $e");
      // Handle registration error
    }
  }

  @override
  void dispose() {
    _nameController.dispose();
    _teachingSubjectController.dispose();
    _numberController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _teachingExperience.dispose();
    _qualificationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(),
      body: SingleChildScrollView(
        child: Center(
          child: Padding(
            padding: EdgeInsets.all(16.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SizedBox(
                  height: 180,
                  child: Center(
                    child: LottieBuilder.network(
                        'https://lottie.host/52e44b04-46f3-4496-bd8e-78bd6c2d202f/VW08s2KNIn.json'),
                  ),
                ),
                const Center(
                  child: Text(
                    "Teacher Signup",
                    style: TextStyle(fontSize: 20),
                  ),
                ),
                const SizedBox(
                  height: 20,
                ),
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    label: Text("Enter Name"),
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _emailController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Enter Email",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),
                TextFormField(
                  controller: _numberController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Number",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),


                // Dropdown for Teaching Subject
                DropdownButtonFormField<String>(
                  value: _selectedSubject,
                  items: _subjects.map((String subject) {
                    return DropdownMenuItem<String>(
                      value: subject,
                      child: Text(subject),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _teachingSubjectController.text = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Teaching Subject",
                  ),
                ),

                const SizedBox(
                  height: 10,
                ),

                // Dropdown for Teaching Experience
                DropdownButtonFormField<String>(
                  value: _selectedExperience,
                  items: _experiences.map((String experience) {
                    return DropdownMenuItem<String>(
                      value: experience,
                      child: Text(experience),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _teachingExperience.text = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Teaching Experience",
                  ),
                ),
                const SizedBox(
                  height: 10,
                ),

                // Dropdown for Qualification
                DropdownButtonFormField<String>(
                  value: _selectedQualification,
                  items: _qualifications.map((String qualification) {
                    return DropdownMenuItem<String>(
                      value: qualification,
                      child: Text(qualification),
                    );
                  }).toList(),
                  onChanged: (String? newValue) {
                    setState(() {
                      _qualificationController.text = newValue!;
                    });
                  },
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Qualification",
                  ),
                ),

                const SizedBox(height: 16),

                TextFormField(
                  controller: _passwordController,
                  decoration: InputDecoration(
                    border: OutlineInputBorder(),
                    labelText: "Set Password",
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () => _signUp(context),
                  child: Text("Sign Up"),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.push(context, MaterialPageRoute(builder: (context) => SignUpPage()));
                  },
                  child: const Text("Already have an account? Log in"),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
