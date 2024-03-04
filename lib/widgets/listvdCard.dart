import 'package:appdemo/common/toast.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/screens/videolist.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class ListVdCard extends StatefulWidget {
  final String searchText;
  ListVdCard({Key? key, required this.searchText}) : super(key: key);

  @override
  State<ListVdCard> createState() => _ListVdCardState();
}

class _ListVdCardState extends State<ListVdCard> {
  CollectionReference listvid =
  FirebaseFirestore.instance.collection("video");

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<QuerySnapshot>(
      stream: listvid.snapshots(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(
            child: CircularProgressIndicator(),
          );
        } else {
          List<ListVideo> videoData = snapshot.data!.docs.map((doc) {
            return ListVideo(
              lVid: doc['videolist'],
              genre: doc['genre'],
            );
          }).toList();
          videoData = videoData.where((video) =>
              video.genre.toLowerCase().contains(widget.searchText.toLowerCase())).toList();
          return Expanded(
            child: ListView.builder(
              itemCount: videoData.length,
              itemBuilder: (context, index) {
                return GestureDetector(
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoList(lvid: videoData[index],),
                      ),
                    );
                  },
                  child: FutureBuilder(
                    future: generateThumbnail(videoData[index].lVid[0]['url']),
                    builder: (context, snapshottm) {
                      if (snapshottm.connectionState == ConnectionState.done) {
                        String lvd() {
                        String result = '';
                        if(videoData[index].lVid.length>1){
                          for(int i=0;i<videoData[index].lVid.length-1;i++) {
                            result += ' ${videoData[index].lVid[i]['title']},'; 
                          }
                          result += ' ${videoData[index].lVid[videoData[index].lVid.length-1]['title']}.';
                        }else(
                          result = ' ${videoData[index].lVid[0]['title']}.'
                        );
                        return result;
                      }
                        return Container(
                          height: 130,
                          padding: EdgeInsets.all(10),
                          child: Row(
                            children: [
                              ClipRRect(
                                borderRadius: BorderRadius.circular(8.0),
                                child: Stack(
                                  children: [
                                    Image.memory(
                                      snapshottm.data!,
                                      height: 130,
                                      fit: BoxFit.cover,
                                    ),
                                    Positioned(
                                      bottom: 8, 
                                      right: 8, 
                                      child: Container(
                                        color: Colors.black,
                                        padding: EdgeInsets.all(5),
                                        child: Row(children:[
                                          SizedBox(
                                          child: Icon(Icons.list,color: Colors.white,),
                                          width: 15,
                                          height: 10,
                                        ),
                                        SizedBox(width: 5.0),
                                        Text('${videoData[index].lVid.length}',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontSize: 10, 
                                          ),)
                                        ])
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              SizedBox(width: 10),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Danh Sách Phát ${videoData[index].genre}",
                                      style: TextStyle(
                                        fontSize: 18,
                                        fontWeight: FontWeight.bold,
                                      ),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                    SizedBox(height: 5),
                                    Text(
                                      "Danh sách phát gồm: ${lvd()}",
                                      style: TextStyle(fontSize: 16),
                                      maxLines: 2,
                                      overflow: TextOverflow.ellipsis,
                                    ),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        );
                      } else {
                        return Center(
                      child: CircularProgressIndicator(),
                    );
                      }
                    },
                  ),
                );
              },
            ),
          );
        }
      },
    );
  }
}
