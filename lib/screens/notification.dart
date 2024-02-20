import 'package:appdemo/widgets/SingleNotification.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:flutter/material.dart';

class Notifucation extends StatefulWidget {
  @override
  State<Notifucation> createState() => _Notifucation();
}

class _Notifucation extends State<Notifucation>{
   Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  final user = FirebaseAuth.instance.currentUser;
  late String userId = "";
  bool _isLoggedIn() {
    if(user != null){
      userId = user!.uid;
      return true;
    }else return false;
  }
  @override
  Widget build(BuildContext context) {
  
     return Scaffold(
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Thông báo"),
      ),
      body: FutureBuilder<DocumentSnapshot>(
          future: _isLoggedIn()?users.doc(userId).get():users.doc(userId).get(),
          builder: ((context,snapshot) {
          if(snapshot.connectionState==ConnectionState.done){
            Map<String, dynamic>? data = snapshot.data!.data() as Map<String,dynamic>?;
            List noti = [];
            noti = data?['notifications'];
            print(noti);
            return ListView.separated(
              padding: const EdgeInsets.only(
                top: 5,
              ),
              itemBuilder: (context, index) {
                DateTime dateTime = noti[index]['time'].toDate();
                return SingleNotification(
                  name: noti[index]['name'],
                  post: noti[index]['post'],
                  time: timeago.format(dateTime),
                );
              },
              separatorBuilder: (context, index) => const Divider(
                height: 1,
              ),
              itemCount: noti.length,
            );
        }else return Text('Loading...');
      }
    )
  )
      
      
      
      


     );
  }
}

