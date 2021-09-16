import 'package:flutter/material.dart';
import 'package:projetflutter/views/DrawerCompteurs.dart';
import 'package:projetflutter/views/Cropper.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

FirebaseFirestore firestore = FirebaseFirestore.instance;

class HomePage extends StatefulWidget {
  HomePage({Key key}) : super(key: key);

  @override
  _HomePageState createState() => _HomePageState();
}

/* Page d'accueil de l'application ----- */

class _HomePageState extends State<HomePage> {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Page d'accueil")),
      body: ListView(children: [
          Container(
            padding: EdgeInsets.all(30),
            child: 
            Text('Projet Caméra/Compteurs + Firebase',
                style: TextStyle(fontSize: 20,), textAlign: TextAlign.center,)
          ),
          Divider(height: 1),
          ListTile(
            leading: Icon(Icons.bar_chart),
            title: Text('Pour accéder aux graphes -> menu déroulant sur la gauche.'),
            trailing: Text('')),
          ListTile(
            leading: Icon(Icons.insert_photo_rounded),
            title: Text('Pour travailler le texte pris en photo par le raspberry, cliquer sur le bouton ci-dessous.'),
            trailing: Text('')),
          ButtonTheme(minWidth: 150, height: 50, child: 
            ElevatedButton(onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => MyCropper()),
              );
            },
            child: Text('Redimensionner la photo', style: TextStyle(fontSize: 20)), style: ButtonStyle(
              backgroundColor: MaterialStateProperty.all<Color>(Colors.green[400]),
            ),),
          ),
          Divider(height: 30,),
          ListTile(
            leading: Icon(Icons.all_inbox),
            title: Text('Pour choisir le compteur actuel, cliquer sur le bouton coloré correspondant.'),
            trailing: Text('')),
          Center(child:
            ButtonTheme(minWidth: 150, height: 50, child: 
              ElevatedButton(
                onPressed: () async {
                  //...
                  await _changeMeter(1);
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text ('Compteur actuel réglé sur électrique')));
              }, child: Text('Électrique', style: TextStyle(fontSize: 20)), style: ButtonStyle(
                backgroundColor: MaterialStateProperty.all<Color>(Colors.yellow[400]),
              ),),
            ),
          ),
          Center(child: 
            ButtonTheme(minWidth: 150, height: 50, child: 
              ElevatedButton(
                onPressed: () async {
                  //...
                  await _changeMeter(2);
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text ('Compteur actuel réglé sur eau')));
                }, child: Text('Eau', style: TextStyle(fontSize: 20)), style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.blue[400]),
                ),
              ),
            ),
          ),
          Center(child: 
            ButtonTheme(minWidth: 150, height: 50, child: 
              ElevatedButton(
                onPressed: () async {
                  //...
                  await _changeMeter(3);
                  ScaffoldMessenger.of(context).showSnackBar(
                  SnackBar(content: const Text ('Compteur actuel réglé sur gaz')));
                }, child: Text('Gaz', style: TextStyle(fontSize: 20)), style: ButtonStyle(
                  backgroundColor: MaterialStateProperty.all<Color>(Colors.purple[400]),
                ),
              ),
            ),
          ),
        ]),
      drawer: DrawerCompteurs()
    );
  }
}

void _changeMeter(int nb) { /* utilisation du fichier config Firebase afin de synchroniser le choix de compteur avec le raspberry pi */
/* 1 = électrique
*  2 = eau
*  3 = gaz */
  var collection = firestore.collection('config');
  collection.doc('ConfigFile')
    .update({'currentMeter': nb})
    .then((value) => print('Compteur actuel mis à jour'))
    .catchError((error) => print("Màj du CompteurChoisi échouée: $error"));
}
