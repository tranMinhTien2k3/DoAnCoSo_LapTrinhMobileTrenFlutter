import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/services.dart';
import 'package:uuid/uuid.dart';

class Storage{
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // adding image to firebase storage
  Future<String> uploadImageToStorage(String childName, Uint8List file, bool isPost) async {
    // creating location to our firebase storage
    
    Reference ref =
        _storage.ref().child(childName).child(_auth.currentUser!.uid);
    if(isPost) {
      String id = const Uuid().v1();
      ref = ref.child(id);
    }

    // putting in uint8list format -> Upload task like a future but not future
    UploadTask uploadTask = ref.putData(
      file
    );

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    return downloadUrl;
  }

  Future<String> downloadImageFromStorage(String childName) async {
    try {
      // Tạo tham chiếu đến tệp trong Firebase Storage
      Reference ref = _storage.ref().child(childName);

      // Lấy URL tải về của tệp
      String downloadUrl = await ref.getDownloadURL();

      return downloadUrl;
    } catch (e) {
      // Xử lý lỗi nếu có
      print("Error downloading image: $e");
      return ""; // Hoặc có thể trả về một giá trị khác đại diện cho lỗi
    }
  }
}