import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'treatment_process_screen.dart'; // Geri dönüş sayfası için import

class AwarenessScreen extends StatefulWidget {
  @override
  _AwarenessScreenState createState() => _AwarenessScreenState();
}

class _AwarenessScreenState extends State<AwarenessScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  final List<Map<String, dynamic>> questions = [
    {"question": "Bağımlılık, kişinin hangi durumunu ifade eder?", "options": ["Kontrollü kullanım", "Kontrolsüz kullanım"], "correctAnswer": "Kontrolsüz kullanım", "color": Colors.purple},
    {"question": "Bağımlılık tolerans gelişmesi ne anlama gelir?", "options": ["Aynı miktarda kullanım yeterli", "Daha fazla kullanma gereksinimi"], "correctAnswer": "Daha fazla kullanma gereksinimi", "color": Colors.orange},
    {"question": "Bağımlılık tamamen iyileşir mi?", "options": ["Bağımlılık tamamen iyileşir.", "Bağımlılık tamamen durdurulabilir."], "correctAnswer": "Bağımlılık tamamen durdurulabilir.", "color": Colors.blue},
    {"question": "Bağımlılıkla mücadelede hangisi daha faydalıdır?", "options": ["Tek başına çalışmak", "Profesyonel yardım almak"], "correctAnswer": "Profesyonel yardım almak", "color": Colors.red},
    {"question": "Bağımlılıkla başa çıkmada en etkili yöntem nedir?", "options": ["Destek gruplarına katılmak", "Bağımlılığı gizlemek"], "correctAnswer": "Destek gruplarına katılmak", "color": Colors.green},
  ];

  Map<int, String?> selectedAnswers = {};

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Bağımlılık Farkındalığı"),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () {
            Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => TreatmentProcessScreen()));
          },
        ),
      ),
      body: Column(
        children: [
          // 📌 Yönerge Metni
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Text(
              "Lütfen aşağıdaki soruları yanıtlayın ve 'Cevapları Kaydet' butonuna basarak ilerleyin.",
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
          ),

          // 📌 Sorular (Scroll içinde)
          Expanded(
            child: SingleChildScrollView(
              child: Column(
                children: List.generate(questions.length, (index) => _buildQuestionCard(index)),
              ),
            ),
          ),

          // 📌 Cevapları Kaydet Butonu
          Container(
            width: double.infinity,
            margin: const EdgeInsets.all(16),
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
    );
  }

  Widget _buildQuestionCard(int index) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
      elevation: 4,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Text(
              questions[index]["question"],
              style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 12),
            Column(
              children: List.generate(questions[index]["options"].length, (optionIndex) {
                String optionText = questions[index]["options"][optionIndex];
                bool isSelected = selectedAnswers[index] == optionText;

                return Container(
                  margin: const EdgeInsets.symmetric(vertical: 4),
                  width: double.infinity,
                  height: 50, // 📌 Buton Boyutu Eşitlendi
                  child: ElevatedButton(
                    onPressed: () {
                      setState(() {
                        selectedAnswers[index] = optionText;
                      });

                      _showAnswerDialog(
                        isCorrect: optionText == questions[index]["correctAnswer"],
                        correctAnswer: questions[index]["correctAnswer"],
                        color: questions[index]["color"],
                      );
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: isSelected ? questions[index]["color"] : Colors.white,
                      foregroundColor: isSelected ? Colors.white : Colors.black,
                    ),
                    child: Text(optionText, textAlign: TextAlign.center),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  void _showAnswerDialog({required bool isCorrect, required String correctAnswer, required Color color}) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(isCorrect ? "Doğru Cevap!" : "Yanlış Cevap!"),
          content: Text(isCorrect ? "Tebrikler, doğru cevap verdiniz!" : "Doğru cevap: $correctAnswer"),
          backgroundColor: color.withOpacity(0.9),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text("Tamam", style: TextStyle(color: Colors.white)),
            ),
          ],
        );
      },
    );
  }

  Future<void> _saveAnswers() async {
    final user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic> answersToSave = {};
      selectedAnswers.forEach((key, value) {
        if (value != null) {
          answersToSave[key.toString()] = value;
        }
      });

      await _firestore.collection('awarenessResponses').doc(user.uid).set(answersToSave);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Cevaplar kaydedildi!")));
    }
  }
}
