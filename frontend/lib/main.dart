import 'package:flutter/material.dart';
import 'package:mungilpedia/halamanblog.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: "Miyo App",
      theme: ThemeData(primaryColor: Color.fromARGB(255, 255, 215, 236)),
      home: Halamanblog(),
      debugShowCheckedModeBanner: false,
    );
  }
}