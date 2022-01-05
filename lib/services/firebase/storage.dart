import 'dart:io';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';

class StorageApp {
  FirebaseStorage storage = FirebaseStorage.instance;

  Future<String?> doUpload(File arquivo) async {
    String ref = "user/${arquivo.path.split('/').last}";
    try {
      await storage.ref(ref).putFile(arquivo);
      return ref;
    } catch (e) {
      print(e);
    }
  }

  Future deleteFile(String path) async {
    await storage.ref(path).delete();
  }

  Future downloadFile(String path) async {
    Directory appDocDir = await getApplicationDocumentsDirectory();
    Directory livros =
        await Directory(appDocDir.path + "/myBooks").create(recursive: true);
    File downloadToFile = File('${livros.path}/${path.split("/").last}');
    try {
      await storage.ref(path).writeToFile(downloadToFile);
      return downloadToFile.path;
    } catch (e) {
      print(e);
    }
  }
}
