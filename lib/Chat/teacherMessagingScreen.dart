import 'dart:io';


import 'package:academyteacher/Chat/teacherChatScreen.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:image_picker/image_picker.dart';

class TeacherMessagingScreen extends StatefulWidget {
  final User? currentUser;
  final ChatUser otherUser;

  final Function? onMessageRead;
  TeacherMessagingScreen({required this.currentUser, required this.otherUser, this.onMessageRead});

  @override
  _TeacherMessagingScreenState createState() => _TeacherMessagingScreenState();
}

class _TeacherMessagingScreenState extends State<TeacherMessagingScreen> {
  final ImagePicker _imagePicker = ImagePicker();
  late TextEditingController _messageController;
  bool _receiverHasSeenMessages = false;
  final DatabaseReference _messagesReference =
  FirebaseDatabase.instance.reference().child('messages');

  @override
  void initState() {
    super.initState();
    _messageController = TextEditingController();
  }


  Future<void> _sendImage() async {
    final pickedFile = await _imagePicker.pickImage(source: ImageSource.gallery);

    if (pickedFile != null) {
      final imageFile = File(pickedFile.path);

      // You can upload the image to Firebase Storage and then send a message with the image URL
      // Example: uploadImageToStorage(imageFile);

      // For simplicity, let's assume you're sending the image path as a message
      final newMessageRef = _messagesReference.push();
      newMessageRef.set({
        'senderId': widget.currentUser!.uid,
        'receiverId': widget.otherUser.uid,
        'message': imageFile.path, // Change this to the image URL after uploading
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'isImage': true,
      });
    }
  }

  void _showMenu(BuildContext context) {
    final RenderBox overlay = Overlay.of(context)!.context.findRenderObject() as RenderBox;
    final Offset offset = Offset(overlay.size.width, overlay.size.height);

    showMenu(
      context: context,
      position: RelativeRect.fromLTRB(offset.dx, offset.dy, 0, 0),
      items: <PopupMenuEntry>[
        PopupMenuItem(
          child: Text('About'),
          value: 'about',
        ),
        PopupMenuItem(
          child: Text('Block'),
          value: 'block',
        ),
      ],
      elevation: 8,
    ).then<void>((dynamic newValue) {
      if (newValue == null) return;
      if (newValue == 'about') {
        // Handle about action
        // You can show a dialog or navigate to a new page
      } else if (newValue == 'block') {
        // Handle block action
        // You can show a confirmation dialog or perform a blocking action
      }
    });
  }

  void _sendMessage() {
    final String messageText = _messageController.text.trim();
    if (messageText.isNotEmpty) {
      final newMessageRef = _messagesReference.push();
      newMessageRef.set({
        'senderId': widget.currentUser!.uid,
        'receiverId': widget.otherUser.uid,
        'message': messageText,
        'timestamp': DateTime.now().toUtc().millisecondsSinceEpoch,
        'isRead': false,
      });
      _messageController.clear();
    }
  }
  void _markMessageAsRead(String messageId) {
    _messagesReference.child(messageId).update({
      'isRead': true,
    }).then((_) {
      if (widget.onMessageRead != null) {
        widget.onMessageRead!(); // Call the onMessageRead callback
      }
    });
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(widget.otherUser.displayName),
        actions: [
          PopupMenuButton<String>(
            onSelected: (value) => _showMenu(context),
            itemBuilder: (BuildContext context) {
              return [
                PopupMenuItem(
                  value: 'about',
                  child: Text('About'),
                ),
                PopupMenuItem(
                  value: 'Block',
                  child: Text('Block'),
                ),
                PopupMenuItem(
                  value: 'Reprot',
                  child: Text('Report'),
                ),
              ];
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: StreamBuilder(
              stream: _messagesReference
                  .orderByChild('timestamp')
                  .limitToLast(50)
                  .onValue,
              builder: (context, snapshot) {
                if (snapshot.hasData && snapshot.data != null) {
                  final messagesData = snapshot.data!.snapshot.value as Map?;
                  if (messagesData != null) {
                    final messages = messagesData.values
                        .where((message) =>
                    (message['senderId'] == widget.currentUser!.uid &&
                        message['receiverId'] == widget.otherUser.uid) ||
                        (message['senderId'] == widget.otherUser.uid &&
                            message['receiverId'] == widget.currentUser!.uid))
                        .toList();
                    // messages.reversed.toList();
                    messages.sort((a, b) => a['timestamp'].compareTo(b['timestamp']));
                    return ListView.builder(
                      itemCount: messages.length,
                      itemBuilder: (context, index) {
                        final message = messages[index];
                        final bool isCurrentUser =
                            message['senderId'] == widget.currentUser!.uid;
                        final bool isImage = message['isImage'] ?? false;

                        // Check if the receiver has seen the messages
                        if (!isCurrentUser && !_receiverHasSeenMessages) {
                          _receiverHasSeenMessages = true;
                          // You can add a widget here to indicate that the messages are not seen
                        }

                        return Align(
                          alignment: isCurrentUser
                              ? Alignment.centerRight
                              : Alignment.centerLeft,
                          child: Container(
                            width: 250,
                            margin: const EdgeInsets.symmetric(
                                vertical: 8, horizontal: 16),
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: isCurrentUser
                                  ? Colors.blue.withOpacity(0.2)
                                  : Colors.grey.withOpacity(0.2),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                if (isImage)
                                  Container(
                                    width: 200,
                                    height: 150,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      image: DecorationImage(
                                        fit: BoxFit.cover,
                                        image: FileImage(File(message['message'],)),
                                      ),
                                    ),
                                  )
                                else
                                  Text(
                                    message['message'],
                                    style:   TextStyle(fontSize: 16,
                                      fontWeight: isCurrentUser ? FontWeight.normal : FontWeight.bold,
                                    ),
                                  ),
                                const SizedBox(height: 4),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.end,
                                  children: [
                                    Text(
                                      DateTime.fromMillisecondsSinceEpoch(
                                        message['timestamp'],
                                      ).toLocal().toString(),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.grey,
                                      ),
                                    ),
                                    const Icon(Icons.check)
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    );
                  }
                }
                return const Center(child: CircularProgressIndicator());
              },
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _messageController,
                    decoration: InputDecoration(
                      contentPadding:
                      EdgeInsets.symmetric(horizontal: 16, vertical: 12),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      hintText: 'Type your message...',
                      suffixIcon: IconButton(
                        onPressed: _sendImage,
                        icon: const Icon(Icons.image),
                      ),
                    ),
                  ),
                ),
                IconButton(
                  onPressed: _sendMessage,
                  icon: const Icon(Icons.send),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _messageController.dispose();
    super.dispose();
  }
}



