import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

class WeeklyTrackingScreen extends StatefulWidget {
  @override
  _WeeklyTrackingScreenState createState() => _WeeklyTrackingScreenState();
}

class _WeeklyTrackingScreenState extends State<WeeklyTrackingScreen> {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  String selectedDay = "Pazartesi"; // Varsayılan gün

  Map<String, List<bool>> moodTracker = {};
  Map<String, List<bool>> selfCareChecklist = {};
  Map<String, TextEditingController> positiveAwarenessControllers = {};
  Map<String, TextEditingController> dailyNotesControllers = {};

  final List<String> days = [
    "Pazartesi", "Salı", "Çarşamba", "Perşembe", "Cuma", "Cumartesi", "Pazar"
  ];
  final List<String> moodOptions = [
    "Mutlu", "Yorgun", "Üzgün", "Stresli", "Endişeli", "Motiveli", "Sakin", "Güvensiz"
  ];
  final List<String> selfCareOptions = [
    "Egzersiz", "Sağlıklı Beslenme", "Temiz Hava", "Sosyal Etkileşim", "Uyku Düzeni", "Meditasyon", "Öz Bakım"
  ];

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _loadPreviousEntries();
  }

  void _initializeControllers() {
    for (var day in days) {
      moodTracker[day] = List.generate(moodOptions.length, (index) => false);
      selfCareChecklist[day] = List.generate(selfCareOptions.length, (index) => false);
      positiveAwarenessControllers[day] = TextEditingController();
      dailyNotesControllers[day] = TextEditingController();
    }
  }

  Future<void> _loadPreviousEntries() async {
    final user = _auth.currentUser;
    if (user != null) {
      DocumentSnapshot userDoc = await _firestore.collection('weeklyTracking').doc(user.uid).get();
      if (userDoc.exists) {
        Map<String, dynamic> data = userDoc.data() as Map<String, dynamic>? ?? {};
        for (var day in days) {
          if (data.containsKey(day)) {
            var values = data[day] as Map<String, dynamic>? ?? {};
            setState(() {
              moodTracker[day] = List<bool>.from(values["moodTracker"] ?? List.generate(moodOptions.length, (_) => false));
              selfCareChecklist[day] = List<bool>.from(values["selfCareChecklist"] ?? List.generate(selfCareOptions.length, (_) => false));
              positiveAwarenessControllers[day]?.text = values["positiveAwareness"] ?? "";
              dailyNotesControllers[day]?.text = values["dailyNotes"] ?? "";
            });
          }
        }
      }
    }
  }

  Future<void> _saveEntries() async {
    final user = _auth.currentUser;
    if (user != null) {
      Map<String, dynamic> entries = {};
      for (var day in days) {
        entries[day] = {
          "moodTracker": moodTracker[day] ?? List.generate(moodOptions.length, (_) => false),
          "selfCareChecklist": selfCareChecklist[day] ?? List.generate(selfCareOptions.length, (_) => false),
          "positiveAwareness": positiveAwarenessControllers[day]?.text ?? "",
          "dailyNotes": dailyNotesControllers[day]?.text ?? "",
        };
      }
      await _firestore.collection('weeklyTracking').doc(user.uid).set(entries);
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Haftalık takip kaydedildi!")));
    }
  }

  @override
  void dispose() {
    for (var controller in positiveAwarenessControllers.values) {
      controller.dispose();
    }
    for (var controller in dailyNotesControllers.values) {
      controller.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.orange,
        title: const Text("Haftalık Takip", style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            const Text(
              "Bugünkü Takip Günlüğünüzü Doldurun",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 10),
            DropdownButton<String>(
              value: selectedDay,
              onChanged: (value) {
                if (value != null) {
                  setState(() {
                    selectedDay = value;
                  });
                }
              },
              items: days.map((day) {
                return DropdownMenuItem<String>(
                  value: day,
                  child: Text(day, style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                );
              }).toList(),
            ),
            Expanded(
              child: SingleChildScrollView(
                child: Column(
                  children: [
                    _buildChecklist("Öz Bakım Tablosu", selfCareOptions, selfCareChecklist[selectedDay] ?? List.generate(selfCareOptions.length, (_) => false)),
                    const SizedBox(height: 20),
                    _buildChecklist("Günlük Duygu Durumu", moodOptions, moodTracker[selectedDay] ?? List.generate(moodOptions.length, (_) => false)),
                    const SizedBox(height: 20),
                    _buildTextField("Olumlu Farkındalık", positiveAwarenessControllers[selectedDay] ?? TextEditingController()),
                    _buildTextField("Bugünü nasıl geçirdiniz? Eklemek istedikleriniz", dailyNotesControllers[selectedDay] ?? TextEditingController()),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: _saveEntries,
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.orange,
                padding: const EdgeInsets.symmetric(vertical: 12.0, horizontal: 20),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.0)),
              ),
              child: const Text("Kaydet", style: TextStyle(color: Colors.white, fontSize: 16)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildChecklist(String title, List<String> options, List<bool> selections) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.orange.shade100,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
            Column(
              children: List.generate(options.length, (index) {
                return CheckboxListTile(
                  title: Text(options[index]),
                  value: selections[index],
                  onChanged: (value) {
                    setState(() {
                      selections[index] = value ?? false;
                    });
                  },
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildTextField(String title, TextEditingController controller) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 8.0),
      color: Colors.orange.shade100,
      child: Padding(
        padding: const EdgeInsets.all(10.0),
        child: TextField(
          controller: controller,
          maxLines: 4,
          decoration: InputDecoration(
            labelText: title,
            border: const OutlineInputBorder(),
            filled: true,
            fillColor: Colors.white,
          ),
        ),
      ),
    );
  }
}
