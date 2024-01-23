import 'package:appdemo/common/toast.dart';
import 'package:appdemo/screens/CreateContent.dart';
import 'package:appdemo/screens/login.dart';
import 'package:appdemo/screens/notification.dart';
import 'package:appdemo/screens/profile_screen.dart';
import 'package:appdemo/screens/schedule_detail.dart';
import 'package:appdemo/widgets/content_card.dart';
import 'package:appdemo/widgets/form_container.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isLoggedIn = false;
  bool _isSearching = false;
  
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      backgroundColor: const Color.fromARGB(255, 182, 218, 184),
      appBar: AppBar(
         title: _isSearching
            ? TextField(
                onChanged: (value) {
                  // Xử lý sự kiện khi nội dung tìm kiếm thay đổi
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
            const DrawerHeader(
              decoration: BoxDecoration(
                color: Colors.green,
              ),
              child: UserAccountsDrawerHeader(
                decoration: BoxDecoration(color: Colors.green),
                accountName: Text(
                  "",
                  style: TextStyle(fontSize: 18),
                ),
                accountEmail: Text(""),
                currentAccountPictureSize: Size.square(50),
                currentAccountPicture: CircleAvatar(
                  backgroundColor: Color.fromARGB(255, 165, 255, 137),
                  child: Text(
                    "",
                    style: TextStyle(fontSize: 30.0, color: Colors.blue),
                  ), 
                ),
              ),
            ), 
            ListTile(
              leading: const Icon(Icons.person),
              title: const Text(' My Profile '),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ProfileScreen()),
                  );
                
              },
            ),
            ListTile(
              leading: const Icon(Icons.calendar_month),
              title: const Text(' My Schedule '),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => ScheduleScreen()),
                  );
              },
            ),
            ListTile(
              leading: const Icon(Icons.notifications),
              title: const Text(' Notifications '),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => Notifucation()),
                  );
              },
            ),
            ListTile(
              leading: const Icon(Icons.video_label),
              title: const Text('Content creation'),
              onTap: () {
                Navigator.push(
                  context,
                  CupertinoPageRoute(builder: (context) => CreateContent()),
                  );
              },
            ),
            ListTile(
              leading: _isLoggedIn ? const Icon(Icons.logout) : const Icon(Icons.login),
              title: _isLoggedIn ? const Text('Logout') : const Text('Login'),
              onTap: () async {
                if (_isLoggedIn) {
                  signOut();
                  setState(() {
                    _isLoggedIn = false;
                  });
                } else {
                  bool loginSuccess = await Navigator.push(
                    context,
                    CupertinoPageRoute(builder: (context) => LoginPage()),
                  );

                if (loginSuccess) {
                  setState(() {
                  _isLoggedIn = true;
                  });
                } else {
                }
              }
            },
          ),
          ],
        ),
      ),
      body: Center(
        child: Column(
        children: [
          ContentCard(),
          ],
      ),
      ),
    );
  }
}
