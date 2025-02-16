import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AngerControlScreen extends StatefulWidget {
  @override
  _AngerControlScreenState createState() => _AngerControlScreenState();
}

class _AngerControlScreenState extends State<AngerControlScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final TextEditingController _otherPositiveController = TextEditingController();
  final TextEditingController _otherNegativeController = TextEditingController();

  // ✅ Olumlu baş etme yolları
  final List<String> positiveWays = [
    "Farkında nefes almak",
    "Ortamdan uzaklaşmak",
    "Başkalarıyla konuşmak",
    "Müzik dinlemek",
    "Dikkatini başka bir olaya-konuyla yöneltmek",
    "Duş almak",
    "Değiştiremeyeceğim şeyleri kabullenmek",
    "Fiziksel egzersiz yapmak (koşu, yürüyüş, futbol, jimnastik)",
    "Diğer (kendi örneğinizi yazınız)"
  ];

  // ✅ Olumsuz baş etme yolları
  final List<String> negativeWays = [
    "Küfretmek",
    "Kendisi veya bir başkasına zarar vermek",
    "Karşısındakini tehdit etmek",
    "Uyuşturucu ve alkol kullanmak",
    "Eşyaları kırmak",
    "Arkasından konuşmak",
    "Dövmek",
    "Ağlamak",
    "Diğer (kendi örneğinizi yazınız)"
  ];

  Map<String, String?> selectedAnswers = {}; // Kullanıcının seçimlerini tutar

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Öfkeyle Baş Etme Yolları"),
        backgroundColor: Colors.orange,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              // ✅ Yönerge
              const Text(
                "Aşağıdaki listeden öfkeyle baş etme yollarınızı seçin ve kaydedin.",
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 20),

              // ✅ Olumlu Yöntemler
              _buildCategorySection("Olumlu", positiveWays, isPositive: true),

              const SizedBox(height: 20),

              // ✅ Olumsuz Yöntemler
              _buildCategorySection("Olumsuz", negativeWays, isPositive: false),

              const SizedBox(height: 20),

              // ✅ Cevapları Kaydet Butonu
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _saveAnswers,
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
      ),
    );
  }

  /// 📌 Olumlu ve Olumsuz kategorileri için listeyi oluşturan fonksiyon
  Widget _buildCategorySection(String title, List<String> options, {required bool isPositive}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ✅ Başlık
        Text(
          title,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: isPositive ? Colors.green : Colors.red,
          ),
        ),
        const SizedBox(height: 10),

        // ✅ Seçenekler Listesi
        Column(
          children: List.generate(options.length, (index) {
            String option = options[index];
            bool isSelected = selectedAnswers[option] != null;

            return Column(
              children: [
                Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        if (option.contains("Diğer")) {
                          selectedAnswers[option] = isPositive ? _otherPositiveController.text : _otherNegativeController.text;
                        } else {
                          selectedAnswers[option] = option;
                        }
                      });
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? (isPositive ? Colors.green : Colors.red) : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(option, textAlign: TextAlign.center),
                  ),
                ),
                if (option.contains("Diğer") && isSelected)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8.0),
                    child: TextField(
                      controller: isPositive ? _otherPositiveController : _otherNegativeController,
                      decoration: const InputDecoration(
                        hintText: "",
                        border: OutlineInputBorder(),
                      ),
                      onChanged: (value) {
                        setState(() {
                          selectedAnswers[option] = value;
                        });
                      },
                    ),
                  ),
              ],
            );
          }),
        ),
      ],
    );
  }

  /// 📌 Firebase'e verileri kaydetme fonksiyonu
  Future<void> _saveAnswers() async {
    final user = _auth.currentUser;
    if (user != null) {
      await _firestore.collection('angerControlResponses').doc(user.uid).set(selectedAnswers);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cevaplar kaydedildi!")));
    }
  }
}
