
import 'dart:io';
import 'package:appdemo/common/toast.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';

import 'package:image_picker/image_picker.dart';
// ... existing imports ...

class CreateContent extends StatefulWidget {
  const CreateContent({super.key});

  @override
  State<CreateContent> createState() => _CreateContent();
}

class _CreateContent extends State<CreateContent> {
  TextEditingController _controllerContent = TextEditingController(); // New TextEditingController
  GlobalKey<FormState> key = GlobalKey();
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  String documentId = "";
  CollectionReference _reference = FirebaseFirestore.instance.collection('post');
  bool _isLoggedIn() {
    if (user != null) {
      documentId = user!.uid;
      return true;
    } else
      return false;
  }

   List<String> imageUrls = [];

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
    return Scaffold(
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Post Content"),
        centerTitle: false,
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child: ListView(
            children: [
              TextFormField(
                controller: _controllerContent, // New controller
                autofocus: true,
                decoration: InputDecoration(
                  border: InputBorder.none,
                  hintText: 'Writing',
                  hintMaxLines: 4,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              imageUrls.isNotEmpty
                  ? Column(
                      children: [
                        for (String imageUrl in imageUrls)
                          Column(
                            children: [
                              Image.network(imageUrl),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  ElevatedButton(
                                    onPressed: () async {
                                      ImagePicker imagePicker = ImagePicker();
                    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                    if (file == null) return;

                    try {
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages = referenceRoot.child('img');
                      Reference referenceImageToUpload = referenceDirImages.child('name');

                      await referenceImageToUpload.putFile(File(file.path));
                      String newImageUrl = await referenceImageToUpload.getDownloadURL();

                      setState(() {
                        imageUrls.add(newImageUrl);
                      });
                    } catch (error) {
                      print('Lỗi khi tải lên ảnh: $error');
                    }
                                    },
                                    child: Text('Thay Đổi Ảnh'),
                                  ),
                                  SizedBox(width: 10),
                                  ElevatedButton(
                                    onPressed: () {
                                      setState(() {
                                        imageUrls.remove(imageUrl);
                                      });
                                    },
                                    child: Text('Xóa Ảnh'),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ],
                    )
                  : Container(),
              IconButton(
                 onPressed: () async {
                    ImagePicker imagePicker = ImagePicker();
                    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                    if (file == null) return;

                    try {
                      Reference referenceRoot = FirebaseStorage.instance.ref();
                      Reference referenceDirImages = referenceRoot.child('img');
                      Reference referenceImageToUpload = referenceDirImages.child('name');

                      await referenceImageToUpload.putFile(File(file.path));
                      String newImageUrl = await referenceImageToUpload.getDownloadURL();

                      setState(() {
                        imageUrls.add(newImageUrl);
                      });
                    } catch (error) {
                      print('Lỗi khi tải lên ảnh: $error');
                    }
                  },
                  icon: Icon(Icons.camera_alt)),

              ElevatedButton(
                  onPressed: () async {

                    if (key.currentState!.validate()) {
                      String itemQuantity = _controllerContent.text; 
                      String idUser = user!.uid;
                      String uniqueFileName = DateTime.now().millisecondsSinceEpoch.toString();
                      Map<String, dynamic> dataToSend = {
                        'name': idUser,
                        'content': itemQuantity,
                        'image': imageUrls,
                        'datePublished': uniqueFileName,
                      };

                       _reference.add(dataToSend);
                       Navigator.pushNamed(context, '/home');
                      showToast(message: "Successful posting");
                    }
                  },
                  child: Text('Submit'))
            ],
          ),
        ),
      ),
    );
  }
}
