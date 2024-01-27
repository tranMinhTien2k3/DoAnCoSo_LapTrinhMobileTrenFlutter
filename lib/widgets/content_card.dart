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
  @override
  Widget build(BuildContext context) {
    return 
         Container(
      padding: EdgeInsets.all(16.0),
      margin: EdgeInsets.all(16.0),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(12.0),
        color: Colors.grey[200],
      ),
      child: StreamBuilder<QuerySnapshot>(
  stream: post.snapshots(),
  builder: (context, snapshot) {
    List<String> usernames = []; 
    String avt="";
    if (snapshot.hasError) {
      return Center(
        child: Text('Something went wrong'),
      );
    }
    if (snapshot.connectionState == ConnectionState.waiting) {
      return Text('Loading...');
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
            avt =  userData['image'];
            
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
            itemBuilder: (context, index) {
return CustomContainer(
  userName: usernames[index],
  time: documents[index]['datePublished'],
  mainContent: documents[index]['content'],
  imageURL: documents[index]['image'],
  avt:avt,
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

