import 'dart:typed_data';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/widgets/listvideo_detial.dart';
import 'package:timeago/timeago.dart' as timeago;

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
      backgroundColor: Color.fromARGB(255, 253, 255, 254),
      appBar: AppBar(
        backgroundColor: Colors.blue,
        title: Text("Danh sách phát"),
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
            return Column(
              children: [
                Container(
                  height: 300,
                  decoration: BoxDecoration(
                    color: Color.fromARGB(255, 34, 89, 87),
                  ),
                  child: Stack(
                  children: [
                    Positioned(
                      top: 30, 
                      left: 50,
                      right: 50,
                      child: ClipRRect(
                        borderRadius: BorderRadius.circular(8.0), 
                        child: Image.memory(
                          thumbnails![0],
                          fit: BoxFit.cover,
                        ),
                      ),
                    ),
                    Positioned(
                      bottom: 20,
                      left: 20,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            '${widget.lvid.genre}',
                            style: TextStyle(
                              fontSize: 24,
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          SizedBox(height: 5),
                          Text(
                            '${widget.lvid.lVid.length} video',
                            style: TextStyle(
                              fontSize: 18,
                              color: Colors.white,
                            ),
                          ),
                        ],
                      )
                    ),
                    Positioned(
                      bottom: 20,
                      right: 20,
                      child: Row(
                        children: [
                          ElevatedButton(
                            onPressed: () {
                            },
                            child: Icon(Icons.calendar_month),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                ),
                Expanded(
                  child: ListView.builder(
                    itemCount: widget.lvid.lVid.length,
                    itemBuilder: (context, index) {
                      return FutureBuilder<Map<String, dynamic>>(
                        future: getUserData(widget.lvid.lVid[index]['UserId']),
                        builder: (context, userSnapshot) {
                          DateTime dateTime =widget.lvid.lVid[index]['time'].toDate();
                          if (userSnapshot.connectionState ==
                              ConnectionState.waiting) {
                            return CircularProgressIndicator();
                          } else if (userSnapshot.hasError) {
                            print(userSnapshot.error);
                            return Text('Error: ${userSnapshot.error}');
                          } else {
                            String userName = userSnapshot.data?['fist name'] + ' ' +userSnapshot.data?['last name'];
                            String avtUrl = userSnapshot.data?['image'] ?? '';
                            return GestureDetector(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => VideoDetailPage(
                                      video: Video(
                                        title: widget.lvid.lVid[index]['title'],
                                        thumbnailUrl: widget.lvid.lVid[index]['url'],
                                        name: userName,
                                        avt: avtUrl,
                                      ),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 130,
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: Image.memory(
                                        thumbnails[index],
                                        height: 120,
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                    SizedBox(width: 10),
                                    Expanded(
                                      child: Column(
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Text(
                                            widget.lvid.lVid[index]['title'],
                                            style: TextStyle(
                                              fontSize: 18,
                                              fontWeight: FontWeight.bold,
                                            ),
                                            maxLines: 2,
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            userName,
                                            style: TextStyle(fontSize: 16),
                                          ),
                                          SizedBox(height: 5),
                                          Text(
                                            timeago.format(dateTime),
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: Colors.grey,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          }
                        },
                      );
                    },
                  ),
                ),
              ],
            );
          }
        },
      ),
    );
  }
}
