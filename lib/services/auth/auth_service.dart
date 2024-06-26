import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';

class AuthService extends ChangeNotifier {
  final FirebaseAuth _firebaseAuth = FirebaseAuth.instance;
  final FirebaseFirestore _firebaseFirestore = FirebaseFirestore.instance;
  Future<UserCredential> signInWithEmailandPassword(
      String email, String password) async {
    try {
      UserCredential userCredential = await _firebaseAuth
          .signInWithEmailAndPassword(email: email, password: password);
      _firebaseFirestore.collection('users').doc(userCredential.user!.uid).set(
          {'uid': userCredential.user!.uid, 'email': email},
          SetOptions(merge: true));
      return userCredential;
    } on FirebaseAuthException catch (e) {
      throw Exception(e.code);
    }
  }

  Future<User?> signUpWithEmailandPassword(
      String email, String password, String username) async {
    try {
      UserCredential result = await _firebaseAuth
          .createUserWithEmailAndPassword(email: email, password: password);
      User? user = result.user;

      // Save the user details to Firestore
      await _firebaseFirestore.collection('users').doc(user?.uid).set({
        'uid': user!.uid,
        'email': email,
        'username': username,
      });

      return user;
    } catch (e) {
      print(e.toString());
      return null;
    }
  }

  Future<void> SingOut() async {
    return await FirebaseAuth.instance.signOut();
  }
}
