// import 'dart:convert';
// import 'package:http/http.dart' as http;
// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_messaging/firebase_messaging.dart';
//
// class FirebaseApi {
//   final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
//   final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
//
//   Future<void> initNotification() async {
//     try {
//       await _firebaseMessaging.requestPermission();
//       final fcmToken = await _firebaseMessaging.getToken();
//       print('FCM Token: $fcmToken');
//     } catch (e) {
//       print('Error initializing notification: $e');
//     }
//   }
//
//   Future<void> sendNotification(
//     String receiverUserId,
//     String receiverUsername,
//     String message,
//   ) async {
//     try {
//       final response = await http.post(
//         Uri.parse('https://fcm.googleapis.com/fcm/send'),
//         headers: <String, String>{
//           //    'Content-Type': 'application/json',
//           'Authorization':
//               'key=AIzaSyA1cegEIWXzGt_y1nII6fsH98818uj3eQM', // Replace with your actual server key
//         },
//         body: jsonEncode(
//           <String, dynamic>{
//             'notification': <String, dynamic>{
//               'title':
//                   'New message from ${_firebaseAuth.currentUser!.displayName}',
//               'body': '$receiverUsername: $message',
//             },
//             'priority': 'high',
//             'to': '/topics/$receiverUserId',
//           },
//         ),
//       );
//
//       if (response.statusCode == 200) {
//         print('Notification sent successfully');
//       } else {
//         print('Failed to send notification: ${response.statusCode}');
//         print('Response body: ${response.body}');
//       }
//     } catch (e) {
//       print('Error sending notification: $e');
//     }
//   }
// }
