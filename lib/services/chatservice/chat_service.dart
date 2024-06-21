import 'dart:io';
import 'package:path/path.dart' as Path;
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:chat/model/message.dart';

class ChatService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<void> sendMessage(String reciverId, String message, String username,
      {required bool isImage}) async {
    final String currentUserId = _firebaseAuth.currentUser!.uid;
    final String currentUsername =
        _firebaseAuth.currentUser!.displayName.toString();
    final String currentUserEmail = _firebaseAuth.currentUser!.email.toString();
    final Timestamp timestamp = Timestamp.now();
    Message newMessage = Message(
        SenderUsername: currentUsername,
        message: message,
        timestamp: timestamp,
        ReciverId: reciverId,
        SenderEmail: currentUserEmail,
        SenderId: currentUserId,
        isImage: isImage);

    List<String> ids = [currentUserId, reciverId];
    ids.sort();
    String chatRoomId = ids.join("_");

    await _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .add(newMessage.toMap());
  }

  Future<void> sendImage(
      String receiverUserId, File image, String receiverUsername) async {
    // Upload image to Firebase Storage
    final ref =
        _storage.ref().child('images/${DateTime.now().millisecondsSinceEpoch}');
    final uploadTask = ref.putFile(image);
    final url =
        await uploadTask.then((snapshot) => snapshot.ref.getDownloadURL());

    // Now you can use the uploaded image URL
    print('Uploaded image URL: $url');

    // Send image URL to chat
    await sendMessage(receiverUserId, url, receiverUsername, isImage: true);
  }

  Stream<QuerySnapshot> getMessage(String userId, String otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join("_");

    return _firestore
        .collection('chat_rooms')
        .doc(chatRoomId)
        .collection('messages')
        .orderBy('timestamp', descending: false)
        .snapshots();
  }
}
