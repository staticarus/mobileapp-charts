import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'dart:async';
import 'dart:io';
import 'package:image_cropper/image_cropper.dart';
//import 'package:image_picker/image_picker.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:projetflutter/models/firebase_api.dart';

/* Classe chargée de toutes les actions en rapport avec le travail des photos/images */

FirebaseFirestore firestore = FirebaseFirestore.instance; // Objet firebase

class MyCropper extends StatefulWidget {
  @override
  _MyCropperState createState() => _MyCropperState();
}

/* Gestion de la vue selon l'état de l'image ---------------- */
enum AppState {
  free,
  picked,
  cropped,
}

class _MyCropperState extends State<MyCropper> {
  AppState state;
  File imageFile;
  String url;


  @override /* Etat initial au chargement de la vue ---------------- */
  void initState() {
    super.initState();
    state = AppState.free;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Image Cropper"),
      ),
      body: Center(
        child: imageFile != null ? Image.file(imageFile) : Container(),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepOrange,
        onPressed: () {
          if (state == AppState.free){ /* 1) téléchargement depuis firebase storage ---------------- */
              _downloadImageMethod();
              ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text ('Image correctement téléchargée !')
            ));
            }
          else if (state == AppState.picked){ /* 2) outil de crop ---------------- */
            _cropImage();
          }
          else if (state == AppState.cropped){ /* envoi de l'image cropée vers firebase storage ---------------- */
            _uploadImage();
            _notifyImageIsCropped();
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: const Text ('Image correctement envoyée !')
            ));
          }
        },
        child: _buildButtonIcon(),
      ),
    );
  }

  Widget _buildButtonIcon() { /* Etat du bouton qui diffère selon l'état de l'app ---------------- */
    if (state == AppState.free)
      return Icon(Icons.add);
    else if (state == AppState.picked)
      return Icon(Icons.crop);
    else if (state == AppState.cropped)
      return Icon(Icons.send_to_mobile);
    else
      return Container();
  }

  Future<Null> _downloadImageMethod() async {
    imageFile = await FirebaseMethods.downloadFile(); /* Image envoyée par le Raspberry Pi ---------------- */
    if (imageFile != null) {
      setState(() {
        state = AppState.picked;
      });
      print('ImageFile exists : state changed from free to picked ! :)');
    }
  }

  Future<Null> _cropImage() async {
    File croppedFile = await ImageCropper.cropImage(
        sourcePath: imageFile.path,
        aspectRatioPresets: Platform.isAndroid /* popotte de la librairie image_cropper ---------------- */
            ? [
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio16x9
              ]
            : [
                CropAspectRatioPreset.original,
                CropAspectRatioPreset.square,
                CropAspectRatioPreset.ratio3x2,
                CropAspectRatioPreset.ratio4x3,
                CropAspectRatioPreset.ratio5x3,
                CropAspectRatioPreset.ratio5x4,
                CropAspectRatioPreset.ratio7x5,
                CropAspectRatioPreset.ratio16x9
              ],
        androidUiSettings: AndroidUiSettings(
            toolbarTitle: 'Recadrage',
            toolbarColor: Colors.deepOrange,
            toolbarWidgetColor: Colors.white,
            initAspectRatio: CropAspectRatioPreset.original,
            lockAspectRatio: false),
    );
    if (croppedFile != null) {
      imageFile = croppedFile; /* Enregistrement des modifs dans cette variable de type File ---------------- */
      setState(() {
        state = AppState.cropped;
      });
    }
  }
  
  Future<Null> _uploadImage() async {
    final _storage = FirebaseStorage.instance;
    String imageUrl;

    await Permission.photos.request();  /* Droits d'accès en lecture/écriture pour IOS ---------------- */
    var permissionStatus = await Permission.photos.status; /* idem */
    
    if (permissionStatus.isGranted) {

      if (imageFile != null) {
        var snapshot = await _storage.ref()
        .child('flutterFolder/croppedPicture') /* Envoi de l'image retouchée à cet emplacement de firebase storage ---------------- */
        .putFile(imageFile);

        var downloadUrl = await snapshot.ref.getDownloadURL();

        setState(() {
          imageUrl = downloadUrl;
        });
        print(imageUrl);
        print('Image uploadée !');
      } else {
        print('No Path Received');
      }
    } else {
      print('Grant Permissions and try again');
    }
  }

  void _notifyImageIsCropped() { /* Modifie le fichier config sur firestore pour indiquer au raspberry qu'il peut récupérer l'image retravaillée ----- */
    var collection = firestore.collection('config');
    collection.doc('ConfigFile')
      .update({'isCropped': true})
      .then((value) => print('Image mise à jour sur Firebase'))
      .catchError((error) => print("Màj de l'image échouée: $error"));
  }

}
