import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'firebase_options.dart';
import 'screens/login_screen.dart';  // ✅ LoginScreen import edildi!
import 'screens/register_screen.dart';
import 'screens/create_profile_screen.dart';
import 'screens/home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Özgür Kal',
      theme: ThemeData(
        primarySwatch: Colors.orange,
      ),
      debugShowCheckedModeBanner: false,
      home: AuthCheck(), // ✅ SplashScreen yerine AuthCheck kullanıyoruz
    );
  }
}

/// 📌 Kullanıcının giriş yapıp yapmadığını kontrol eden ekran
class AuthCheck extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Scaffold(
            backgroundColor: Colors.orange,
            body: Center(child: CircularProgressIndicator()),
          ); // 🔄 Yükleniyor ekranı
        }
        if (snapshot.hasData) {
          return HomeScreen(); // ✅ Kullanıcı giriş yapmışsa HomeScreen'e gider
        } else {
          return LoginScreen(); // ✅ Kullanıcı giriş yapmamışsa LoginScreen açılır
        }
      },
    );
  }
}
