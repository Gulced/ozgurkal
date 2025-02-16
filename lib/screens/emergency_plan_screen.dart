import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class EmergencyPlanScreen extends StatefulWidget {
  @override
  _EmergencyPlanScreenState createState() => _EmergencyPlanScreenState();
}

class _EmergencyPlanScreenState extends State<EmergencyPlanScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final List<TextEditingController> emergencyPlanControllers = List.generate(3, (_) => TextEditingController());

  /// 📌 Kullanıcının girdiği acil planı Firestore’a kaydeder
  Future<void> _saveEmergencyPlan() async {
    final user = _auth.currentUser;
    if (user != null) {
      await FirebaseFirestore.instance.collection('profiles').doc(user.uid).set({
        'emergencyPlan': emergencyPlanControllers.map((controller) => controller.text).toList(),
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
        title: const Text("Acil Durum Planı", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ListView(
          children: [
            const Text(
              "ACİL DURUMLAR\nÇalışma 1",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            const Text(
              "Acil Planım Formu",
              textAlign: TextAlign.center,
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            const Text(
              "Şiddetli istek geldiği zaman için acil planım:",
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            _buildEmergencyPlanForm(),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEmergencyPlan,
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

  /// 📌 Kullanıcının acil durum planlarını yazması için giriş kutuları
  Widget _buildEmergencyPlanForm() {
    return Column(
      children: List.generate(3, (index) {
        return Padding(
          padding: const EdgeInsets.symmetric(vertical: 8.0),
          child: TextField(
            controller: emergencyPlanControllers[index],
            decoration: InputDecoration(
              labelText: "Acil plan ${index + 1}",
              border: OutlineInputBorder(),
            ),
          ),
        );
      }),
    );
  }
}
