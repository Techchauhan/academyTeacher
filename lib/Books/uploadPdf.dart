import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:file_picker/file_picker.dart';
import 'dart:io';

class UploadPdfPage extends StatefulWidget {
  @override
  _UploadPdfPageState createState() => _UploadPdfPageState();
}

class _UploadPdfPageState extends State<UploadPdfPage> {
  String _selectedCategory = 'Hindi';
  String _selectedClass = 'Class 1';
  File? _pdfFile;
  bool _isUploading = false;

  Future<void> _selectPdf() async {


    FilePickerResult? result = await FilePicker.platform.pickFiles(

    );

    if (result != null && result.files.isNotEmpty) {
      File selectedFile = File(result.files.single.path!);

      if (await selectedFile.exists()) {
        setState(() {
          _pdfFile = selectedFile;
        });
      } else {
        // Handle the case where the selected file does not exist
        // You can show an error message or take appropriate action here
      }
    } else {
      // No file selected or user canceled
      // You can show an error or a message here
    }
  }

  Future<void> _uploadPdf() async {
    setState(() {
      _isUploading = true;
    });

    if (_pdfFile == null) {
      // No file selected, show an error or toast message
      setState(() {
        _isUploading = false;
      });
      return;
    }

    try {
      final Reference storageReference = FirebaseStorage.instance
          .ref()
          .child('books/$_selectedCategory/$_selectedClass/${DateTime.now().millisecondsSinceEpoch}.pdf');

      final UploadTask uploadTask = storageReference.putFile(_pdfFile!);

      await uploadTask.whenComplete(() {
        // File uploaded successfully
        // You can add further logic here, such as updating a database with the download URL
        setState(() {
          _isUploading = false;
        });
      });
    } catch (e) {
      print('Error uploading PDF: $e');
      // Handle the error
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: ()async{
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context)=>MyHomePage(user: FirebaseAuth.instance.currentUser!.uid)));
        return true;
      },
      child: Scaffold(
        appBar: AppBar(
          title: Text('Upload PDF'),
        ),
        body: Padding(
          padding: EdgeInsets.all(16.0),
          child: Column(
            children: <Widget>[
              ElevatedButton(
                onPressed: () {
                  _selectPdf(); // Call the _selectPdf function when the "Select" button is pressed
                },
                child: Text("Select PDF"),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedCategory,
                onChanged: (value) {
                  setState(() {
                    _selectedCategory = value!;
                  });
                },
                items: <String>['Hindi', 'English', 'Maths', 'Science']
                    .map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),
              SizedBox(height: 20),
              DropdownButton<String>(
                value: _selectedClass,
                onChanged: (value) {
                  setState(() {
                    _selectedClass = value!;
                  });
                },
                items: <String>[
                  'Class 1',
                  'Class 2',
                  'Class 3',
                  // Add more classes as needed
                ].map<DropdownMenuItem<String>>((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
              ),

              SizedBox(height: 20),
              Center(
                child: ElevatedButton(
                  onPressed: _isUploading ? null : _uploadPdf,
                  child: _isUploading ? CircularProgressIndicator() : Text('Upload PDF'),
                ),
              ),

            ],
          ),
        ),
      ),
    );
  }
}
