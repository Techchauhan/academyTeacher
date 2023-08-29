import 'dart:io';

import 'package:academyteacher/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(TeacherApp());
}

class TeacherApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Teacher App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: CreateLiveCourse(),
    );
  }
}

class CreateLiveCourse extends StatefulWidget {
  @override
  _CreateLiveCourseState createState() => _CreateLiveCourseState();
}

class _CreateLiveCourseState extends State<CreateLiveCourse> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final TextEditingController _courseNameController = TextEditingController();
  final TextEditingController _courseDurationController = TextEditingController();
  final TextEditingController _courseStartDateController = TextEditingController();
  final TextEditingController _courseEndDateController = TextEditingController();
  final TextEditingController _coursePriceController = TextEditingController();
  final TextEditingController _discountController = TextEditingController();
  final TextEditingController _basicDetailsController = TextEditingController();

    late   File _thumbnailImage;
  @override
  void initState() {
    super.initState();
    _thumbnailImage = File(''); // Initialize with an empty File
  }
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _thumbnailImage = File(pickedImage.path);
      });
    }
  }

  Future<String> _uploadThumbnailImage(String courseId) async {
    final Reference storageRef = _storage.ref().child('thumbnails').child(courseId);

    final TaskSnapshot snapshot = await storageRef.putFile(_thumbnailImage);

    final String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<void> _createCourse(
      String courseName,
      int courseDuration,
      DateTime startDate,
      DateTime endDate,
      double price,
      double discount,
      String basicDetails,
      ) async {
    try {
      final double discountedPrice = price - (price * (discount / 100));

      // Upload thumbnail to Firebase Storage and get its URL
      String thumbnailUrl = '';
      if (_thumbnailImage != null) {
        thumbnailUrl = await _uploadThumbnailImage(courseName);
        // Code to upload thumbnail image and get the URL
        // Replace this with actual implementation using Firebase Storage
      }

      await _firestore.collection('live-courses').add({
        'courseName': courseName,
        'courseDuration': courseDuration,
        'startDate': startDate,
        'endDate': endDate,
        'price': price,
        'discount': discount,
        'discountedPrice': discountedPrice,
        'thumbnailUrl': thumbnailUrl,
        'basicDetails': basicDetails,
        'sessions': [],
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Course created successfully.'),
      ));
    } catch (error) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('Error creating course.'),
      ));
    }
  }



  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid)));
        return false;
      },
      child: Scaffold(
        appBar: AppBar(
          leading: BackButton(
            onPressed: (){
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid)));

            },
          ) ,
          title: const Text('Create Live Course'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: SingleChildScrollView(
            child: Column(
              children: [
                GestureDetector(
                  onTap: _pickImage,
                  child: Container(
                    height: 150,
                    color: Colors.grey[300],
                    child: _thumbnailImage != null
                        ? Image.file(
                      _thumbnailImage,
                      height: 150,
                    )
                        : Container(
                      child: const Center(
                        child: Icon(Icons.image),
                      ),
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseNameController,
                  decoration: const InputDecoration(
                    labelText: 'Course Name',
                    prefixIcon: Icon(Icons.text_fields),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _courseDurationController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText:  'Course Duration (years)',
                    prefixIcon: Icon(Icons.timer),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: _courseStartDateController,
                  decoration: const InputDecoration(
                    labelText: 'Start Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now(),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365)),
                    );
                    if (picked != null) {
                      setState(() {
                        _courseStartDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  readOnly: true,
                  controller: _courseEndDateController,
                  decoration: const InputDecoration(
                    labelText: 'End Date',
                    prefixIcon: Icon(Icons.calendar_today),
                  ),
                  onTap: () async {
                    final DateTime? picked = await showDatePicker(
                      context: context,
                      initialDate: DateTime.now().add(const Duration(days: 7)),
                      firstDate: DateTime.now(),
                      lastDate: DateTime.now().add(const Duration(days: 365 * 2)),
                    );
                    if (picked != null) {
                      setState(() {
                        _courseEndDateController.text = DateFormat('yyyy-MM-dd').format(picked);
                      });
                    }
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _coursePriceController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Price',
                    prefixIcon: Icon(Icons.monetization_on),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _discountController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(
                    labelText: 'Discount (%)',
                    prefixIcon: Icon(Icons.local_offer),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _basicDetailsController,
                  maxLines: 4,
                  decoration: const InputDecoration(
                    labelText: 'Basic Details',
                    prefixIcon: Icon(Icons.description),
                  ),
                ),
                const SizedBox(height: 16),
                ElevatedButton(
                  onPressed: () {
                    final courseName = _courseNameController.text;
                    final courseDuration = int.tryParse(_courseDurationController.text) ?? 0;
                    final startDate = DateFormat('yyyy-MM-dd').parse(_courseStartDateController.text);
                    final endDate = DateFormat('yyyy-MM-dd').parse(_courseEndDateController.text);
                    final price = double.tryParse(_coursePriceController.text) ?? 0;
                    final discount = double.tryParse(_discountController.text) ?? 0;
                    final basicDetails = _basicDetailsController.text;

                    if (courseName.isNotEmpty &&
                        courseDuration > 0 &&
                        startDate != null &&
                        endDate != null &&
                        price > 0 &&
                        discount >= 0 &&
                        discount <= 100 &&
                        basicDetails.isNotEmpty) {
                      _createCourse(
                          courseName, courseDuration, startDate, endDate, price, discount, basicDetails);
                    }
                  },
                  child: const Text('Create Course'),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
