import 'package:flutter/material.dart';

class ActivityTrackerScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("Aktivite Takibi")),
      body: Center(
        child: Text("Burada günlük aktivitelerini takip edebilirsin!"),
      ),
    );
  }
}
