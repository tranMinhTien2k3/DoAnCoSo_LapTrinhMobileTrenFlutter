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
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  final user = FirebaseAuth.instance.currentUser;
  late String userId = "";
  bool _isLoggedIn() {
    if(user != null){
      userId = user!.uid;
      return true;
    }else return false;
  }
  String createNotificationKey(Map<String, dynamic> notification) {
    return "${notification['post']}_${notification['name']}";
  }
  List filterNotificationsByPostAndName(List notifications, String post, String name) {
    return notifications.where((notification) =>
      notification['post'] == post && notification['name'] == name).toList();
  }
  @override
  Widget build(BuildContext context) {
     return Scaffold(
      appBar: AppBar(
        title: Text("Thông báo"),
      ),
      body:FutureBuilder<DocumentSnapshot>(
  future: _isLoggedIn() ? users.doc(userId).get() : users.doc(userId).get(),
  builder: (context, snapshot) {
    if (snapshot.connectionState == ConnectionState.done) {
      Map<String, dynamic>? data = snapshot.data!.data() as Map<String, dynamic>?;

      List noti = [];
      noti = data?['notifications'];

      // Tạo một Map để theo dõi các thông báo với cặp giá trị 'post' và 'name'
      Map<String, dynamic> uniqueNotifications = {};

      for (var item in noti) {
        String key = createNotificationKey(item);
        if (!uniqueNotifications.containsKey(key) ||
            item['time'].toDate().isAfter(uniqueNotifications[key]['time'].toDate())) {
          // Nếu cặp giá trị 'post' và 'name' chưa tồn tại trong uniqueNotifications hoặc thời gian mới hơn, thay thế thông báo đó
          uniqueNotifications[key] = item;
        }
      }

      // Chuyển các giá trị của uniqueNotifications thành danh sách cuối cùng
      List notiWithoutDuplicates = uniqueNotifications.values.toList();

      // Sắp xếp theo thời gian giảm dần
      notiWithoutDuplicates.sort((a, b) => b['time'].compareTo(a['time']));

      print(notiWithoutDuplicates);
      
      return ListView.separated(
        padding: const EdgeInsets.only(top: 5),
        itemBuilder: (context, index) {
          DateTime dateTime = notiWithoutDuplicates[index]['time'].toDate();
          return GestureDetector(
            onTap: () {
              // Lọc thông báo theo 'post' và 'name' được chọn
              List filteredNotifications = filterNotificationsByPostAndName(
                noti, 
                notiWithoutDuplicates[index]['post'],
                notiWithoutDuplicates[index]['name']
              );
              // Hiển thị danh sách thông báo cùng 'post' và 'name' ngay bên dưới
              showModalBottomSheet(
                context: context,
                builder: (context) => ListView.separated(
                  padding: EdgeInsets.all(10),
                  itemBuilder: (context, index) {
                    DateTime dateTime = filteredNotifications[index]['time'].toDate();
                    return SingleNotification(
                      name: filteredNotifications[index]['name'],
                      post: filteredNotifications[index]['post'],
                      time: timeago.format(dateTime),
                    );
                  },
                  separatorBuilder: (context, index) => const Divider(
                    height: 1,
                  ),
                  itemCount: filteredNotifications.length,
                ),
              );
            },
            child: SingleNotification(
              name: notiWithoutDuplicates[index]['name'],
              post: notiWithoutDuplicates[index]['post'],
              time: timeago.format(dateTime),
            ),
          );
        },
        separatorBuilder: (context, index) => const Divider(
          height: 1,
        ),
        itemCount: notiWithoutDuplicates.length,
      );
    } else {
      return Text('Loading...');
    }
  },
)
     );
  }
}

