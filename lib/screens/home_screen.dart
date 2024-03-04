import 'package:appdemo/widgets/home_card.dart';
import 'package:appdemo/common/toast.dart';
import 'package:appdemo/widgets/content_card.dart';
import 'package:appdemo/widgets/listvdCard.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
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
  int selectedButtonIndex = 2;
  bool _isLoggedIn() {
    if(user != null){
       documentId =  user!.uid;
      return true;
    }else return false;
  }
  late String searchText ="" ;
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 182, 218, 184),
      appBar: AppBar(
        title: _isSearching
          ? TextField(
            onChanged: (value) {
              setState(() {
                searchText = value;
                print(searchText);
                _isSearching = searchText.isNotEmpty;
              });
            },
            decoration: const InputDecoration(
              hintText: 'Tìm Kiếm...',
              border: InputBorder.none,
            ),
            style: const TextStyle(color: Colors.white),
          )
          : const Text('Trang chủ'),
        backgroundColor: Colors.blue,
        actions:[
           (_isSearching) ?
           IconButton(
            icon:  Icon(Icons.cancel) ,
            onPressed: () {
              setState(() {
                searchText ="";
                _isSearching = false;
              });
            },
          ):IconButton(
              icon: Icon(Icons.search),
              onPressed: () {
                  setState(() {
                    _isSearching = true;
                   Navigator.of(context);
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
                    selectedButtonIndex = 2;
                    _isSearching = false;
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
                child: Text('Trang chủ'),
              ),
              
              SizedBox(width: 10), 
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    selectedButtonIndex = 1;
                    _isSearching = false;
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
                    selectedButtonIndex = 0;
                    _isSearching = false;
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
            ],
          ),
          if (selectedButtonIndex == 0)
          Container(
            width: 400,
            height: 550,
            child: ContentCard(searchText: _isSearching ? searchText : '',),
          ),
          if(selectedButtonIndex ==1)
           Container(
            width: 400,
            height: 550,
            child: ListVdCard(searchText: _isSearching ? searchText : '',)
          ),
          if(selectedButtonIndex ==2)
          Container(
            width: 400,
            height: 550,
            child: Homecard(searchText: _isSearching ? searchText : '',)
          ),
        ],
      ),
    );
  }
}

