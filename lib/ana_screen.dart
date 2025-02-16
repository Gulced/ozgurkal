import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'login_screen.dart'; // Kullanıcı çıkış yaparsa buraya yönlendireceğiz.

class AnaEkran extends StatefulWidget {
  @override
  _AnaEkranState createState() => _AnaEkranState();
}

class _AnaEkranState extends State<AnaEkran> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;

  @override
  void initState() {
    super.initState();
    _loadUserProfile();
  }

  Future<void> _loadUserProfile() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userProfile =
      await FirebaseFirestore.instance.collection('profiles').doc(user.uid).get();

      if (userProfile.exists) {
        setState(() {
          _userData = userProfile.data() as Map<String, dynamic>;
        });
      }
    }
  }

  void _logout() async {
    await _auth.signOut();
    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (context) => LoginScreen()), // Çıkış yapınca Login'e yönlendir
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Ana Ekran"),
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: _logout, // Kullanıcı çıkış yaparsa
          ),
        ],
      ),
      body: Center(
        child: _userData == null
            ? CircularProgressIndicator() // Veriler yüklenene kadar bekletme animasyonu
            : Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text("Hoş geldin, ${_userData!['name']}!", style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold)),
            SizedBox(height: 10),
            Text("Yaş: ${_userData!['age']}", style: TextStyle(fontSize: 18)),
            Text("Cinsiyet: ${_userData!['gender']}", style: TextStyle(fontSize: 18)),
            Text("Kimle yaşıyor?: ${_userData!['livingWith']}", style: TextStyle(fontSize: 18)),
            Text("Çalışma durumu: ${_userData!['workStatus']}", style: TextStyle(fontSize: 18)),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: _logout,
              child: Text("Çıkış Yap"),
            ),
          ],
        ),
      ),
    );
  }
}
