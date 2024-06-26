import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String SenderUsername;
  final String message;
  final Timestamp timestamp;
  final String ReciverId;
  final String SenderEmail;
  final String SenderId;
  final bool isImage;
  final String? mediaUrl; // URL of the media (image or video)
  final bool hasMedia; // New field to indicate media presence

  Message({
    required this.SenderUsername,
    required this.message,
    required this.timestamp,
    required this.ReciverId,
    required this.SenderEmail,
    required this.SenderId,
    this.isImage = false,
    this.mediaUrl, // Add mediaUrl to store image or video URL
    this.hasMedia = false, // Indicates if there is any media
  });

  Map<String, dynamic> toMap() {
    return {
      'SenderUsername': SenderUsername,
      'message': message,
      'timestamp': timestamp,
      'ReciverId': ReciverId,
      'SenderEmail': SenderEmail,
      'SenderId': SenderId,
      'isImage': isImage,
      'mediaUrl': mediaUrl, // Include the mediaUrl in the map
      'hasMedia': hasMedia, // Include hasMedia in the map
    };
  }

  factory Message.fromMap(Map<String, dynamic> map) {
    return Message(
      SenderUsername: map['SenderUsername'],
      message: map['message'],
      timestamp: map['timestamp'],
      ReciverId: map['ReciverId'],
      SenderEmail: map['SenderEmail'],
      SenderId: map['SenderId'],
      isImage: map['isImage'] ?? false,
      mediaUrl: map['mediaUrl'], // Assign mediaUrl from the map
      hasMedia: map['hasMedia'] ?? false, // Assign hasMedia from the map
    );
  }
}
