import 'dart:io'; // Pour les opérations sur les fichiers
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart'; // Pour choisir des images
import 'package:firebase_auth/firebase_auth.dart'; // Assurez-vous d'avoir ce package dans pubspec.yaml
import 'package:firebase_storage/firebase_storage.dart'; // Pour le stockage des images
import 'package:cloud_firestore/cloud_firestore.dart'; // Pour stocker les informations supplémentaires dans Firestore

class ProfileScreen extends StatefulWidget {
  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final _auth = FirebaseAuth.instance;
  final _firestore = FirebaseFirestore.instance;
  final _nameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  File? _profileImage;
  String? _profileImageUrl;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    User? user = _auth.currentUser;
    if (user != null) {
      _nameController.text = user.displayName ?? '';
      _phoneController.text = ''; // Remplacez ceci par la méthode pour obtenir le numéro de téléphone si disponible
      _emailController.text = user.email ?? '';
      _profileImageUrl = user.photoURL;
    }
  }

  Future<void> _updateProfile() async {
    User? user = _auth.currentUser;
    if (user != null) {
      try {
        // Mise à jour des informations utilisateur
        await user.updateProfile(
          displayName: _nameController.text,
          photoURL: _profileImageUrl,
        );
        await user.reload();
        // Mise à jour des informations supplémentaires dans Firestore
        await _firestore.collection('users').doc(user.uid).set({
          'name': _nameController.text,
          'phone': _phoneController.text,
          'email': _emailController.text,
          'photoURL': _profileImageUrl,
        });
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Profile updated successfully')),
        );
        Navigator.of(context).pop(); // Retour à la page précédente
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error updating profile: $e')),
        );
      }
    }
  }

  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedImage = await picker.getImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      File imageFile = File(pickedImage.path);
      setState(() {
        _profileImage = imageFile;
      });
      _uploadImage(imageFile);
    }
  }

  Future<void> _uploadImage(File imageFile) async {
    try {
      final storageRef = FirebaseStorage.instance
          .ref()
          .child('profile_images')
          .child('${_auth.currentUser?.uid}.jpg');
      final uploadTask = storageRef.putFile(imageFile);
      final snapshot = await uploadTask;
      final downloadUrl = await snapshot.ref.getDownloadURL();
      setState(() {
        _profileImageUrl = downloadUrl;
      });
      // Mettre à jour l'URL de la photo de profil dans Firestore
      await _firestore.collection('users').doc(_auth.currentUser?.uid).update({
        'photoURL': _profileImageUrl,
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error uploading image: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Profile'),
        actions: [
          IconButton(
            icon: Icon(Icons.save),
            onPressed: _updateProfile,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            GestureDetector(
              onTap: _pickImage,
              child: CircleAvatar(
                radius: 50,
                backgroundColor: Colors.grey[300],
                backgroundImage: _profileImage != null
                    ? FileImage(_profileImage!)
                    : NetworkImage(_profileImageUrl ?? '') as ImageProvider,
                child: _profileImage == null && _profileImageUrl == null
                    ? Icon(Icons.person, size: 50, color: Colors.grey[800])
                    : null,
              ),
            ),
            SizedBox(height: 20),
            TextField(
              controller: _nameController,
              decoration: InputDecoration(labelText: 'Name'),
            ),
            TextField(
              controller: _phoneController,
              decoration: InputDecoration(labelText: 'Phone'),
            ),
            TextField(
              controller: _emailController,
              decoration: InputDecoration(labelText: 'Email'),
              enabled: false, // Disable editing of the email field
            ),
          ],
        ),
      ),
    );
  }
}
