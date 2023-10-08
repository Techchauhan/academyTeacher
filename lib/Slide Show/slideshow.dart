import 'package:academyteacher/Authentication/myHomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter_speed_dial/flutter_speed_dial.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class SlideshowImage {
  final String imageUrl;
  final String docId;

  SlideshowImage(this.imageUrl, this.docId);
}

class AddingSlideShow extends StatefulWidget {
  @override
  _AddingSlideShowState createState() => _AddingSlideShowState();
}

class _AddingSlideShowState extends State<AddingSlideShow> {
  final picker = ImagePicker();
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  late Slideshow _slideshow;

  @override
  void initState() {
    super.initState();
    _slideshow = Slideshow();
    _loadImagesFromFirestore();
  }

  Future<void> _loadImagesFromFirestore() async {
    var snapshot = await firestore.collection('slideshow').get();
    var images = snapshot.docs.map((doc) {
      return SlideshowImage(doc['image_url'], doc.id);
    }).toList();

    setState(() {
      _slideshow.images = images;
    });
  }

  Future<void> _uploadImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      var imageFile = File(pickedFile.path);
      var fileName = DateTime.now().toString() + '.jpg';
      Reference storageRef = storage.ref().child('slideshow_images/$fileName');

      UploadTask uploadTask = storageRef.putFile(imageFile);

      TaskSnapshot taskSnapshot = await uploadTask;
      if (taskSnapshot.state == TaskState.success) {
        String imageUrl = await storageRef.getDownloadURL();
        DocumentReference docRef =
        await firestore.collection('slideshow').add({'image_url': imageUrl});
        String docId = docRef.id;

        setState(() {
          _slideshow.addImage(SlideshowImage(imageUrl, docId));
        });
      } else {
        print('Image upload failed.');
      }
    }
  }

  Future<void> _removeImage(String docId, String imageUrl) async {
    // Delete image from Firebase Storage
    Reference storageRef = FirebaseStorage.instance.refFromURL(imageUrl);
    await storageRef.delete();

    // Delete image data from Firestore
    await firestore.collection('slideshow').doc(docId).delete();

    setState(() {
      _slideshow.removeImage(docId);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Add Slide Show'),
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [

          Expanded(
            child: ListView.builder(
              itemCount: _slideshow.images.length,
              itemBuilder: (context, index) {
                var image = _slideshow.images[index];
                return Container(
                  decoration: BoxDecoration(color: Colors.cyanAccent, borderRadius: BorderRadius.circular(20) ),
                  width:  MediaQuery.of(context).size.width,
                  margin: EdgeInsets.all(10),
                  child: Column(
                    children: [
                      Image.network(
                        image.imageUrl,
                        width: MediaQuery.of(context).size.width,
                        height: 200,
                        fit: BoxFit.cover,
                      ),
                      TextButton(
                        onPressed: () => _removeImage(image.docId, image.imageUrl),
                        child: Text('Remove'),
                      ),
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      floatingActionButton: SpeedDial(
        activeIcon: Icons.add,
       icon: Icons.add,
       label: Text("Add Image"),
      onPress: _uploadImage,
      ),
    );
  }
}

class Slideshow {
  List<SlideshowImage> images = [];

  void addImage(SlideshowImage image) {
    images.add(image);
  }

  void removeImage(String docId) {
    images.removeWhere((image) => image.docId == docId);
  }
}

