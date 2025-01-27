import 'package:flutter/material.dart';
import 'package:pp_viewer/profile_viewer_page.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: Theme.of(context),
      debugShowCheckedModeBanner: false,
      home: ProfileViewerPage(),
    );
  }
}
