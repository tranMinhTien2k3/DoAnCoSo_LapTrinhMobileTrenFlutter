import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

class UserOnline extends StatefulWidget {
  const UserOnline({super.key});

  @override
  State<UserOnline> createState() => _UserOnlineState();
}

class _UserOnlineState extends State<UserOnline> {
  final user = FirebaseAuth.instance.currentUser;
  late String userId = "";
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  
  Future<void> updateUserOnlineStatus(bool isOnline) async {
    try {
      userId = user!.uid;
      await users.doc(userId).update({'Online': isOnline});
    } catch (e) {
      print(' $e');
    }
  }
  @override
  void initState() {
    super.initState();
    updateUserOnlineStatus(true);
  }

  @override
  void dispose() {
    super.dispose();
    updateUserOnlineStatus(false);
  }
  @override
  Widget build(BuildContext context) {
    return Container(
      child: StreamBuilder<QuerySnapshot>(
        stream: users.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return CircularProgressIndicator();
          } else {
            int onlineUsers = 0;
            snapshot.data!.docs.forEach((doc) {
              if (doc['Online'] == true) {
                onlineUsers++;
              }
            });
            return (onlineUsers > 1)?Column(
              children: [
                Center(
                  child: LoadingAnimationWidget.twistingDots(
                    leftDotColor: Colors.blue,
                    rightDotColor: Colors.green,
                    size: 20,
                  ),
                ),
                Text('Số người đang trong cuộc thảo luận $onlineUsers')
              ],
            ):Text('Số người đang trong cuộc thảo luận $onlineUsers');
          }
        },
      ),
    );

  }
}