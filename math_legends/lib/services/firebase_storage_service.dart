import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';

class FirebaseStorageService {
  final FirebaseStorage _storage = FirebaseStorage.instance;

  Future<String> uploadProfilePic({
    required String uid,
    required File imageFile,
  }) async {
    final ref = _storage
        .ref()
        .child('profile_pics')
        .child('$uid.jpg');

    await ref.putFile(imageFile);

    return await ref.getDownloadURL();
  }
}
