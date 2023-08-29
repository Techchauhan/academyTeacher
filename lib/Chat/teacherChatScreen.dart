import 'package:academyteacher/Chat/teacherMessagingScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class TeacherChatScreen extends StatefulWidget {
  @override
  _TeacherChatScreenState createState() => _TeacherChatScreenState();
}

class _TeacherChatScreenState extends State<TeacherChatScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? _currentUser;
  List<ChatUser> _users = [];
  Set<String> _teachersWithUnreadMessages = Set();

  @override
  void initState() {
    super.initState();
    _currentUser = _auth.currentUser;
    _loadUsers();
    _checkUnreadMessages();
  }



  String _searchQuery = '';

  List<ChatUser> get _filteredUsers {
    return _users.where((user) {
      final displayName = user.displayName.toLowerCase();
      final searchQuery = _searchQuery.toLowerCase();
      return displayName.contains(searchQuery);
    }).toList();
  }

  Future<void> _loadUsers() async {
    final snapshot = await _firestore.collection('teachers').get();
    print("User data fetched: ${snapshot.docs.length} documents");

    setState(() {
      _users = snapshot.docs
          .where((doc) => doc.id != _currentUser!.uid)
          .map((doc) => ChatUser.fromSnapshot(doc))
          .toList();
    });
    print("Users loaded: ${_users.length}");
  }

  Future<void> _checkUnreadMessages() async {
    final snapshot = await _firestore
        .collection('messages')
        .where('receiverId', isEqualTo: _currentUser!.uid)
        .where('isRead', isEqualTo: false)
        .get();

    final teachersWithUnreadMessages = snapshot.docs
        .map((doc) => doc['senderId'] as String)
        .toSet();

    setState(() {
      _teachersWithUnreadMessages = teachersWithUnreadMessages;
    });
  }


  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(10.0),
          child: TextFormField(
            decoration: InputDecoration(
                contentPadding: EdgeInsets.symmetric(horizontal: 20),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30), // Adjust the radius as needed
                ),
                hintText: 'Find Your Class Mate',
                suffixIcon: Icon(Icons.search)
            ),
            onChanged: (value) {
              setState(() {
                _searchQuery = value;
              });
            },
          ),
        ),
        Expanded(
          child: ListView.builder(
            itemCount: _filteredUsers.length,
            itemBuilder: (context, index) {
              final chatUser = _filteredUsers[index];
              final hasUnreadMessages =
              _teachersWithUnreadMessages.contains(chatUser.uid);

              return ListTile(
                tileColor: hasUnreadMessages ? Colors.yellow.withOpacity(0.3) : null,
                title: Text(_filteredUsers[index].displayName),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => TeacherMessagingScreen(
                        currentUser: _currentUser!,
                        otherUser: _filteredUsers[index],
                        onMessageRead: () {
                          _checkUnreadMessages(); // Refresh unread messages after viewing messages
                        },
                      ),
                    ),
                  );
                },
              );
            },
          ),
        ),
      ],
    );
  }
}

class ChatUser {
  final String uid;
  final String displayName;

  ChatUser({required this.uid, required this.displayName});

  factory ChatUser.fromSnapshot(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>;
    final displayName = data['name'] as String? ?? 'Unknown'; // Provide a default value if null
    return ChatUser(uid: snapshot.id, displayName: displayName);
  }
}



