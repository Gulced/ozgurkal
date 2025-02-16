import 'package:flutter/material.dart';
import '../screens/treatment_process_screen.dart'; // ✅ Tedavi süreci ekranını import ettik.

class BottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTap;

  const BottomNavBar({required this.currentIndex, required this.onTap, Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return BottomNavigationBar(
      currentIndex: currentIndex,
      onTap: (index) {
        if (index == 1) { // 📌 Eğer "Tedavi" butonuna basılırsa yeni sayfa açılır.
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => TreatmentProcessScreen()),
          );
        } else {
          onTap(index); // Diğer butonlara basıldığında sadece _selectedIndex güncelleniyor.
        }
      },
      backgroundColor: Colors.orange, // 🎨 TURUNCU RENK
      selectedItemColor: Colors.white, // SEÇİLİ ÖĞELER BEYAZ
      unselectedItemColor: Colors.white70, // SEÇİLMEYENLER AÇIK GRİ
      showSelectedLabels: true,
      showUnselectedLabels: true,
      type: BottomNavigationBarType.fixed, // Düzgün görünüm için
      items: const [
        BottomNavigationBarItem(
          icon: Icon(Icons.home),
          label: "Ana Sayfa",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.local_hospital),
          label: "Tedavi",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.support_agent),
          label: "Destek",
        ),
        BottomNavigationBarItem(
          icon: Icon(Icons.settings),
          label: "Ayarlar",
        ),
      ],
    );
  }
}
