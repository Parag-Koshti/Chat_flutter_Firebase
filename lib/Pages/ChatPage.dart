import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:chat/services/chatservice/chat_service.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:shimmer/shimmer.dart';

class ChatPage extends StatefulWidget {
  final String reciverUserEmail;
  final String reciverUserID;
  final String reciverUsername;

  const ChatPage({
    super.key,
    required this.reciverUserEmail,
    required this.reciverUserID,
    required this.reciverUsername,
  });

  @override
  State<ChatPage> createState() => _ChatPageState();
}

class _ChatPageState extends State<ChatPage> {
  final TextEditingController _messageController = TextEditingController();
  final ChatService _chatService = ChatService();
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final ImagePicker _imagePicker = ImagePicker();

  File? _image;

  @override
  void initState() {
    super.initState();
  }

  void sendMessage() async {
    if (_messageController.text.isNotEmpty) {
      await _chatService.sendMessage(
        widget.reciverUserID,
        _messageController.text,
        widget.reciverUsername,
        isImage: false,
      );
      _messageController.clear();
    } else {
      print("Error: Message is empty");
    }
  }

  Future<void> sendImage() async {
    if (_image != null) {
      final storageRef = FirebaseStorage.instance.ref();
      final uploadTask = storageRef
          .child('images/${DateTime.now().millisecondsSinceEpoch}')
          .putFile(_image!);
      final snapshot = await uploadTask.whenComplete(() => null);
      final url = await snapshot.ref.getDownloadURL();

      // Store the image URL in Firestore
      await _chatService.sendMessage(
        widget.reciverUserID,
        url,
        widget.reciverUsername,
        isImage: true,
      );
      _image = null; // Clear the selected image after sending
    } else {
      print("Error: No image selected");
    }
  }

  Future<void> _selectAndSendImage() async {
    final XFile? image =
        await _imagePicker.pickImage(source: ImageSource.camera);
    if (image != null) {
      final File file = File(image.path);
      _image = file;
      await sendImage();
      _image = null;
    } else {
      print("No image selected");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Column(
          children: [
            _appBar(),
            Expanded(child: _buildMessageList()),
            _messageInput()
          ],
        ),
      ),
    );
  }

  Widget _buildMessageList() {
    return StreamBuilder(
      stream: _chatService.getMessage(
          _firebaseAuth.currentUser!.uid, widget.reciverUserID),
      builder: (context, AsyncSnapshot<QuerySnapshot> snapshot) {
        if (snapshot.hasError) {
          return Center(child: Text("Error"));
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        }
        return ListView(
          children: snapshot.data!.docs
              .map((document) => _MessageList(document))
              .toList(),
        );
      },
    );
  }

  Widget _MessageList(DocumentSnapshot document) {
    Map<String, dynamic> data = document.data() as Map<String, dynamic>;
    var isCurrentUser = data['SenderId'] == _firebaseAuth.currentUser!.uid;
    var alignment = isCurrentUser ? Alignment.topRight : Alignment.topLeft;
    var bgColor = isCurrentUser ? Colors.blue : Colors.grey[200];
    var textColor = isCurrentUser ? Colors.white : Colors.black;
    var timestamp = data['timestamp'] != null
        ? (data['timestamp'] as Timestamp).toDate()
        : DateTime.now();
    var formattedTime = DateFormat('hh:mm a').format(timestamp);

    return data['isImage'] == true
        ? Padding(
            padding: const EdgeInsets.all(8.0),
            child: Container(
              alignment: alignment,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: 150,
                  height: 150,
                  child: CachedNetworkImage(
                    fit: BoxFit.cover,
                    // color: Colors.transparent,
                    imageUrl: data['message'],
                    placeholder: (context, url) => _buildSkeletonView(),
                    errorWidget: (context, url, error) => Icon(Icons.error),
                  ),
                ),
              ),
            ),
          )
        : Container(
            alignment: alignment,
            child: Column(
              crossAxisAlignment: isCurrentUser
                  ? CrossAxisAlignment.end
                  : CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 25),
                  margin: EdgeInsets.symmetric(vertical: 5, horizontal: 10),
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(25),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.grey.withOpacity(0.5),
                        spreadRadius: 1,
                        blurRadius: 2,
                      ),
                    ],
                  ),
                  child: Column(
                    crossAxisAlignment: isCurrentUser
                        ? CrossAxisAlignment.end
                        : CrossAxisAlignment.start,
                    children: [
                      Text(
                        data['message'],
                        style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      SizedBox(height: 5),
                      Text(
                        formattedTime,
                        style: TextStyle(
                          color: textColor.withOpacity(0.7),
                          fontSize: 12,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          );
  }

  Widget _messageInput() {
    return Container(
      padding: EdgeInsets.all(10),
      decoration: BoxDecoration(
        color: Colors.white,
        boxShadow: [
          BoxShadow(
            color: Colors.grey.withOpacity(0.5),
            spreadRadius: 2,
            blurRadius: 5,
          ),
        ],
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(
              onPressed: () async {
                print('_messageInput: camera button pressed');
                await _selectAndSendImage();
              },
              icon: Icon(CupertinoIcons.camera_fill)),
          IconButton(onPressed: () {}, icon: Icon(CupertinoIcons.photo)),
          Expanded(
            child: TextField(
              controller: _messageController,
              decoration: InputDecoration(
                suffixIcon: Container(
                  margin: EdgeInsets.all(5),
                  child: CircleAvatar(
                    radius: 10,
                    backgroundColor: Colors.blue,
                    child: IconButton(
                        onPressed: sendMessage,
                        icon: Icon(
                          CupertinoIcons.arrow_up,
                          size: 16,
                          color: Colors.white,
                        )),
                  ),
                ),
                contentPadding: EdgeInsets.all(10),
                hintText: "Enter Message Here",
                hintStyle: TextStyle(color: Colors.grey),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(35),
                  borderSide: BorderSide(color: Colors.grey),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _appBar() {
    return Material(
      elevation: 5,
      child: Container(
        height: MediaQuery.of(context).size.height * 0.1,
        decoration: BoxDecoration(color: Colors.grey[200]),
        child: Row(
          children: [
            SizedBox(
              height: 5,
            ),
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: Icon(
                  Icons.arrow_back_ios,
                  color: Colors.blue,
                )),
            SizedBox(
              width: MediaQuery.of(context).size.height * 0.12,
            ),
            Column(
              children: [
                CircleAvatar(
                  radius: 25,
                  backgroundImage: AssetImage('assets/women8.png'),
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(
                  height: 5,
                ),
                Text(
                  widget.reciverUsername,
                  style: TextStyle(fontSize: 15),
                ),
              ],
            )
          ],
        ),
      ),
    );
  }

  Widget _buildSkeletonView() {
    return Container(
      width: 150,
      height: 150,
      child: Shimmer.fromColors(
        baseColor: Colors.grey.shade300, // Change to your desired base color
        highlightColor:
            Colors.grey.shade100, // Change to your desired highlight color
        child: Container(
          width: 450.0,
          height: 300.0,
          decoration: BoxDecoration(
              color: Colors.grey, borderRadius: BorderRadius.circular(15)),
        ),
      ),
    );
  }
}
