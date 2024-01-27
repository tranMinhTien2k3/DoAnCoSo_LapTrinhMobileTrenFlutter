import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
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