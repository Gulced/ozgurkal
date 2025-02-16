import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class RiskSituationsScreen extends StatefulWidget {
  @override
  _RiskSituationsScreenState createState() => _RiskSituationsScreenState();
}

class _RiskSituationsScreenState extends State<RiskSituationsScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> riskliDurumControllers = List.generate(3, (_) => TextEditingController());
  Map<String, bool> oneriSecimleri = {};

  final List<String> degisiklikOnerileri = [
    "Hafta sonunda 3 günlüğüne şehir dışına çıkmak",
    "İstirahat günlerinde izin almak",
    "Konsere gitmek",
    "Spor yapmak",
    "Akrabaları ziyaret etmek",
    "Yemek için dışarıya çıkmak",
    "Eski bir dostu ziyaret etmek",
    "Sevgilinle/eşinle özel bir gün planlamak",
    "Küçük değişiklikler yapmak (Farklı bir yere gitmek, farklı bir yoldan yürümek)",
    "Yeni hobiler, eğlenceler bulmak"
  ];

  final List<String> aktiviteOnerileri = [
    "Yürümek",
    "Ders/Kurs almak",
    "Sinemaya gitmek",
    "Okumak",
    "Yazı yazmak",
    "Meditasyon/yoga öğrenmek",
    "Bisiklete binmek",
    "TV izlemek",
    "Müzik dinlemek",
    "Resim/çizim yapmak",
    "Balık tutmak",
    "Hayvanlarla oynamak",
    "Spor yapmak",
    "Alışveriş yapmak",
    "İbadet etmek",
    "Yemek yapmak",
    "Müzik aleti çalmak",
    "Konuşmadığınız arkadaşlarınızla konuşmak",
    "Görüşmediğiniz akrabalarınızla görüşmek"
  ];

  /// 📌 Kullanıcının girdiği verileri Firestore’a kaydeder
  Future<void> _saveRiskliDurumlar() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set({
        'enRiskliDurumlar': riskliDurumControllers.map((controller) => controller.text).toList(),
        'oneriSecimleri': oneriSecimleri,
      }, SetOptions(merge: true));
    }
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Riskli Durumlar Listesi", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              " RİSKLİ DURUMLAR LİSTESİ",
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Sizin için en riskli üç durumu yazar mısınız?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildRiskSecimFormu(),
            const SizedBox(height: 20),
            const Text(
              "Yazdıklarınızla başa çıkmak için aktivite önerilerinden size uygun olanları işaretler misiniz?",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildOneriListesi(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveRiskliDurumlar,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text("Kaydet ve Geri Dön", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  /// 📌 Kullanıcının en riskli 3 durumunu yazması için giriş kutuları
  Widget _buildRiskSecimFormu() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: riskliDurumControllers[index],
            decoration: InputDecoration(
              labelText: "Riskli durum ${index + 1}",
              border: OutlineInputBorder(),
            ),
          ),
        );
      }),
    );
  }

  /// 📌 Kullanıcıya başa çıkma yöntemleri sunar
  Widget _buildOneriListesi() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        ...degisiklikOnerileri.map((oneri) {
          return CheckboxListTile(
            title: Text(oneri),
            value: oneriSecimleri[oneri] ?? false,
            onChanged: (bool? newValue) {
              setState(() {
                oneriSecimleri[oneri] = newValue ?? false;
              });
            },
          );
        }),
        const SizedBox(height: 10),
        const Text(
          "Aktivite Önerileri",
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
        ...aktiviteOnerileri.map((oneri) {
          return CheckboxListTile(
            title: Text(oneri),
            value: oneriSecimleri[oneri] ?? false,
            onChanged: (bool? newValue) {
              setState(() {
                oneriSecimleri[oneri] = newValue ?? false;
              });
            },
          );
        }),
      ],
    );
  }
}
