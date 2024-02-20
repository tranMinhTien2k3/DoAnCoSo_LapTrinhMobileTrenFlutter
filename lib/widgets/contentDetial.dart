import 'package:appdemo/common/toast.dart';
import 'package:appdemo/screens/comment.dart';
import 'package:appdemo/widgets/media.dart';
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
      padding: EdgeInsets.all(5.0),
      margin: EdgeInsets.all(5.0),
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
                      backgroundImage: new NetworkImage(widget.avt),
                      backgroundColor: Colors.transparent,
                    ),
                  SizedBox(width: 8.0),
                  Text(widget.userName),
                ],
              ),
              Text(timeago.format(dateTime)),
            ],
          ),
          SizedBox(height: 12.0),
          Text(
            widget.mainContent,
            style: TextStyle(fontSize: 18.0, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 12.0),
      
          SizedBox(
            height: 200,
            width: double.infinity,
            child:  MediaScreen(mediaUrls: widget.imageURL),
        
          ),

          Divider(),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Stack(
                children: [
                  IconButton(
                    onPressed: () async {
                      _isLoggedIn()?
                      widget.likes.contains(userId)?
                        dislikePost(context):
                        likePost(context):
                        showToast(message:"You can login");
                    },
                    icon: _isLoggedIn()?widget.likes.contains(userId)
                        ? Icon(Icons.thumb_up)
                        : Icon(Icons.thumb_up_alt_outlined):Icon(Icons.thumb_up),
                  ),
                  Text(
                        widget.likes.length.toString(), 
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ],
              ),
              Stack(
                children: [
                  IconButton(
                    onPressed: () {
                      _isLoggedIn()?
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => CommentPage(comments: widget.comments, id: widget.id, idUser: widget.idUser,),
                        ),
                      ):
                      showToast(message:"You can login");
                      },
                    icon: Icon(Icons.comment),
                  ),
                  Text(
                        widget.comments.length.toString(), 
                        style: TextStyle(
                          color: Colors.black,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                ],
              ),
              
            ],
            
          ),
          Container(
      height: 12,
      color: Color.fromARGB(255, 182, 218, 184),
    ),
        ],
      ),
    
    );
  }
}
  