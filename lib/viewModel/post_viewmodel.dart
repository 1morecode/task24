import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:message_app/model/post.dart';
import 'package:message_app/res/global_data.dart';

class PostViewModel extends ChangeNotifier {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  FirebaseStorage storage = FirebaseStorage.instance;
  FirebaseAuth firebaseAuth = FirebaseAuth.instance;
  String imageUrl = '';
  TextEditingController textEditingController = TextEditingController();
  File imageFile = File("");
  Uint8List image = Uint8List(0);
  bool isLoading = false;

  Future getImage(ImageSource imageSource) async {
    ImagePicker imagePicker = ImagePicker();
    PickedFile pickedFile = (await imagePicker.getImage(source: imageSource))!;
    imageFile = File(pickedFile.path);
    image = await imageFile.readAsBytes();
    notifyListeners();
  }

  Future postBlog() async {
    isLoading = true;
    notifyListeners();
    String fileName = DateTime
        .now()
        .millisecondsSinceEpoch
        .toString();

    Reference reference = storage.ref().child(fileName);
    UploadTask uploadTask = reference.putFile(imageFile);
    await uploadTask.then((res) async {
      imageUrl = await res.ref.getDownloadURL();
      saveBlog();
    });
    image = Uint8List(0);
    imageUrl = "";
    imageFile = File("");
    textEditingController.clear();
    isLoading = false;
    notifyListeners();
  }

  void saveBlog() {
    if (imageUrl.isNotEmpty && textEditingController.text.isNotEmpty) {
      final DocumentReference documentReference = _db
          .collection('blogs')
          .doc(DateTime
          .now()
          .millisecondsSinceEpoch
          .toString());

      documentReference
          .set(<String, dynamic>{
        'image': imageUrl,
        'title': textEditingController.text,
        'created_at': DateTime.now(),
        'created_by': firebaseAuth.currentUser!.uid
      })
          .then((dynamic success) {})
          .catchError((dynamic error) {
        print(error);
      });
      GlobalData.showSnackBar("Saved Successfully!",
          GlobalData.globalNavigatorKey.currentState!.context, Colors.green);
    } else {
      GlobalData.showSnackBar("All fields are mandatory!",
          GlobalData.globalNavigatorKey.currentState!.context, Colors.red);
    }
  }

  Stream<QuerySnapshot> getPostList() {
    Stream<QuerySnapshot> qs = _db.collection('blogs').snapshots();

    return qs;
  }
}
