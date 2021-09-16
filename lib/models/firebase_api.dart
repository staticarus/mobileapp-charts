import 'dart:io';

import 'package:firebase_storage/firebase_storage.dart';
import 'package:path_provider/path_provider.dart';
import 'package:projetflutter/models/firebase_file.dart';

/* Rassemble les méthodes qui sont utilisées pour interagir avec Firebase et plus précisément le transfert de photos entre Raspberry et app Flutter */

class FirebaseMethods {
  static Future<List<String>> _getDownloadLinks(List<Reference> refs) async {
      Future.wait(refs.map((ref) => ref.getDownloadURL()).toList());
  }

  static Future downloadFile() async {
    final ref = FirebaseStorage.instance.ref('raspberryFolder/pictureToCrop.png');
    final dir = await getApplicationDocumentsDirectory();
    final file = File('${dir.path}/${ref.name}');
    await ref.writeToFile(file);
    return file;
  }

  static Future<FirebaseFile> getRaspberryPicture() async {
    final ref = FirebaseStorage.instance.ref('raspberryFolder');
    final result = await ref.child('imageToCrop');
    FirebaseFile firebaseFile;
    if (result != null)
      {
        print('Image existe, cool ->' + result.toString());
        var path = result.getDownloadURL().toString();
        firebaseFile = FirebaseFile(name: result.name, url: path);
      }
    else
      print('image nexiste pas, sans doute mauvais path');
    
    return firebaseFile;
  }

  // PLUS UTILISEE MAIS GARDEE SOUS LA MAIN AU CAS OÙ
  // static Future<List<FirebaseFile>> listAll(String path) async {
  //   final ref = FirebaseStorage.instance.ref('raspberryFolder');
  //   final result = await ref.listAll();

  //   final urls = await _getDownloadLinks(result.items);

  //   return urls
  //   .asMap()
  //   .map((index, url) {
  //     final ref = result.items[index];
  //     final name = ref.name;
  //     final file = FirebaseFile(name:name, url:url);

  //     return MapEntry(index, file);
  //   })
  //   .values
  //   .toList();
  // }

}