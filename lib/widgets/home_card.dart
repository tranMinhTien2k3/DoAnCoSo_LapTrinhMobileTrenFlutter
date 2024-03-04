import 'package:appdemo/common/toast.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/widgets/listvideo_detial.dart';
import 'package:appdemo/widgets/media.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:timeago/timeago.dart' as timeago;
import 'package:video_player/video_player.dart';

class Homecard extends StatefulWidget {
  final String searchText;
  const Homecard({Key? key, required this.searchText}) : super(key: key);
  @override
  State<Homecard> createState() => _HomecardState();
}


class _HomecardState extends State<Homecard> {
  CollectionReference listvid = FirebaseFirestore.instance.collection("video");
  List<dynamic> originalVideos = [];
  List<dynamic> sortedVideos = [];
  void filterVideos(String searchText) {
      if (searchText.isEmpty) {
        sortedVideos = List.from(originalVideos);
      } else {
        sortedVideos = originalVideos.where((video) =>
            video['title'].toLowerCase().contains(searchText.toLowerCase())).toList();
      }
    }
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: listvid.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else if (snapshot.hasError) {
          return Text('Error: ${snapshot.error}');
        } else {
          originalVideos.clear();
          for (var doc in snapshot.data!.docs) {
            List<dynamic> videoList = doc['videolist'];
            originalVideos.addAll(videoList);
          }
          sortedVideos = List.from(originalVideos);
          filterVideos(widget.searchText);
          sortedVideos.sort((a, b) => b['time'].compareTo(a['time']));
          return ListView.builder(
            itemCount: sortedVideos.length,
            itemBuilder: (context, index) {
              dynamic video = sortedVideos[index];
              DateTime dateTime = video['time'].toDate();
              return FutureBuilder<Map<String, dynamic>>(
                future: getUserData(video['UserId']),
                builder: (context, userSnapshot) {
                  if (userSnapshot.connectionState == ConnectionState.waiting) {
                    return Center(
                      child: CircularProgressIndicator(),
                    );
                  } else if (userSnapshot.hasError) {
                    return Text('Error: ${userSnapshot.error}');
                  } else {
                    String userName = userSnapshot.data?['fist name'] + userSnapshot.data?['last name'];
                    String avtUrl = userSnapshot.data?['image'] ?? '';
                    Uri relativeUri = Uri.parse(video['url']);
                    final VideoPlayerController controller = VideoPlayerController.networkUrl(relativeUri);
                    late final String duration;
                    controller.addListener(() {
                      if (controller.value.isInitialized) {
                        duration = "${controller.value.duration}";
                        print('Duration: $duration');
                      }
                    });              
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => VideoDetailPage(
                                  video: Video(
                                    title: video['title'],
                                    thumbnailUrl: video['url'],
                                    name: userName,
                                    avt: avtUrl,
                                  ),
                                ),
                              ),
                            );
                          },
                          child: Stack(
                            alignment: Alignment.bottomRight,
                            children: [
                              VideoWidget(videoUrl: video['url']),
                              Container(
                                margin: EdgeInsets.all(8),
                                padding: EdgeInsets.all(4),
                                color: Colors.black.withOpacity(0.6),
                                child: Text(
                                  '',
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.white,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(horizontal: 8.0, vertical: 4.0),
                          child: Row(
                            children: [
                              CircleAvatar(
                                radius: 20.0,
                                backgroundImage: NetworkImage(avtUrl),
                                backgroundColor: Colors.transparent,
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      video['title'],
                                      style: TextStyle(fontSize: 18),
                                    ),
                                    Row(
                                      children: [
                                        Text(userName),
                                        SizedBox(width: 5.0),
                                        Icon(Icons.check_circle),
                                        SizedBox(width: 5.0),
                                        Text(timeago.format(dateTime)),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        ),
                        Divider(),
                      ],
                    );
                  }
                },
              );
            },
          );
        }
      },
    );
  }
}
