import 'package:flutter/material.dart';

class GifShower extends StatelessWidget {
  const GifShower({super.key});

  @override
  Widget build(BuildContext context) {
    String text = "Привіт, Пака, Hello, Hola, Bonjour!";
    RegExp regex = RegExp(r'\bПака\b', caseSensitive: false, unicode: true);

  bool containsWordPaka = regex.hasMatch(text.toLowerCase());
  print(containsWordPaka);
    return Center(
      child: Text("борщ з"),
    );
  }
}
