import 'package:flutter/material.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen>{
   Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pop(context);
      },
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: 10),
        child: Row(
          children: <Widget>[
            Container(
              padding: EdgeInsets.only(left: 0, top: 10, bottom: 10),
              child: Icon(Icons.keyboard_arrow_left, color: Colors.black),
            ),
          ],
        ),
      ),
    );
  }
  @override
  Widget build(BuildContext context) {
    final Map<String, dynamic> userProfile = {
    "address": "Nam Dinh",
    "gender": true,
    "occupation": "free",
    "age": 20,
    "username": "Tien",
  };
     return Scaffold(
      
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Profile"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            ListTile(
              title: Text("Username"),
              subtitle: Text(userProfile["username"]),
            ),
            ListTile(
              title: Text("Gender"),
              subtitle: Text(userProfile["gender"] ? 'Male' : 'Female'),
            ),
            ListTile(
              title: Text("Age"),
              subtitle: Text(userProfile["age"].toString()),
            ),
            ListTile(
              title: Text("Address"),
              subtitle: Text(userProfile["address"]),
            ),
            ListTile(
              title: Text("Occupation"),
              subtitle: Text(userProfile["occupation"]),
            ),
          ],
        ),
      ),
     );
  }
}
  