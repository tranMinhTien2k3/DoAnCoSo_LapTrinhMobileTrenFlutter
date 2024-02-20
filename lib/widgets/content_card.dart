import 'package:appdemo/widgets/contentDetial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ContentCard extends StatefulWidget {
  @override
  State<ContentCard> createState() => _ContentCardState();
}

class _ContentCardState extends State<ContentCard> {
  
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  CollectionReference post = FirebaseFirestore.instance.collection("post");
  String imageUrl ='';
  Future<List<List<String>>> getDataFromUsers(CollectionReference users, List userIds) async {
    List<String> usernames = [];
    List<String> avts = [];

    for (String userId in userIds) {
      try {
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
      } catch (e) {
        print('Error getting data from users: $e');
      }
    }

    return [usernames, avts];
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: EdgeInsets.all(5.0),
      margin: EdgeInsets.all(5.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: StreamBuilder<QuerySnapshot>(
        stream: post.snapshots(),
        builder: (context, snapshot) {
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

          List<String> usernames = [];
          List<String> avts = [];

          final documents = snapshot.data!.docs;

          List userIds = documents.map((doc) => doc['name']).toList();
          Future<void> future = getDataFromUsers(users, userIds);

          return FutureBuilder(
            future: future,
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                List<dynamic> data = snapshot.data as List<dynamic>;
                usernames = data[0] as List<String>;
                avts = data[1] as List<String>;

                return ListView.builder(
                  itemCount: documents.length,
                  itemBuilder: (BuildContext context, int index) {
                    return CustomContainer(
                      userName: usernames[index],
                      time: documents[index]['datePublished'],
                      mainContent: documents[index]['content'],
                      likes: documents[index]['like'],
                      comments: documents[index]['comment'],
                      imageURL: documents[index]['image'],
                      avt: avts[index],
                      id: documents[index].id,
                      idUser: userIds[index],
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
    );
  }
}