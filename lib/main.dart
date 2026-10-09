import 'package:flutter/material.dart';
import 'login_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Vstock Cafe POS',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.espressoDark,
          primary: AppColors.espressoDark,
          secondary: AppColors.warmMocha,
          tertiary: AppColors.caramelCrema,
          surface: AppColors.latteCream,
        ),
        scaffoldBackgroundColor: AppColors.latteCream,
        useMaterial3: true,
      ),
      debugShowCheckedModeBanner: false,
      home: const LoginPage(),
    );
  }
}
