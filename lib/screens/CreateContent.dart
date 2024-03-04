import 'dart:io';
import 'package:toggle_switch/toggle_switch.dart';
import 'package:appdemo/common/toast.dart';
import 'package:appdemo/widgets/media.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:uuid/uuid.dart';

class CreateContent extends StatefulWidget {
  const CreateContent({Key? key}) : super(key: key);

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
  List<String> options = [];
  bool isPost = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Tạo nội dung"),
        centerTitle: false,
        actions: [
          TextButton(
            onPressed: () async {
              try {
                if (key.currentState!.validate()) {
                  String title = _controllerContent.text;
                  if (title == "") {
                    showToast(message: "Vui lòng nhập tiêu đề!");
                  } else {
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
                    if (isPost) {
                        _reference.add(dataToSend);
                        showToast(message: "Đăng bài thành công");
                        Navigator.pushNamed(context, '/home');
                    } else {
                      if (videourl.isEmpty) {
                        showToast(message: "Vui lòng tải lên video");
                      } else {
                        if (_selectedOption == null) {
                          showToast(message: "Vui lòng chọn danh sách video");
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
                          showToast(message: "Đăng video thành công");
                          Navigator.pushNamed(context, '/home');
                        }
                      }
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
          child: StreamBuilder<QuerySnapshot>(
            stream: _video.snapshots(),
            builder: (context, snapshot) {
              final documents = snapshot.data!.docs;
              List<String> genre = documents.map((doc) => doc['genre'].toString()).toList();
              options.addAll(genre);
              options = options.toSet().toList();
              return ListView(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceAround,
                    children: [
                      ToggleSwitch(
                        customWidths: [90.0, 150.0],
                        initialLabelIndex: 0,
                        totalSwitches: 2,
                        activeBgColor: [isPost ? Colors.green : Colors.grey],
                        inactiveBgColor: isPost ? Colors.grey : Colors.green, 
                        labels: ["Bản tin", "Danh sách video"],
                        onToggle: (index) {
                          index;
                          if(index==0){
                            setState(() {
                            isPost = true;
                          });
                          }else{
                            setState(() {
                            isPost = false;
                          });
                          }
                        },
                      ),
                    ],
                  ),
                  SizedBox(height: 20),
                  TextFormField(
                    controller: _controllerContent,
                    autofocus: true,
                    decoration: InputDecoration(
                      border: OutlineInputBorder(),
                      hintText: isPost?'Nội dung của bài đăng (Bắt buộc)':'Tiêu đề của video (Bắt buộc)',
                      hintMaxLines: 4,
                    ),
                    keyboardType: TextInputType.multiline,
                    maxLines: null,
                  ),
                  SizedBox(height: 20),
                  if (!isPost)
                    Row(
                      children: [
                        Expanded(
                          child: TextFormField(
                            decoration: InputDecoration(
                              border: OutlineInputBorder(),
                              hintText: 'Tên danh sách video',
                            ),
                            onChanged: (value) {
                              setState(() {
                                _selectedOption = value;
                              });
                            },
                          ),
                        ),
                        SizedBox(width: 10),
                        ElevatedButton(
                          onPressed: () {
                            if (_selectedOption != null && _selectedOption!.isNotEmpty) {
                              setState(() {
                                options.add(_selectedOption!);
                                options = options.toSet().toList();
                              });
                            }
                          },
                          child: Text('Thêm'),
                        ),
                      ],
                    ),
                  if (!isPost)
                    SizedBox(height: 10),
                  if (!isPost)
                    DropdownButton<String>(
                    value: _selectedOption,
                    onChanged: (String? newValue) {
                      setState(() {
                        _selectedOption = newValue;
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
                        child: Text('Chọn danh sách'),
                      ),
                    ]
                  ),
                  SizedBox(height: 20),
                  if (isPost)
                    Column(
                      children: [
                        Row(
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                ImagePicker imagePicker = ImagePicker();
                                XFile? file =
                                    await imagePicker.pickImage(source: ImageSource.gallery);
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
                              child: Icon(Icons.camera_alt),
                            ),
                            if (imageUrls.isNotEmpty)
                          Column(
                            children: [
                              for (String imageUrl in imageUrls)
                              Column(
                                children: [
                                  Container(
                                        height: 150,
                                        child: ImageWidget(imageUrl: imageUrl),
                                      ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      ElevatedButton(
                                        onPressed: () async {
                                          ImagePicker imagePicker = ImagePicker();
                                          XFile? file =
                                              await imagePicker.pickImage(source: ImageSource.gallery);
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
                          ),
                        if (imageUrls.isEmpty)
                          Container(
                            child: Text("Chọn biểu tượng camera để tải lên hình ảnh"),
                          ),
                          ],
                        ),
                        SizedBox(
                          child: Text("Ảnh tải lên định dạng hợp lệ PNG, JPEG, GIF, BMP, WebP, và TIFF."),
                        ),
                        Divider(),
                        SizedBox(
                          child: Text("Đăng tải video hãy chọn danh sách phát để sắp xếp nội dung cho người xem "),
                        ),
                      ],
                    ),
                  if (!isPost)
                    Column(
                      children: [
                        Row(
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
                                      setState(() {
                                        progressValue = progress;
                                      });
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
                            videourl.isNotEmpty
                                ? Column(
                                    children: [
                                      Text(
                                        'Tiến trình tải lên: ${progressValue.toStringAsFixed(2)}%',
                                        style: TextStyle(fontSize: 20),
                                      ),
                                      Container(
                                        height: 150,
                                        child: VideoWidget(videoUrl: videourl),
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
                                : Text("Ấn vào biểu tượng máy quay để tải lên video")
                          ],
                        ),
                        SizedBox(
                          child: Text("Video tải lên với định dạng hợp lệ MP4, WebM, MKV, AVI, MOV, và FLV"),
                        ),
                        Divider(),
                      ],
                    ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
