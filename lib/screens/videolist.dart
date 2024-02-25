import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/widgets/listvideo_detial.dart';

class VideoList extends StatefulWidget {
  final ListVideo lvid;

  const VideoList({
    required this.lvid,
  });

  @override
  State<VideoList> createState() => _VideoListState();
}

class _VideoListState extends State<VideoList> {
  late Future<List<Uint8List>> _thumbnailsFuture;

  @override
  void initState() {
    super.initState();
    _thumbnailsFuture = _generateThumbnails();
  }

  Future<List<Uint8List>> _generateThumbnails() async {
    List<Uint8List> thumbnails = [];
    for (int i = 0; i < widget.lvid.lVid.length; i++) {
      final fileName = await VideoThumbnail.thumbnailData(
        video: widget.lvid.lVid[i]['url'],
        timeMs: 1000,
        imageFormat: ImageFormat.WEBP,
        maxHeight: 64,
        quality: 75,
      );
      thumbnails.add(fileName!);
    }
    return thumbnails;
  }

  CollectionReference users = FirebaseFirestore.instance.collection("Users");

  Future<Map<String, dynamic>> getUserData(String userId) async {
    try {
      DocumentSnapshot userSnapshot = await users.doc(userId).get();
      if (userSnapshot.exists) {
        return userSnapshot.data() as Map<String, dynamic>;
      }
    } catch (e) {
      print(' $e');
    }
    return {};
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 182, 218, 184),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text(widget.lvid.genre),
      ),
      body: FutureBuilder<List<Uint8List>>(
        future: _thumbnailsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else if (snapshot.hasError) {
            print(snapshot.error);
            return Center(
              child: Text('Error: ${snapshot.error}'),
            );
          } else {
            List<Uint8List>? thumbnails = snapshot.data;
            return Container(
              padding: EdgeInsets.all(8),
              child: ListView.builder(
                itemCount: widget.lvid.lVid.length,
                itemBuilder: (context, index) {
                  return FutureBuilder<Map<String, dynamic>>(
                    future: getUserData(widget.lvid.lVid[index]['UserId']),
                    builder: (context, userSnapshot) {
                      if (userSnapshot.connectionState ==
                          ConnectionState.waiting) {
                        return CircularProgressIndicator();
                      } else if (userSnapshot.hasError) {
                        print(userSnapshot.error);
                        return Text('Error: ${userSnapshot.error}');
                      } else {
                        String userName = userSnapshot.data?['fist name'] +userSnapshot.data?['last name'];
                        String avtUrl = userSnapshot.data?['image'] ?? '';
                        return Column(
                          children:<Widget> [  
                            new GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoDetailPage(
                                      video: Video(
                                        title: widget.lvid.lVid[index]['title'] ,
                                        thumbnailUrl: widget.lvid.lVid[index]['url'] ,
                                        name: userName ,
                                        avt: avtUrl
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: new Container(
                                height: 200,
                                decoration: BoxDecoration(
                                  image: DecorationImage(
                                    image: MemoryImage(
                                          thumbnails![index],
                                        ),
                                    fit: BoxFit.cover
                                  ),
                                ),
                              ),
                            ),
                            new Padding(padding:const EdgeInsets.all(8)),
                            new Row(
                              children: [
                                Container(
                                   width: 200,
                                   child: Text(
                                    widget.lvid.lVid[index]['title'],
                                    style: TextStyle(fontSize: 18),
                                  ),
                                ),                           
                                Expanded(
                                  child: Row(
                                    children: [
                                      CircleAvatar(
                                        radius: 20.0,
                                        backgroundImage: NetworkImage(avtUrl),
                                        backgroundColor: Colors.transparent,
                                      ),
                                      SizedBox(width: 5.0),
                                      Text(userName),
                                    ],
                                  )
                                )
                                
                              ],
                            ),
                            new Divider()
                          ]
                        );
                      }
                    },
                  );
                },
              ),
            );
          }
        },
      ),
    );
  }
}
