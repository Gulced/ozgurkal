import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class GamblingProsConsScreen extends StatefulWidget {
  @override
  _GamblingProsConsScreenState createState() => _GamblingProsConsScreenState();
}

class _GamblingProsConsScreenState extends State<GamblingProsConsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final TextEditingController _prosController = TextEditingController();
  final TextEditingController _consController = TextEditingController();
  final TextEditingController _lossesController = TextEditingController();
  final TextEditingController _gainsController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadPreviousEntries();
  }

  /// 📌 Firebase'den daha önce kaydedilen verileri yükleme
  Future<void> _loadPreviousEntries() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot doc = await _firestore.collection('gamblingProsCons').doc(user.uid).get();
      if (doc.exists) {
        setState(() {
          _prosController.text = doc.get("pros") ?? "";
          _consController.text = doc.get("cons") ?? "";
          _lossesController.text = doc.get("losses") ?? "";
          _gainsController.text = doc.get("gains") ?? "";
        });
      }
    }
  }

  /// 📌 Firebase'e verileri kaydetme
  Future<void> _saveEntries() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('gamblingProsCons').doc(user.uid).set({
        "pros": _prosController.text,
        "cons": _consController.text,
        "losses": _lossesController.text,
        "gains": _gainsController.text,
      });

      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cevaplar kaydedildi!")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Yararlar ve Yitireceklerim"),
        backgroundColor: Colors.orange,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Kumarın hayatınıza etkilerini değerlendirin ve düşüncelerinizi kaydedin.",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),

            /// 📌 4 Kutu İçin Grid Yapısı
            Expanded(
              child: GridView.count(
                crossAxisCount: 2,
                crossAxisSpacing: 10,
                mainAxisSpacing: 10,
                childAspectRatio: 1.2, // Kutu oranı ayarlandı
                children: [
                  _buildInputBox("Kumar oynamanın bana getirdiği yararlar", _prosController),
                  _buildInputBox("Kumar oynamazsam yitireceklerim", _lossesController),
                  _buildInputBox("Kumar oynamanın bugünkü olumsuz sonuçları ve gelecekte ortaya çıkabilecek olası sorunlar", _consController),
                  _buildInputBox("Kumar oynamayı bırakırsam kazanacaklarım", _gainsController),
                ],
              ),
            ),

            /// 📌 Kaydet Butonu
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _saveEntries,
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  backgroundColor: Colors.orange,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                ),
                child: const Text("Cevapları Kaydet", style: TextStyle(color: Colors.white, fontSize: 16)),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Giriş Kutularını Oluşturan Fonksiyon
  Widget _buildInputBox(String title, TextEditingController controller) {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: TextField(
                controller: controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(
                  border: OutlineInputBorder(),
                  hintText: "Buraya yazın...",
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
