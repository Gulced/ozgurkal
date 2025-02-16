import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ozgurkal1/screens/risk_situations_screen.dart';
import 'package:ozgurkal1/screens/emergency_plan_screen.dart';
import 'package:ozgurkal1/screens/awareness_screen.dart';
import 'package:ozgurkal1/screens/anger_control_screen.dart';
import 'package:ozgurkal1/screens/gambling_proscons_screen.dart';
import 'package:ozgurkal1/screens/weekly_tracking_screen.dart';

class TreatmentProcessScreen extends StatefulWidget {
  @override
  _TreatmentProcessScreenState createState() => _TreatmentProcessScreenState();
}

class _TreatmentProcessScreenState extends State<TreatmentProcessScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String addictionType = "Genel"; // Varsayılan bağımlılık türü
  List<Map<String, dynamic>> addictionSpecificCards = [];
  bool isLoading = true;

  /// 📌 **Herkese Açık Kartlar**
  final List<Map<String, dynamic>> baseCards = [
    {"title": "Riskli Durumlar", "icon": Icons.warning_amber_rounded, "screen": RiskSituationsScreen()},
    {"title": "Acil Durum Planı", "icon": Icons.medical_services_rounded, "screen": EmergencyPlanScreen()},
    {"title": "Farkındalık", "icon": Icons.psychology, "screen": AwarenessScreen()},
    {"title": "Öfke Kontrol", "icon": Icons.emoji_emotions, "screen": AngerControlScreen()},
    {"title": "Haftalık Takip", "icon": Icons.calendar_today, "screen": WeeklyTrackingScreen()},
  ];

  /// 🔥 **Bağımlılık Türüne Özel Kartlar**
  final Map<String, List<Map<String, dynamic>>> addictionActivities = {
    "Kumar": [
      {"title": "Artı/Eksiler", "icon": Icons.balance, "screen": GamblingProsConsScreen()},
    ],
    "Madde": [],
    "Alkol": [],
    "Genel": [],
  };

  @override
  void initState() {
    super.initState();
    _loadUserAddictionType();
  }

  /// 📌 **Firestore'dan Kullanıcının Bağımlılık Türünü Al**
  Future<void> _loadUserAddictionType() async {
    final user = _auth.currentUser;
    if (user == null) {
      print("❌ Kullanıcı giriş yapmamış!");
      setState(() {
        isLoading = false;
      });
      return;
    }

    try {
      DocumentSnapshot userDoc = await _firestore.collection('users').doc(user.uid).get();
      if (userDoc.exists && userDoc.data() != null) {
        String? fetchedType = userDoc.get("addictionType");
        setState(() {
          addictionType = fetchedType ?? "Genel"; // Eğer veri yoksa varsayılan olarak "Genel" ata
          addictionSpecificCards = addictionActivities[addictionType] ?? [];
          isLoading = false;
        });
      } else {
        setState(() {
          addictionType = "Genel";
          addictionSpecificCards = [];
          isLoading = false;
        });
      }
    } catch (e) {
      print("⚠️ Firestore'dan veri çekme hatası: $e");
      setState(() {
        addictionSpecificCards = [];
        isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Map<String, dynamic>> allCards = [
      ...baseCards, // **Herkese açık olan kartlar**
      ...addictionSpecificCards, // **Bağımlılık türüne özel kartlar**
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Tedavi Süreci", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator()) // 🔄 Yükleniyor animasyonu
          : Padding(
        padding: const EdgeInsets.all(16.0),
        child: GridView.builder(
          gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // ✅ Her satırda 2 kart olacak
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 1.1, // ✅ Kart oranını belirledik
          ),
          itemCount: allCards.length,
          itemBuilder: (context, index) {
            return _buildCard(context, allCards[index]);
          },
        ),
      ),
    );
  }

  /// 📌 **Kartları Oluşturma Fonksiyonu**
  Widget _buildCard(BuildContext context, Map<String, dynamic> cardData) {
    return GestureDetector(
      onTap: () {
        if (cardData["screen"] != null) {
          Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => cardData["screen"]),
          );
        } else {
          print("🟠 '${cardData["title"]}' Kartına Basıldı, Ancak Sayfa Yok!");
        }
      },
      child: Card(
        elevation: 4,
        color: Colors.orange.shade50,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(cardData["icon"], color: Colors.orange, size: 40),
            const SizedBox(height: 10),
            Text(
              cardData["title"],
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ],
        ),
      ),
    );
  }
}
