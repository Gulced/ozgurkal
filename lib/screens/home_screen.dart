import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../widgets/bottom_nav_bar.dart';
import 'activity_tracker_screen.dart';
import 'help_support_screen.dart';
import 'settings_screen.dart';
import 'login_screen.dart';

class HomeScreen extends StatefulWidget {
  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _selectedIndex = 0;
  final FirebaseAuth _auth = FirebaseAuth.instance;
  Map<String, dynamic>? _userData;
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _checkAuthState();
  }

  /// 🔥 Kullanıcının giriş yapıp yapmadığını kontrol eder.
  void _checkAuthState() {
    final user = _auth.currentUser;
    if (user == null) {
      _redirectToLogin();
    } else {
      _fetchUserData();
    }
  }

  /// 🔥 Firestore'dan kullanıcı verilerini çeker.
  Future<void> _fetchUserData() async {
    final user = _auth.currentUser;
    if (user == null) return _redirectToLogin();

    try {
      DocumentSnapshot userDoc = await FirebaseFirestore.instance
          .collection('profiles')
          .doc(user.uid)
          .get();

      if (userDoc.exists && mounted) {
        setState(() {
          _userData = userDoc.data() as Map<String, dynamic>?;
          _isLoading = false;
        });
      } else if (mounted) {
        setState(() {
          _errorMessage = "Kullanıcı verisi bulunamadı!";
          _isLoading = false;
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _errorMessage = "Veri alınırken hata oluştu: $e";
          _isLoading = false;
        });
      }
    }
  }

  /// 🔥 Kullanıcıyı LoginScreen'e yönlendirir.
  void _redirectToLogin() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => LoginScreen()),
      );
    });
  }

  /// 🔥 Kullanıcı çıkış yaptığında LoginScreen'e yönlendirir.
  void _logout() async {
    await _auth.signOut();
    _redirectToLogin();
  }

  /// 🔄 Navigasyon değiştirildiğinde güncellenen fonksiyon
  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Özgür Kal'),
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: _logout,
          )
        ],
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator()) // Yükleme ekranı
          : _errorMessage != null
          ? Center(child: Text(_errorMessage!, style: const TextStyle(color: Colors.red, fontSize: 16)))
          : _buildHomeScreen(), // Ana ekranı burada oluşturuyoruz
      bottomNavigationBar: BottomNavBar(
        currentIndex: _selectedIndex,
        onTap: _onItemTapped,
      ),
    );
  }

  /// 📌 Ana sayfa içeriği
  Widget _buildHomeScreen() {
    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "Bağımlılık Profiliniz",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _userData == null
              ? const Text("Kullanıcı verileri yükleniyor...")
              : Card(
            color: Colors.orange.shade100,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text("İsim: ${_userData?['name'] ?? 'Bilinmiyor'}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Bağımlılık Türü: ${_userData?['dependencyTypes']?.join(', ') ?? 'Belirtilmemiş'}",
                      style: const TextStyle(fontSize: 18)),
                  Text("Ayıklık Süresi: ${_userData?['sobrietyDays'] ?? 'Bilinmiyor'} gün",
                      style: const TextStyle(fontSize: 18)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 20),
          const Text(
            "Günlük Takip ve Aktivite Planı",
            style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 10),
          _buildActivityTracker(),
        ],
      ),
    );
  }

  /// 📌 Günlük takip ve aktivite planı bölümü
  Widget _buildActivityTracker() {
    return Column(
      children: [
        ListTile(
          leading: const Icon(Icons.fitness_center, color: Colors.orange),
          title: const Text("Günlük Egzersiz"),
          subtitle: const Text("Bugün için planlanan egzersizlerinizi yapın."),
          trailing: ElevatedButton(
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => ActivityTrackerScreen()));
            },
            child: const Text("Takip Et"),
          ),
        ),
        ListTile(
          leading: const Icon(Icons.check_circle, color: Colors.green),
          title: const Text("Günlük Hedefler"),
          subtitle: const Text("Bugün tamamlamanız gereken görevler."),
          trailing: ElevatedButton(
            onPressed: () {
              // Günlük görev takibi ekranına yönlendirme yapılabilir
            },
            child: const Text("Planla"),
          ),
        ),
      ],
    );
  }
}
