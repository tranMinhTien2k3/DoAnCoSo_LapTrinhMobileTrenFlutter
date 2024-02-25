
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
  double progressValue = 0.0;
  TextEditingController _controllerContent = TextEditingController();
  GlobalKey<FormState> key = GlobalKey();
  final user = FirebaseAuth.instance.currentUser;
  CollectionReference users = FirebaseFirestore.instance.collection("Users");
  String documentId = "";
  CollectionReference _reference = FirebaseFirestore.instance.collection('post');
  CollectionReference _video = FirebaseFirestore.instance.collection('video');
  List<String> imageUrls = [];
  String videourl = "";
  String? _selectedOption;
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
  List<String> options = ['Thêm'];
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: _backButton(),
        title: Text("Tạo nội dung"),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                if (key.currentState!.validate()) {
                  String title = _controllerContent.text; 
                  if(title == ""){
                     showToast(message: "Vui lòng nhập tiêu đề!");
                  }
                  else{
                  String idUser = user!.uid;

                  DateTime uniqueFileName = Timestamp.now().toDate();
                  List<String> likes = [];
                  List<String> comments = [];
                  Map<String, dynamic> dataToSend = {
                    'name': idUser,
                    'content': title,
                    'image': imageUrls,
                    'datePublished': uniqueFileName,
                    'like': likes,
                    'comment': comments,
                  };
                  if(videourl==""){
                     showToast(message: "Vui lòng tải lên video");
                  }else{
                  if (_selectedOption == null) {
                    _reference.add(dataToSend);
                  } else {
                    Map<String, dynamic> vidData = {
                      'UserId': idUser,
                      'title': title,
                      'url': videourl,
                      'time': uniqueFileName,
                    };

                    QuerySnapshot genreQuery = await FirebaseFirestore.instance
                        .collection('video')
                        .where('genre', isEqualTo: _selectedOption)
                        .get();

                    if (genreQuery.docs.isNotEmpty) {
                      String genreId = genreQuery.docs.first.id;
                      FirebaseFirestore.instance
                          .collection('video')
                          .doc(genreId)
                          .update({
                        'videolist': FieldValue.arrayUnion([vidData])
                      });
                    } else {
                      Map<String, dynamic> newGenreData = {
                        'genre': _selectedOption,
                        'videolist': [vidData]
                      };
                      FirebaseFirestore.instance.collection('video').add(newGenreData);
                    }
                  }

                  Navigator.pushNamed(context, '/home');
                  showToast(message: "Successful posting");
                }
                  }
                }
              } catch (error) {
                showToast(message: "Error occurred: $error");
              }
            },
            child: Text(
              'Đăng tải',
              style: TextStyle(fontSize: 16),             
            ),
          ),


        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Form(
          key: key,
          child:StreamBuilder<QuerySnapshot>(
          stream: _video.snapshots(),
          builder: (context, snapshot) {
            final documents = snapshot.data!.docs;
            List<String> genre = documents.map((doc) => doc['genre'].toString()).toList(); 
            options.addAll(genre);
            options=options.toSet().toList();
           return ListView(
            children: [
              TextFormField(
                controller: _controllerContent, 
                autofocus: true,
                decoration: InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: 'Tiêu đề của bài đăng (Bắt buộc)',
                  hintMaxLines: 4,
                ),
                keyboardType: TextInputType.multiline,
                maxLines: null,
              ),
              SizedBox(height: 20,),
              Text("Danh sách phát",
                style: TextStyle(fontSize: 20), 
              ),
              Row(
                children: [
                   DropdownButton<String>(
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
                        if (_selectedOption == 'Thêm') {
                          _showCustomInputDialog(context);
                        }
                      });
                    },
                    items: options.map<DropdownMenuItem<String>>((String value) {
                      return DropdownMenuItem<String>(
                        value: value,
                        child: Text(value),
                      );
                    }).toList()+
                    [
                        DropdownMenuItem<String>(
                          value: null,
                          child: Text('không chọn danh sách'),
                        ),
                    ]
                  ),
                ],
              ),
             
              (_selectedOption == null)?
              Column(
                children: [
                  imageUrls.isNotEmpty
                ? Column(
                    children: [
                      for (String imageUrl in imageUrls)
                        Column(
                          children: [
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
                                        imageUrls.remove(imageUrl);
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
                  ): Container(
                  child: Text("Đăng bài lên bản tin"),
                ),
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
                  SizedBox(
                    child: Text("Ảnh tải lên định dạng hợp lệ PNG, JPEG, GIF, BMP, WebP, và TIFF."),
                  ),
                  Divider(),
                  SizedBox(
                    child: Text("Đăng tải video hãy chọn danh sách phát để sắp xếp nội dung cho người xem "),
                  ),
                ],
              ):
            Column(
                children: [
                  IconButton(
                  onPressed: () async {
                    bool confirmUpload = await showDialog(
                      context: context,
                      builder: (BuildContext context) {
                        return AlertDialog(
                          title: Text("Lưu ý"),
                          content: Text("Chỉ được phép tải lên được 1 video"),
                          actions: <Widget>[
                            TextButton(
                              onPressed: () {
                                imageUrls = [];
                                Navigator.of(context).pop(true);
                              },
                              child: Text("Tiếp tục"),
                            ),
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).pop(false); 
                              },
                              child: Text("Hủy"),
                            ),
                          ],
                        );
                      },
                    );
                    if (confirmUpload == true) {
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
                        Task task = referenceVideoToUpload.putFile(
                          File(file.path),
                        );
                        task.snapshotEvents.listen((TaskSnapshot snapshot) {
                          double progress = (snapshot.bytesTransferred / snapshot.totalBytes) * 100;
                          print('Tiến trình tải lên: $progress%');
                          setState(() { progressValue = progress; });
                        });

                        setState(() {
                          videourl = newVideoUrl;
                        });
                      } catch (error) {
                        print('Lỗi khi tải lên video: $error');
                      }
                    }
                  },
                  icon: Icon(Icons.videocam),
                ),
                  SizedBox(
                    child: Text("Video tải lên với định dạng hợp lệ MP4, WebM, MKV, AVI, MOV, và FLV"),
                  ),
                  Divider(),
                  videourl.isNotEmpty?
                  Column(
                    children: [
                      VideoWidget(videoUrl: videourl),
                      Text(
                        'Tiến trình tải lên: ${progressValue.toStringAsFixed(2)}%',
                        style: TextStyle(fontSize: 20),
                      ),
                      ElevatedButton(
                        onPressed: () {
                          setState(() {
                            videourl = "";
                          });
                        },
                        child: Text('Xóa'),
                      ),
                    ],
                  )
                  :Text("Đăng tải lên bản tin hãy không chọn danh sách phát")
                ],
              ),
            ],
          );
          }
          ),
        ),
      ),
    );
  }
  void _showCustomInputDialog(BuildContext context) {
    String? customOption;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Nhập danh sách phát'),
          content: TextField(
            onChanged: (value) {
              customOption = value;
            },
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Hủy'),
            ),
            ElevatedButton(
              onPressed: () {
                setState(() {
                  options.add(customOption!);
                  options = options.toSet().toList();
                  _selectedOption = customOption;
                });
                Navigator.of(context).pop();
              },
              child: Text('Xác nhận'),
            ),
          ],
        );
      },
    );
  }

}
