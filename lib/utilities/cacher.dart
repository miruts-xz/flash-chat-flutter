import 'dart:async';
import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart' as storage;

class Cacher {
  static Future<File> downloadImage(String uid, String filename) async {
    Directory tempDir = Directory.systemTemp;
    File file = File('${tempDir.path}/$uid/$filename');
    final storage.StorageReference ref = storage.FirebaseStorage.instance
        .ref()
        .child('users')
        .child(uid)
        .child('images')
        .child(filename);
    final storage.StorageFileDownloadTask task = ref.writeToFile(file,);

    return await task.future.then((value) => file, onError: (error) => null);
  }
}
