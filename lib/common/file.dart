import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';

Future<String> uploadImg(String path, XFile img)async{
  final ref = FirebaseStorage.instance.ref(path).child(img.name);
  await ref.putFile(File(img.path));
  final url = await ref.getDownloadURL();
  return url;

}