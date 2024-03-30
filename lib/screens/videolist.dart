import 'dart:typed_data';
import 'package:appdemo/common/toast.dart';
import 'package:appdemo/screens/schedule_detail.dart';
import 'package:appdemo/widgets/media.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/screens/listvideo_detial.dart';
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
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  final user = FirebaseAuth.instance.currentUser;
  late String userId = "";
  bool _isLoggedIn() {
    if(user != null){
      userId = user!.uid;
      return true;
    }else return false;
  }
  List saveVideo = [];
  void _addEvent(String eventName, DateTime date, Map<String, dynamic> video) {
    if (_isLoggedIn()) {
      users.doc(userId).collection('events').add({
        'eventName': eventName,
        'date': date,
        'video': video,
      }).then((docRef) {
        setState(() {
          saveVideo.add(Events(uid: docRef.id, eventName: eventName, date: date));
        });
      }).catchError((error) {
        print("Error adding event: $error");
      });
    } else {
      showToast(message: "Vui lòng đăng nhập để thực hiện tác vụ");
    }
  }
  // void _addList() {
  //   if (_isLoggedIn()) {
  //     users.doc(userId).collection('saveList').add({

  //     }).then((docRef) {
  //       setState(() {
  //       });
  //     }).catchError((error) {
  //       print("Error adding event: $error");
  //     });
  //   } else {
  //     showToast(message: "Vui lòng đăng nhập để thực hiện tác vụ");
  //   }
  // }


  void _showVideoSelectionDialog(DateTime selectedDate) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Chọn video'),
        content: SingleChildScrollView(
          child: Column(
            children: widget.lvid.lVid.map((video) {
              return ListTile(
                title: Text(video['title']),
                onTap: () {
                  Navigator.of(context).pop();
                  _showEventDialog(video, selectedDate);
                },
              );
            }).toList(),
          ),
        ),
      ),
    );
  }
  void _showEventDialog(Map<String, dynamic> selectedVideo, DateTime selectedDate) {
    String eventName = '';

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text('Thêm sự kiện'),
        content: TextField(
          onChanged: (value) {
            eventName = value;
          },
          decoration: InputDecoration(hintText: 'Nhập tên sự kiện'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: Text('Hủy'),
          ),
          TextButton(
            onPressed: () {
              if (eventName.isNotEmpty) {
                // Thực hiện thêm sự kiện vào lịch ở đây
                _addEvent(eventName, selectedDate, selectedVideo);
                Navigator.of(context).pop();
              } else {
                showToast(message: 'Vui lòng nhập tên sự kiện');
              }
            },
            child: Text('Thêm'),
          ),
        ],
      ),
    );
  }



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
      backgroundColor: Color.fromARGB(255, 220, 255, 231),
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
                              showDatePicker(
                                context: context,
                                initialDate: DateTime.now(),
                                firstDate: DateTime.now(),
                                lastDate: DateTime(DateTime.now().year + 1),
                              ).then((selectedDate) {
                                if (selectedDate != null) {
                                  _showVideoSelectionDialog(selectedDate);
                                }
                              });
                            },
                            child: Icon(Icons.calendar_month),
                            style: ElevatedButton.styleFrom(
                              shape: CircleBorder(),
                            ),
                          ),

                          ElevatedButton(
                            onPressed: () {
                              showToast(message: 'chức năng đang được phát triển');
                              // _addList();
                            },
                            child: Icon(Icons.add_box),
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
                                      ), lvid: widget.lvid, time: timeago.format(dateTime),
                                    ),
                                  ),
                                );
                              },
                              child: Container(
                                height: 135,
                                padding: EdgeInsets.all(15),
                                child: Row(
                                  children: [
                                    ClipRRect(
                                      borderRadius: BorderRadius.circular(8.0),
                                      child: VideoWidget(
                                        videoUrl: widget.lvid.lVid[index]['url'],
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
