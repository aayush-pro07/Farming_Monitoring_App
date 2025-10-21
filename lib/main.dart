import 'dart:async';
//import 'dart:convert';
import 'package:flutter/material.dart';
//import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:lottie/lottie.dart';
import 'dart:io' show Platform;
import 'package:flutter/foundation.dart' show kIsWeb;

import 'authentication.dart';
import 'dashboard.dart';
//import 'weather.dart';
//import 'logs.dart';
//import 'appInfo.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final token = prefs.getString("token");
  runApp(SmartFarmApp(initialRoute: token == null ? '/login' : '/dashboard'));
}

// API URL selection at runtime
final String API_URL = (() {
  try {
    if (kIsWeb) return 'http://localhost:3000';
    if (Platform.isAndroid) return 'http://10.0.2.2:3000';
    if (Platform.isWindows || Platform.isLinux || Platform.isMacOS) return 'http://localhost:3000';
  } catch (e) {}
  return 'http://192.168.0.100:3000';
})();

// ================= WELCOME PAGE =================
class WelcomePage extends StatefulWidget {
  const WelcomePage({super.key});

  @override
  State<WelcomePage> createState() => _WelcomePageState();
}

class _WelcomePageState extends State<WelcomePage> with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3))..forward();

    Future.delayed(const Duration(seconds: 4), () {
      if (!mounted) return;
      Navigator.pushReplacementNamed(context, '/login');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          Container(
            decoration: const BoxDecoration(
              gradient: LinearGradient(
                colors: [Color(0xFF43cea2), Color(0xFF185a9d)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
            ),
          ),
          Positioned(
            bottom: 30,
            right: 20,
            child: Text(
              "SK",
              style: TextStyle(
                fontSize: 72,
                fontWeight: FontWeight.bold,
                color: Colors.white.withOpacity(0.08),
              ),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _controller,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Lottie.asset("assets/welcome.json", width: 220, height: 220),
                  const SizedBox(height: 20),
                  const Text(
                    "किसान App",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                      shadows: [Shadow(color: Colors.black45, blurRadius: 6, offset: Offset(2, 2))],
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text(
                    "Welcome to Smart Farming",
                    style: TextStyle(color: Colors.white70, fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}

// ================= MAIN APP =================
class SmartFarmApp extends StatelessWidget {
  final String initialRoute;
  const SmartFarmApp({super.key, required this.initialRoute});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Smart Farm App',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(primarySwatch: Colors.green, scaffoldBackgroundColor: Colors.grey.shade100),
      initialRoute: initialRoute,
      routes: {
        '/login': (context) => const LoginPage(),
        '/signup': (context) => const SignUpPage(),
        '/dashboard': (context) => const MainPage(),
      },
    );
  }
}
