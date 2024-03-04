import 'package:appdemo/widgets/contentDetial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Mycontent extends StatefulWidget {
  const Mycontent({Key? key}) : super(key: key);

  @override
  State<Mycontent> createState() => _Mycontent();
}

class _Mycontent extends State<Mycontent> {
  late String currentUserID;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  CollectionReference post = FirebaseFirestore.instance.collection("post");

  @override
  void initState() {
    super.initState();
    currentUserID = FirebaseAuth.instance.currentUser!.uid;
  }


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("My content"),
      ),
      body: Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: post.where('name', isEqualTo: currentUserID).snapshots(),
        builder: (context, snapshot) {
          List<String> usernames = []; 
          List<String> avts = []; 
          if (snapshot.hasError) {
            return Center(
              child: Text('Something went wrong'),
            );
          }
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          }
          final documents = snapshot.data!.docs;
          List<Future<void>> futures = [];
          for (int index = 0; index < documents.length; index++) {
            final data = documents[index].data() as Map<String, dynamic>;

            Future<void> future = users.doc(data['name']).get().then((snapshot) {
              if (snapshot.exists) {
                Map<String, dynamic>? userData =
                    snapshot.data() as Map<String, dynamic>?;

                if (userData != null) {
                  String firstName = userData['fist name'] ?? '';
                  String lastName = userData['last name'] ?? '';
                  String username = '$firstName $lastName';
                  usernames.add(username);
                  String avt =  userData['image'];
                  avts.add(avt);
                }
              }
            });

            futures.add(future); 
          }
          return FutureBuilder<void>(
      future: Future.wait(futures),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.done) {
          return ListView.builder(
            itemCount: documents.length,
            itemBuilder: (BuildContext context,int index) {
              return CustomContainer(
              userName: usernames[index],
              time: documents[index]['datePublished'],
              mainContent: documents[index]['content'],
              likes: documents[index]['like'],
              comments: documents[index]['comment'],
              imageURL: documents[index]['image'],
              avt:avts[index],
              id: documents[index].id, 
              idUser: currentUserID,
            );

            },
          );
        } else {
          return Center(child: CircularProgressIndicator());
        }
      },
    );
        },
      ),
    )
    );
  }
}
