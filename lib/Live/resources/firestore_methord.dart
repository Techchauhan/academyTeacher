import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class FiresStoreMethods {
  final FirebaseFirestore _Firestore = FirebaseFirestore.instance;
  final FirebaseAuth _Auth = FirebaseAuth.instance;
  void addToMeetingHistory(String meetingName) async {
    try {
      await _Firestore.collection('liveHistory')
          .doc(_Auth.currentUser!.uid)
          .collection('meetings')
          .add({'meetingName': meetingName, 'createdAt': DateTime.now()});
    } catch (e) {
      print(e);
    }
  }
}
