import 'dart:typed_data';

import 'package:appdemo/common/toast.dart';
import 'package:appdemo/common/video.dart';
import 'package:appdemo/widgets/content_card.dart';
import 'package:appdemo/screens/videolist.dart';
import 'package:appdemo/widgets/listvideo_detial.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:video_thumbnail/video_thumbnail.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  CollectionReference listvid = FirebaseFirestore.instance.collection("video");
  bool _isSearching = false;
  String documentId="";
  int selectedButtonIndex = 0;
  bool _isLoggedIn() {
    if(user != null){
       documentId =  user!.uid;
      return true;
    }else return false;
  }
  Future<Uint8List> _generateThumbnail(String videoUrl) async {
    final thumbnail = await VideoThumbnail.thumbnailData(
      video: videoUrl,
      timeMs: 1000,
      imageFormat: ImageFormat.WEBP,
      maxHeight: 64,
      quality: 75,
    );
    return thumbnail!;
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
      backgroundColor: const Color.fromARGB(255, 182, 218, 184),
      appBar: AppBar(
         title: _isSearching
            ? TextField(
                decoration: const InputDecoration(
                  hintText: 'Tìm Kiếm...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Trang chủ'),
        backgroundColor: Colors.blue,
        actions:[
           IconButton(
            icon: _isSearching ? Icon(Icons.cancel) : Icon(Icons.search),
            onPressed: () {
              setState(() {
                _isSearching = !_isSearching;
              });
            },
          ),
        ]
      ),
      drawer: Drawer(
        child: ListView(
          padding: const EdgeInsets.all(0),
          children: [
            DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                accountName: Text(
                  "",
                  style: TextStyle(fontSize: 0),
                ),
                accountEmail: Text(_isLoggedIn()?user!.email!:"Chưa đăng nhập"),
                currentAccountPictureSize: Size.square(100),
                currentAccountPicture: _isLoggedIn()? FutureBuilder<DocumentSnapshot>(
                  future: users.doc(documentId).get(),
                  builder: ((context,snapshot) {
                  if(snapshot.connectionState==ConnectionState.done){
                  Map<String, dynamic>? data = 
                    snapshot.data!.data() as Map<String,dynamic>?;
                    return ListView(
                      shrinkWrap: true,
                      children: [
                     (data?['image']!="")?CircleAvatar(
                      radius: 30.0,
                      backgroundImage: NetworkImage(data?['image']),
                      backgroundColor: Colors.transparent,
                    ):CircleAvatar(
                      radius: 30.0,
                      backgroundImage: AssetImage('assets/img/user.png'),
                      backgroundColor: Colors.transparent,
          )
                    
                  ],
                );
              }else return Text('Loading...');
              }
            )
          ): CircleAvatar(
                      radius: 30.0,
                      backgroundImage: AssetImage('assets/img/user.png'),
                      backgroundColor: Colors.transparent,
          )
                ),
              ),
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' Thông tin cá nhân '),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/profile'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text(' Quản lý Thời gian biểu '),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/schedule'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text(' Thông báo '),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/notifucation'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_label),
              title: const Text('Nội dung của tôi'),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/mycontent'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_call),
              title: const Text('Tạo nội dung'),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/content'):showToast(message: "You cant login");
              },
            ),
            _isLoggedIn()==false?
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Đăng nhập'),
              onTap: () {
               Navigator.pushNamed(context, '/login');
              },    
          ):
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Đăng xuất'),
              onTap: () {
                signOut(context);
            },    
          ),
          ],
        ),
      ),
      body: Column(
        children: [
          Row(
            children: [
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButtonIndex = 0;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (selectedButtonIndex == 0) {
                        return Colors.blue;
                      }
                      return Colors.white;
                    },
                  ),
                ),
                child: Text('Bản tin'),
              ),
              SizedBox(width: 10), 
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButtonIndex = 1;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (selectedButtonIndex == 1) {
                        return Colors.blue;
                      }
                      return Colors.white;
                    },
                  ),
                ),
                child: Text('Danh sách Video'),
              ),
              SizedBox(width: 10), 
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButtonIndex = 2;
                  });
                },
                style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.resolveWith<Color>(
                    (Set<MaterialState> states) {
                      if (selectedButtonIndex == 2) {
                        return Colors.blue;
                      }
                      return Colors.white;
                    },
                  ),
                ),
                child: Text('Video'),
              ),
            ],
          ),
          if (selectedButtonIndex == 0)
          Container(
            width: 400,
            height: 550,
            child: ContentCard(),
          ),
          if(selectedButtonIndex ==1)
          Container(
            width: 400,
            height: 550,
            child:     StreamBuilder<QuerySnapshot>(
            stream: listvid.snapshots(),
            builder: (context, snapshot) {
              List<ListVideo> videoData = snapshot.data!.docs.map((doc) {
                return ListVideo(
                  lVid:doc['videolist'] ,
                  genre: doc['genre'],
                );
              }).toList();
              return Expanded(
                child: ListView.builder(
                  itemCount: snapshot.data!.docs.length,
                  itemBuilder: (context, index) {
                    return ListTile(
                      contentPadding: EdgeInsets.symmetric(vertical: 10),
                      onTap: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => VideoList(lvid: videoData[index],),
                          ),
                        );
                      },
                      title: Text(videoData[index].genre,
                        style: TextStyle(fontSize: 18)),
                      leading: FutureBuilder(
                        future: _generateThumbnail(videoData[index].lVid[0]['url']),
                        builder: (context, snapshot) {
                          if (snapshot.connectionState == ConnectionState.done) {
                            return Stack(
                              children: [
                                Image.memory(
                                  snapshot.data!,
                                  width: 150,
                                  height: 200,
                                  fit: BoxFit.cover,
                                ),
                                SizedBox(
                                  child: Icon(Icons.list_alt_outlined),
                                  width: 15,
                                  height: 10,
                                )
                              ],
                            );
                          } else {
                            return CircularProgressIndicator();
                          }
                        },
                      ),
                    );
                  },
                ),
              );
            }
          ),
          ),
        
          if(selectedButtonIndex ==2)
         Container(
  width: 400,
  height: 550,
  child: StreamBuilder<QuerySnapshot>(
    stream: listvid.snapshots(),
    builder: (context, snapshot) {
      if (snapshot.connectionState == ConnectionState.waiting) {
        return CircularProgressIndicator();
      } else if (snapshot.hasError) {
        return Text('Error: ${snapshot.error}');
      } else {
        List<ListVideo> videoData = snapshot.data!.docs.map((doc) {
          return ListVideo(
            lVid: doc['videolist'],
            genre: doc['genre'],
          );
        }).toList();

        return ListView.builder(
          itemCount: snapshot.data!.docs.length,
          itemBuilder: (context, index) {
            return Column(
              children: [
                ListView.builder(
                  shrinkWrap: true,
                  physics: NeverScrollableScrollPhysics(),
                  itemCount: videoData[index].lVid.length,
                  itemBuilder: (context, i) {
                    dynamic video = videoData[index].lVid[i];
                    return FutureBuilder<Map<String, dynamic>>(
                      future: getUserData(video['UserId']),
                      builder: (context, userSnapshot) {
                        if (userSnapshot.connectionState == ConnectionState.waiting) {
                          return CircularProgressIndicator();
                        } else if (userSnapshot.hasError) {
                          print(userSnapshot.error);
                          return Text('Error: ${userSnapshot.error}');
                        } else {
                          String userName = userSnapshot.data?['fist name'] + userSnapshot.data?['last name'];
                          String avtUrl = userSnapshot.data?['image'] ?? '';
                          return Column(
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
                                child: FutureBuilder(
                                  future: _generateThumbnail(video['url']),
                                  builder: (context, snapshot1) {
                                    if (snapshot1.connectionState == ConnectionState.done) {
                                      return Container(
                                        height: 200,
                                        child: Image.memory(
                                          snapshot1.data!,
                                          fit: BoxFit.cover,
                                        ),
                                      );
                                    } else {
                                      return CircularProgressIndicator();
                                    }
                                  },
                                ),
                              ),
                              Padding(padding: const EdgeInsets.all(8)),
                              Row(
                                children: [
                                  Container(
                                    width: 200,
                                    child: Text(
                                      video['title'],
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
                                    ),
                                  )
                                ],
                              ),
                              Divider(),
                            ],
                          );
                        }
                      },
                    );
                  },
                ),
              ],
            );
          },
        );
      }
    },
  ),
),

   
        ],
      ),
    );
  }
}
