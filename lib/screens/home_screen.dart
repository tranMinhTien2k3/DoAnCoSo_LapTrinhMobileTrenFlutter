import 'package:appdemo/common/toast.dart';
import 'package:appdemo/widgets/content_card.dart';
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
  bool _isSearching = false;
  String documentId="";
  
  GetOptions? get email => null;
  bool _isLoggedIn() {
    if(user != null){
       documentId =  user!.uid;
      return true;
    }else return false;
  }
    void handleSearch(String query) {
    List<String> searchList = [];
    List<String> _data = [''];
    List<String> _searchResult = [];
    if (query.isNotEmpty) {
      _data.forEach((item) {
        if (item.toLowerCase().contains(query.toLowerCase())) {
          searchList.add(item);
        }
      });
    } else {
      searchList.addAll(_data);
    }

    setState(() {
      _searchResult.clear();
      _searchResult.addAll(searchList);
    });
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 182, 218, 184),
      appBar: AppBar(
         title: _isSearching
            ? TextField(
                onChanged: (value) {
                  handleSearch(value);
                },
                decoration: const InputDecoration(
                  hintText: 'Search...',
                  border: InputBorder.none,
                ),
                style: const TextStyle(color: Colors.white),
              )
            : const Text('Home'),
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
                accountEmail: Text(_isLoggedIn()?user!.email!:"No account"),
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
              title: const Text(' My Profile '),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/profile'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text(' My Schedule '),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/schedule'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text(' Notifications '),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/notifucation'):showToast(message: "You cant login");
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_label),
              title: const Text('Content creation'),
              onTap: () {
                _isLoggedIn()?
                Navigator.pushNamed(context, '/content'):showToast(message: "You cant login");
              },
            ),
            _isLoggedIn()==false?
            ListTile(
              leading: const Icon(Icons.login),
              title: const Text('Login'),
              onTap: () {
               Navigator.pushNamed(context, '/login');
              },    
          ):
          ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Logout'),
              onTap: () {
                signOut(context);
            },    
          ),
          ],
        ),
      ),
      body: ContentCard(),
    );
  }
}
