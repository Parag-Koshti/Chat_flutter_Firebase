import 'package:cloud_firestore/cloud_firestore.dart';

class Message {
  final String SenderUsername;
  final String message;
  final Timestamp timestamp;
  final String ReciverId;
  final String SenderEmail;
  final String SenderId;
  final bool isImage;

  Message({
    required this.SenderUsername,
    required this.message,
    required this.timestamp,
    required this.ReciverId,
    required this.SenderEmail,
    required this.SenderId,
    this.isImage = false, // Add a flag to indicate if the message is an image
  });

  Map<String, dynamic> toMap() {
    return {
      'SenderUsername': SenderUsername,
      'message': message,
      'timestamp': timestamp,
      'ReciverId': ReciverId,
      'SenderEmail': SenderEmail,
      'SenderId': SenderId,
      'isImage': isImage, // Include the isImage flag in the map
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
      isImage:
          map['isImage'] ?? false, // Default to false if the field is missing
    );
  }
}
