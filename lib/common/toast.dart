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
// void signOut(context){
//   FirebaseAuth.instance.signOut();
//   Navigator.pushNamed(context, "/login");
// }
CollectionReference users = FirebaseFirestore.instance.collection("Users");

Future<void> signOut(BuildContext context) async {
  return showDialog<void>(
    context: context,
    barrierDismissible: false,
    builder: (BuildContext context) {
      return AlertDialog(
        title: Text('Xác nhận'),
        content: SingleChildScrollView(
          child: ListBody(
            children: <Widget>[
              Text('Bạn có muốn đăng xuất tài khoản ?'),
            ],
          ),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () async {
              await FirebaseAuth.instance.signOut();
              Navigator.pushNamed(context, '/home');
            },
            child: Text('Đồng ý'),
          ),
        ],
      );
    },
  );
}
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