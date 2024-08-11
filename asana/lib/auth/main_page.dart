import 'package:asana/screen/login.dart';
import 'package:asana/screen/home.dart'; // Assure-toi d'importer Home_Screen
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Main_Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Something went wrong'));
          } else if (snapshot.hasData) {
            return Home_Screen(); // Affiche Home_Screen si l'utilisateur est connecté
          } else {
            return LogIN_Screen(() {
              Navigator.of(context).pushReplacementNamed('/signup');
            });
          }
        },
      ),
    );
  }
}
