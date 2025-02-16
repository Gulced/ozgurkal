import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'home_screen.dart';
import 'forgot_password_screen.dart'; // Şifre sıfırlama ekranı
import 'package:ozgurkal1/screens/forgot_password_screen.dart';


class LoginScreen extends StatefulWidget {
  @override
  _LoginScreenState createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  bool _isLoading = false;

  /// 🔥 Kullanıcı giriş yapma fonksiyonu
  Future<void> _login() async {
    if (_emailController.text.isEmpty || !_emailController.text.contains('@')) {
      _showSnackBar("Geçerli bir e-posta girin");
      return;
    }

    if (_passwordController.text.isEmpty || _passwordController.text.length < 6) {
      _showSnackBar("Şifre en az 6 karakter olmalıdır");
      return;
    }

    setState(() {
      _isLoading = true;
    });

    try {
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: _emailController.text.trim(),
        password: _passwordController.text.trim(),
      );

      _showSnackBar("Giriş başarılı!");

      /// ✅ Kullanıcı giriş yaptıktan sonra HomeScreen'e yönlendiriyoruz.
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (context) => HomeScreen()),
      );
    } catch (e) {
      _showSnackBar("Giriş başarısız: ${e.toString()}");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  /// 📌 Kullanıcıyı "Şifremi Unuttum" sayfasına yönlendirir
  void _navigateToForgotPasswordScreen() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => ForgotPasswordScreen()),
    );
  }

  /// 📌 Kullanıcıya bildirim gösterir
  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF001F3F),
      appBar: AppBar(
        backgroundColor: const Color(0xFF001F3F),
        elevation: 0,
        title: const Text('Giriş Yap', style: TextStyle(color: Colors.white)),
        centerTitle: true,
      ),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              _buildTextField("E-posta", _emailController, keyboardType: TextInputType.emailAddress),
              _buildTextField("Şifre", _passwordController, isPassword: true),
              const SizedBox(height: 10.0),
              TextButton(
                onPressed: _navigateToForgotPasswordScreen,
                child: const Text(
                  "Şifrenizi mi unuttunuz?",
                  style: TextStyle(color: Colors.white70, decoration: TextDecoration.underline),
                ),
              ),
              const SizedBox(height: 20.0),
              _isLoading
                  ? const CircularProgressIndicator()
                  : ElevatedButton(
                onPressed: _login,
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFFFA500),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8.0),
                  ),
                  padding: const EdgeInsets.symmetric(vertical: 16.0, horizontal: 50),
                ),
                child: const Text("Giriş Yap", style: TextStyle(color: Colors.white, fontSize: 16.0)),
              ),
            ],
          ),
        ),
      ),
    );
  }

  /// 📌 Ortak TextField bileşeni
  Widget _buildTextField(String label, TextEditingController controller, {bool isPassword = false, TextInputType? keyboardType}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 16.0),
      child: TextField(
        controller: controller,
        obscureText: isPassword,
        keyboardType: keyboardType ?? TextInputType.text,
        decoration: InputDecoration(
          labelText: label,
          labelStyle: const TextStyle(color: Colors.white70),
          filled: true,
          fillColor: const Color(0xFF002F5F),
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(8.0),
            borderSide: BorderSide.none,
          ),
        ),
        style: const TextStyle(color: Colors.white),
      ),
    );
  }
}
