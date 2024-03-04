import 'package:appdemo/common/toast.dart';
import 'package:appdemo/screens/comment.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
class CustomContainer extends StatefulWidget {
  final String userName;
  final Timestamp time;
  final String mainContent;
  final List likes;
  final List comments;
  final List<dynamic> imageURL;
  final String avt;
  final String id;
  final String idUser;

  const CustomContainer({
    Key? key,
    required this.userName,
    required this.time,
    required this.mainContent,
    required this.likes,
    required this.comments,
    required this.imageURL,
    required this.avt,
    required this.id, 
    required this.idUser,
  }):super(key: key);
  @override
  State<CustomContainer> createState() => _CustomContainerState();
}

class _CustomContainerState extends State<CustomContainer>{
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  late String userId = "";
  bool _isLoggedIn() {
    if(user != null){
      userId = user!.uid;
      return true;
    }else return false;
  }
  Future<void> likePost(
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.id)
          .update(
        {
          'like': FieldValue.arrayUnion([userId])
        },
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.idUser)
          .update(
        {
          'notifications': FieldValue.arrayUnion([
            {
              'name': widget.userName,
              'post': "like your post",
              'time': Timestamp.now().toDate(),
            }
          ])
        },
      );
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error liking post'),
        ),
      );
    }
  }
  Future<void> dislikePost(
    BuildContext context,
  ) async {
    try {
      await FirebaseFirestore.instance.collection('post').doc(widget.id).update(
        {
          'like': FieldValue.arrayRemove([userId])
        },
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.idUser)
          .update(
        {
          'notifications': FieldValue.arrayUnion([
            {
              'name': widget.userName,
              'post': "unlike your post",
              'time': Timestamp.now().toDate(),
            }
          ])
        },
      );
    } on FirebaseException {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error liking post'),
        ),
      );
    }
  }
  
  @override
Widget build(BuildContext context) {
  DateTime dateTime = widget.time.toDate();
  return Container(
    padding: EdgeInsets.symmetric(vertical: 10.0, horizontal: 15.0),
    margin: EdgeInsets.all(10.0),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12.0),
      color: Colors.grey[200],
    ),
    child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                CircleAvatar(
                  radius: 30.0,
                  backgroundImage: NetworkImage(widget.avt),
                  backgroundColor: Colors.transparent,
                ),
                SizedBox(width: 8.0),
                Text(
                  widget.userName,
                  style: TextStyle(
                    fontSize: 16.0,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ],
            ),
            Text(
              timeago.format(dateTime),
              style: TextStyle(
                fontSize: 14.0,
                color: Colors.grey,
              ),
            ),
          ],
        ),
        SizedBox(height: 12.0),
        Text(
          widget.mainContent,
          style: TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.bold,
          ),
        ),
        SizedBox(height: 12.0),
        SizedBox(
          height: 250,
          width: double.infinity,
          child: SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: [
                for (var imageUrl in widget.imageURL)
                  Container(
                    margin: EdgeInsets.only(right: 2.0),
                    child: Image.network(imageUrl, fit: BoxFit.cover),
                  ),
              ],
            ),
          ),
        ),
        Center(
          child: Text(
            "Số trang: ${widget.imageURL.length} .Hãy lướt sang để xem tiếp",
            style: TextStyle(
              fontSize: 10.0,
              fontWeight: FontWeight.normal,
            ),
          ),
        ),
        Divider(),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            GestureDetector(
              onTap: () async {
                _isLoggedIn()
                    ? widget.likes.contains(userId)
                        ? dislikePost(context)
                        : likePost(context)
                    : showToast(message: "You can login");
              },
              child: Row(
                children: [
                  Icon(
                    _isLoggedIn()
                        ? widget.likes.contains(userId)
                            ? Icons.thumb_up
                            : Icons.thumb_up_alt_outlined
                        : Icons.thumb_up,
                    color: _isLoggedIn()
                        ? widget.likes.contains(userId)
                            ? Colors.blue
                            : null
                        : null,
                  ),
                  SizedBox(width: 5.0),
                  Text(
                    widget.likes.length.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            GestureDetector(
              onTap: () {
                _isLoggedIn()
                    ? Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentPage(
                            comments: widget.comments,
                            id: widget.id,
                            idUser: widget.idUser,
                          ),
                        ),
                      )
                    : showToast(message: "You can login");
              },
              child: Row(
                children: [
                  Icon(Icons.comment),
                  SizedBox(width: 5.0),
                  Text(
                    widget.comments.length.toString(),
                    style: TextStyle(
                      color: Colors.black,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
        SizedBox(height: 10.0),
        Container(
          height: 1,
          color: Colors.grey[300],
        ),
      ],
    ),
  );
}

}
  