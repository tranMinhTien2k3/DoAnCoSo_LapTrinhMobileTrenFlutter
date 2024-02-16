
import 'dart:io';
import 'package:appdemo/common/toast.dart';
import 'package:appdemo/widgets/media.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:image_picker/image_picker.dart';

class CreateContent extends StatefulWidget {
  const CreateContent({super.key});

  @override
  State<CreateContent> createState() => _CreateContent();
}

class _CreateContent extends State<CreateContent> {
  
  TextEditingController _controllerContent = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  String documentId = "";
  CollectionReference _reference = FirebaseFirestore.instance.collection('post');
  List<String> imageUrls = [];
  bool _isVideoUrl(String url) {
            return url.contains("/video");
          }
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
                controller: _controllerContent, 
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
                            (_isVideoUrl(imageUrl)) ?
                          VideoWidget(videoUrl: imageUrl):
                          ImageWidget(imageUrl: imageUrl),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                ElevatedButton(
                                  onPressed: () async {
                                    ImagePicker imagePicker = ImagePicker();
                                    XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                                    if (file == null) return;

                                    try {
                                      var uuid = Uuid();
                                      var randomName = uuid.v4();
                                      Reference referenceRoot = FirebaseStorage.instance.ref();
                                      Reference referenceDirImages = referenceRoot.child('img');
                                      Reference referenceImageToUpload = referenceDirImages.child(randomName);

                                      await referenceImageToUpload.putFile(File(file.path));
                                      String newImageUrl = await referenceImageToUpload.getDownloadURL();

                                      setState(() {
                                        imageUrls.add(newImageUrl);
                                      });
                                    } catch (error) {
                                      print('Lỗi khi tải lên: $error');
                                    }
                                  },
                                  child: Text('Thay Đổi'),
                                ),
                                SizedBox(width: 10),
                                ElevatedButton(
                                  onPressed: () {
                                    setState(() {
                                      imageUrls.remove(imageUrl);
                                    });
                                  },
                                  child: Text('Xóa'),
                                ),
                              ],
                            ),
                          ],
                        ),
                    ],
                  )
                : Container(),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickImage(source: ImageSource.gallery);

                      if (file == null) return;

                      try {
                        var uuid = Uuid();
                        var randomName = uuid.v4();
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference referenceDirImages = referenceRoot.child('img');
                        Reference referenceImageToUpload = referenceDirImages.child(randomName);

                        await referenceImageToUpload.putFile(File(file.path));
                        String newImageUrl = await referenceImageToUpload.getDownloadURL();

                        setState(() {
                          imageUrls.add(newImageUrl);
                        });
                      } catch (error) {
                        print('Lỗi khi tải lên ảnh: $error');
                      }
                    },
                    icon: Icon(Icons.camera_alt),
                  ),
                  IconButton(
                    onPressed: () async {
                      ImagePicker imagePicker = ImagePicker();
                      XFile? file = await imagePicker.pickVideo(source: ImageSource.gallery);

                      if (file == null) return;

                      try {
                        var uuid = Uuid();
                        var randomName = uuid.v4();
                        Reference referenceRoot = FirebaseStorage.instance.ref();
                        Reference referenceDirVideos = referenceRoot.child('video');
                        Reference referenceVideoToUpload = referenceDirVideos.child(randomName);

                        await referenceVideoToUpload.putFile(File(file.path));
                        String newVideoUrl = await referenceVideoToUpload.getDownloadURL();

                        setState(() {
                          imageUrls.add(newVideoUrl);
                        });
                      } catch (error) {
                        print('Lỗi khi tải lên video: $error');
                      }
                    },
                    icon: Icon(Icons.videocam),
                  ),
                ],
              ),

              ElevatedButton(
                  onPressed: () async {

                    if (key.currentState!.validate()) {
                      String itemQuantity = _controllerContent.text; 
                      String idUser = user!.uid;
                      DateTime uniqueFileName = Timestamp.now().toDate();
                      List<String> likes = [];
                      List<String> comments = [];
                      Map<String, dynamic> dataToSend = {
                        'name': idUser,
                        'content': itemQuantity,
                        'image': imageUrls,
                        'datePublished': uniqueFileName,
                        'like': likes,
                        'comment':comments,
                      };
                       _reference.add(dataToSend);
                       Navigator.pushNamed(context, '/home');
                      showToast(message: "Successful posting");
                    }
                  },
                  child: Text('Submit')),
                  GestureDetector(
                    onTap: () {
                      Navigator.pushNamed(context, '/mycontent');
                    },
                    child: Text(
                      "My content",
                      style: TextStyle(
                        color: Colors.blue,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
            ],
          ),
        ),
      ),
    );
  }
}
