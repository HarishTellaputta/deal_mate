import 'package:flutter/material.dart';

import 'core/app_theme.dart';
import 'pages/home_page.dart';

void main() {
  runApp(const DealMateApp());
}

class DealMateApp extends StatelessWidget {
  const DealMateApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'DealMate',
      theme: AppTheme.light,
      home: const HomePage(),
    );
  }
}