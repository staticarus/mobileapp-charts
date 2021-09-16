import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:projetflutter/views/HomePage.dart';
import 'package:firebase_auth/firebase_auth.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(FlutterFire());
}

/// We are using a StatefulWidget such that we only create the [Future] once,
/// no matter how many times our widget rebuild.
/// If we used a [StatelessWidget], in the event where [App] is rebuilt, that
/// would re-initialize FlutterFire and make our application re-enter loading state,
/// which is undesired.
class FlutterFire extends StatefulWidget {
  // Create the initialization Future outside of `build`:
  @override
  _FlutterFireState createState() => _FlutterFireState();
}

class _FlutterFireState extends State<FlutterFire> { /* Initialisation de la librairie Flutter pour interagir avec Firebase */

  final Future<FirebaseApp> _initialization = Firebase.initializeApp();

  @override
  Widget build(BuildContext context) { /* Initialisation */
    return FutureBuilder(
      future: _initialization,
      builder: (context, snapshot) {

        if (snapshot.hasError) {
          print('Erreur lors de l\'initialisation de FlutterFire. (0)');
        }
        if (snapshot.connectionState == ConnectionState.done) {
          print('FlutterFire est correctement initialisé ! (1)');
          firebaseAuth();
        }

        return MyApp(); /* Lancement de l'application principale */

      },
    );
  }

  void firebaseAuth() async {

    UserCredential userCredential = await FirebaseAuth.instance.signInAnonymously();
    User user = userCredential.user;

  }

}

// Lancement de l'application principale
class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Projet Flutter',
      theme: ThemeData(
        brightness: Brightness.dark,        
        primaryColor: Colors.green,
        visualDensity: VisualDensity.adaptivePlatformDensity,
      ),
      home: HomePage(),
    );
  }
}
