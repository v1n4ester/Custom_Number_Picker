import 'package:custom_weight_picker/widget/custom_widget.dart';
import 'package:custom_weight_picker/widget/page_view_picker.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: Scaffold(
        backgroundColor: Colors.blue.shade900,
        body: SafeArea(
          child: PageViewPicker(width: MediaQuery.of(context).size.width)
        ),
      ),
    );
  }
}
