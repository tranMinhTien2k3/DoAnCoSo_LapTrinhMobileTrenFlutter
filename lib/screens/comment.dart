import 'package:appdemo/services/userOnline.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:comment_box/comment/comment.dart';
import 'package:timeago/timeago.dart' as timeago;
class CommentPage extends StatefulWidget {
  final List comments;
  final String id;
  final String idUser;
  const CommentPage({Key? key, required this.comments, required this.id, required this.idUser}):super(key: key);
  @override
  State<CommentPage> createState() => _CommentState();
}

class _CommentState extends State<CommentPage> {
  final user = FirebaseAuth.instance.currentUser;
  late String userId = "";
  final formKey = GlobalKey<FormState>();
  final TextEditingController commentController = TextEditingController();
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  List<String> usernames = [];
  List<String> avts = [];
  Future<bool> _isLoggedIn() async {
    if(user != null){
      userId = user!.uid;
      DocumentSnapshot userSnapshot = await users.doc(userId).get();
      if (userSnapshot.exists) {
          Map<String, dynamic>? userData = userSnapshot.data() as Map<String, dynamic>?;
           if (userData != null) {
            String firstName = userData['fist name'] ?? '';
            String lastName = userData['last name'] ?? '';
            String username = '$firstName $lastName';
            usernames.add(username);
            String avt =  userData['image'];
            avts.add(avt);
          }
        }
      return true;
    }else return false;
  }
  Future<void> _postComment(String text, String username, String avt) async {
    try {
      await FirebaseFirestore.instance
          .collection('post')
          .doc(widget.id)
          .update(
        {
          'comment': FieldValue.arrayUnion([
            {
              'name': username,
              'avt': avt,
              'text': text,
              'time': Timestamp.now().toDate(),
            }
          ])
        },
      );
      await FirebaseFirestore.instance
          .collection('Users')
          .doc(widget.idUser)
          .update(
        {
          'notifications': FieldValue.arrayUnion([
            {
              'name': username,
              'post': "comment your post",
              'time': Timestamp.now().toDate(),
            }
          ])
        },
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Error posting comment'),
        ),
      );
    }
  }
  Widget commentChild(data) {
    return ListView(
      children: [
        UserOnline(),
        for (var i = 0; i < data.length; i++)
          Padding(
            padding: const EdgeInsets.fromLTRB(2.0, 8.0, 2.0, 0.0),
            child: ListTile(
              leading: GestureDetector(
                onTap: () async {
                  print("Comment Clicked");
                },
                child: Container(
                  height: 50.0,
                  width: 50.0,
                  decoration: new BoxDecoration(
                      color: Colors.blue,
                      borderRadius: new BorderRadius.all(Radius.circular(50))),
                  child: CircleAvatar(
                      radius: 50,
                      backgroundImage: CommentBox.commentImageParser(
                          imageURLorPath: data[i]['avt'])),
                ),
              ),
              title: Text(
                data[i]['text'],
                style: TextStyle(fontWeight: FontWeight.bold),
              ),
              subtitle: Text(data[i]['name']),
              trailing: Text(timeago.format(data[i]['time'].toDate()), style: TextStyle(fontSize: 10)),
            ),
          ),

      ],
    );
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Thảo Luận"),
          ],
        ),
      ),
      body: Container(
        child: CommentBox(
          userImage: CommentBox.commentImageParser(
              imageURLorPath: avts.isNotEmpty ? avts[0] :"assets/img/user.png"),
          child: commentChild(widget.comments),
          labelText: 'Viết bình luận',
          errorText: 'Comment cannot be blank',
          withBorder: false,
          sendButtonMethod: () {
            if (formKey.currentState!.validate()) {
              String comment = commentController.text;
              _isLoggedIn().then((isLoggedIn) {
                if (isLoggedIn) {
                  _postComment(comment, usernames.isNotEmpty ? usernames[0] : "", avts.isNotEmpty ? avts[0] : "");
                } else {
                  showDialog(
                    context: context,
                    builder: (BuildContext context) {
                      return AlertDialog(
                        title: Text("Login Required"),
                        content: Text("Please login to post a comment."),
                        actions: <Widget>[
                          TextButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            child: Text("OK"),
                          ),
                        ],
                      );
                    },
                  );
                }
              });
              commentController.clear();
              FocusScope.of(context).unfocus();
            } else {
              print("Not validated");
            }
          },
          formKey: formKey,
          commentController: commentController,
          backgroundColor: Color.fromARGB(255, 44, 214, 49),
          textColor: Colors.white,
          sendWidget: Icon(Icons.send_sharp, size: 30, color: Colors.white),
        ),
      ),
    );
  }
}