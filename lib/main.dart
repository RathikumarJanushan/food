import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:food_order/view/login/welcome_view.dart';
import 'package:food_order/view/on_boarding/startup_view.dart';
import 'package:food_order/view/home/home_view.dart';
import 'package:food_order/view/login/login_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(); // Initialize Firebase
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Food Delivery',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        fontFamily: "Metropolis",
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      initialRoute: '/',
      routes: {
        '/': (context) => const StartupView(),
        '/home': (context) => const HomeView(),
        '/login': (context) => const WelcomeView(),
        // Define other routes here
      },
    );
  }
}
