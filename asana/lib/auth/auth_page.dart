import 'package:asana/screen/SingUP.dart';
import 'package:asana/screen/login.dart';
import 'package:asana/screen/home.dart'; // Assurez-vous que le chemin est correct
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class Main_Page extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasData) {
          // Utilisez Home_Screen ici pour les utilisateurs connectés
          return Home_Screen();
        } else {
          return LogIN_Screen(() => Navigator.pushReplacement(
                context,
                MaterialPageRoute(
                  builder: (context) => SignUp_Screen(() {
                    Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                        builder: (context) => LogIN_Screen(() {}),
                      ),
                    );
                  }),
                ),
              ));
        }
      },
    );
  }
}
