import 'package:flutter/material.dart';

class HelpSupportScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Destek & Yardım"),
        backgroundColor: Colors.orange,
      ),
      body: Center(
        child: Text(
          "Bağımlılıkla mücadele ederken size destek olabilecek kaynakları buradan görüntüleyebilirsiniz.",
          style: TextStyle(fontSize: 18),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }
}
