import 'package:flutter/material.dart';
import 'package:food_order/view/login/welcome_view.dart';

class StartupView extends StatefulWidget {
  const StartupView({Key? key}) : super(key: key);

  @override
  State<StartupView> createState() => _StartupViewState();
}

class _StartupViewState extends State<StartupView> {
  @override
  void initState() {
    super.initState();
    // Delay for 3 seconds before navigating to welcome page
    Future.delayed(const Duration(seconds: 3), () {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const WelcomeView()),
      );
    });
  }

  @override
  Widget build(BuildContext context) {
    var media = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(
        alignment: Alignment.center,
        children: [
          Image.asset(
            "assets/img/splash_bg.png",
            width: media.width,
            height: media.height,
            fit: BoxFit.cover,
          ),
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Image.asset(
                "assets/img/logo.jpeg", // Replace with your logo asset path
                width: media.width * 0.5, // Adjust size as needed
              ),
              SizedBox(height: 20),
              Text(
                "Food Order App",
                style: TextStyle(
                  fontSize: media.width * 0.1, // Adjust font size as needed
                  color: Color.fromARGB(255, 9, 9, 9),
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}
