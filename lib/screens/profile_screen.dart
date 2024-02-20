import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreen();
}

class _ProfileScreen extends State<ProfileScreen>{
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  String documentId="";
  String imageUrl = '';
  bool _isLoggedIn() {
    if(user != null){
       documentId =  user!.uid;
      return true;
    }else return false;
  }
  Future<void> editProfile(String field)async{
    String newValue ="";
    await showDialog(
      context: context, 
      builder:(context)=>AlertDialog(
        backgroundColor: Color.fromARGB(255, 175, 196, 175),
        title: Text("Edit: "+field),
        content: TextField(
          autofocus: true,
          style: TextStyle(color: Colors.black,fontWeight: FontWeight.bold),
          decoration: InputDecoration(
            hintText: "Enter new $field",
            hintStyle: TextStyle(color: Color.fromARGB(57, 45, 45, 109),fontWeight: FontWeight.bold)
          ),
          onChanged: (value){
            newValue = value;
          },
        ),
        actions: [
          TextButton(
            onPressed: (){
              Navigator.pop(context);
            },
          child: Text('cancel')),
          TextButton(
            onPressed: (){
              Navigator.of(context).pop(newValue);
            },
          child: Text('Save'))
        ],
      ),
    );
    if(newValue.trim().length>0){
      await  users.doc(documentId).update({field:newValue});  
      Navigator.pushNamed(context, '/profile');
      }
  }
  Widget _backButton() {
    return InkWell(
      onTap: () {
        Navigator.pushNamed(context, '/home');
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
  itemProfile(String title, String subtitle,String n, IconData iconData) {
    return Container(
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          boxShadow: [
            BoxShadow(
                offset: Offset(0, 5),
                color: Colors.deepOrange.withOpacity(.2),
                spreadRadius: 2,
                blurRadius: 10
            )
          ]
      ),
      child: ListTile(
        title: Text(title),
        subtitle: Text(subtitle),
        leading: Icon(iconData),
        trailing: IconButton(
          icon: Icon(Icons.settings),
          color: Colors.grey.shade400,
          onPressed: () {
            editProfile(n);
          },
          ),
        tileColor: Colors.white,
      ),
    );
  } 
  @override
  Widget build(BuildContext context) {
    
    return Scaffold(
      resizeToAvoidBottomInset: false,
      appBar: AppBar(
        backgroundColor: Colors.green[200],
        leading: _backButton(),
        title:Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text("Profile"),
            Text(
              _isLoggedIn()?user!.email!:"Please Sign In",
              style: TextStyle(fontSize: 12),
            ),
          ],
        )  
      ),
      body: Padding(
        padding: EdgeInsets.symmetric(horizontal: 30.0),
        child: FutureBuilder<DocumentSnapshot>(
          future: users.doc(documentId).get(),
          builder: ((context,snapshot) {
          if(snapshot.connectionState==ConnectionState.done){
            Map<String, dynamic>? data = 
            snapshot.data!.data() as Map<String,dynamic>?;
             if (data == null || data.isEmpty) {
              users.doc(documentId).set({
                'fist name': '',
                'last name': '',
                'phone': '',
                'address': '',
                'age': '',
                'email': user?.email,
              });
              
              data = {
                'fist name': '',
                'last name': '',
                'phone': '',
                'address': '',
                'age': '',
                'email': user?.email,
              };
            }
            return ListView(
              shrinkWrap: true,
              children: [
            ListTile(
              trailing: IconButton(
                  onPressed: () async {

                    ImagePicker imagePicker = ImagePicker();
                    XFile? file =
                        await imagePicker.pickImage(source: ImageSource.gallery);
                    print('${file?.path}');

                    if (file == null) return;
                    var uuid = Uuid();
                      var randomName = uuid.v4();
                    Reference referenceRoot = FirebaseStorage.instance.ref();
                    Reference referenceDirImages =
                        referenceRoot.child('avt');
                    Reference referenceImageToUpload =
                        referenceDirImages.child(randomName);

                    try {
                      await referenceImageToUpload.putFile(File(file.path));
                      imageUrl = await referenceImageToUpload.getDownloadURL();
                    } catch (error) {
                    }
                    users.doc(documentId).update({'image':imageUrl});
                  },
                  icon: Icon(Icons.camera_alt)),
                  
                  tileColor: Colors.white,
                  ),
            (data['image'] != null)
            ? CircleAvatar(
            radius: 80.0,
            backgroundImage: NetworkImage(data['image']),
            backgroundColor: Colors.transparent,
            )
            : CircleAvatar(
            radius: 80.0,
            backgroundImage: AssetImage('assets/img/user.png'),
            ),
            const SizedBox(height: 20),
            itemProfile('Fist Name', '${data['fist name']}','fist name',Icons.badge_outlined),
            const SizedBox(height: 10),
            itemProfile('Last Name', '${data['last name']}','last name',Icons.badge),
            const SizedBox(height: 10),
            itemProfile('Phone', '${data['phone']}','phone',Icons.phone),
            const SizedBox(height: 10),
            itemProfile('Address','${data['address']}','address',Icons.place),
            const SizedBox(height: 10),
            itemProfile('Age', '${data['age']}','age',Icons.cake),
            const SizedBox(height: 20,),
          ],
        );
       }else return Text('Loading...');
      }
    )
  )
      )
      );
  }
}
  