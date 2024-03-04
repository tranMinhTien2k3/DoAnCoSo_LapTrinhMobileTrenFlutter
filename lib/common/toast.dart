import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
void showToast({required String message}){
  Fluttertoast.showToast(
      msg: message,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 1,
      backgroundColor: Colors.blue,
      textColor: Colors.white,
      fontSize: 16.0
  );
}
void signOut(context){
  FirebaseAuth.instance.signOut();
  Navigator.pushNamed(context, "/home");
}
CollectionReference users = FirebaseFirestore.instance.collection("Users");

Future<Uint8List> generateThumbnail(String videoUrl) async {
  final thumbnail = await VideoThumbnail.thumbnailData(
    video: videoUrl,
    timeMs: 1000,
    imageFormat: ImageFormat.WEBP,
    maxHeight: 64,
    quality: 75,
  );
  return thumbnail!;
}
Future<Map<String, dynamic>> getUserData(String userId) async {
  try {
    DocumentSnapshot userSnapshot = await users.doc(userId).get();
    if (userSnapshot.exists) {
      return userSnapshot.data() as Map<String, dynamic>;
    }
  } catch (e) {
    print(' $e');
  }
  return {};
}