import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SlideshowImage {
  final String imageUrl;

  SlideshowImage(this.imageUrl);
}

class ViewSlideShow extends StatelessWidget {
  FirebaseFirestore firestore = FirebaseFirestore.instance;
  List<SlideshowImage> slideshowImages = [];

  ViewSlideShow({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Student Application'),
      ),
      body: StreamBuilder(
        stream: firestore.collection('slideshow').snapshots(),
        builder: (context, snapshot) {
          if (!snapshot.hasData) {
            return Center(child: CircularProgressIndicator());
          }

          var slideshowDocs = snapshot.data!.docs;

          slideshowImages = slideshowDocs
              .map((doc) => SlideshowImage(doc['image_url']))
              .toList();

          return Container(
            height: 200,
            width: 400,
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: slideshowImages.length,
              itemBuilder: (context, index) {
                return Container(
                  width: 300,
                  height: 200,
                  margin: EdgeInsets.all(8),
                  child: Image.network(
                    slideshowImages[index].imageUrl,
                    fit: BoxFit.cover,
                  ),
                );
              },
            ),
          );
        },
      ),
    );
  }
}


