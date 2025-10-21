import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'main.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  bool isLoading = false;

  Future<void> login() async {
    if (emailController.text.isEmpty || passwordController.text.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Please fill all fields")));
      return;
    }

    setState(() => isLoading = true);

    try {
      final response = await http.post(
        Uri.parse('$API_URL/login'),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": emailController.text.contains("@") ? "" : emailController.text,
          "email": emailController.text.contains("@") ? emailController.text : "",
          "password": passwordController.text,
        }),
      );

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final prefs = await SharedPreferences.getInstance();
        await prefs.setString("token", data['token']);
        await prefs.setString("farmerName", data['farmer']['name']);
        await prefs.setString("thingspeakChannel", data['farmer']['thingspeakChannel']);
        await prefs.setString("thingspeakApiKey", data['farmer']['thingspeakApiKey']);

        if (!mounted) return;
        Navigator.pushReplacementNamed(context, '/dashboard');
      } else {
        final error = jsonDecode(response.body)['error'] ?? "Login failed";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.agriculture, size: 100, color: Colors.green),
              const SizedBox(height: 24),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email or Username")),
              const SizedBox(height: 12),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
              const SizedBox(height: 24),
              isLoading
                  ? Lottie.asset("assets/loading.json", width: 120, height: 120)
                  : ElevatedButton(onPressed: login, child: const Text("Login")),
              const SizedBox(height: 12),
              TextButton(
                onPressed: () => Navigator.pushNamed(context, '/signup'),
                child: const Text("Don't have an account? Sign Up"),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class SignUpPage extends StatefulWidget {
  const SignUpPage({super.key});
  @override
  _SignUpPageState createState() => _SignUpPageState();
}

class _SignUpPageState extends State<SignUpPage> {
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final usernameController = TextEditingController();
  final thingspeakChannelController = TextEditingController();
  final thingspeakApiKeyController = TextEditingController();
  bool isLoading = false;

  Future<void> signUp() async {
    if (nameController.text.isEmpty || emailController.text.isEmpty || passwordController.text.isEmpty) return;

    setState(() => isLoading = true);

    try {
      final response = await http.post(Uri.parse('$API_URL/signup'),
          headers: {"Content-Type": "application/json"},
          body: jsonEncode({
            "username": usernameController.text,
            "name": nameController.text,
            "email": emailController.text,
            "password": passwordController.text,
            "thingspeakChannel": thingspeakChannelController.text,
            "thingspeakApiKey": thingspeakApiKeyController.text,
          }));

      setState(() => isLoading = false);

      if (response.statusCode == 200) {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Signup successful! Login now")));
        Navigator.pushReplacementNamed(context, '/login');
      } else {
        final error = jsonDecode(response.body)['error'] ?? "Sign Up failed";
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(error)));
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Sign Up"), backgroundColor: Colors.green),
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              TextField(controller: nameController, decoration: const InputDecoration(labelText: "Name")),
              const SizedBox(height: 12),
              TextField(controller: usernameController, decoration: const InputDecoration(labelText: "Username")),
              const SizedBox(height: 12),
              TextField(controller: emailController, decoration: const InputDecoration(labelText: "Email")),
              const SizedBox(height: 12),
              TextField(controller: thingspeakChannelController, decoration: const InputDecoration(labelText: "ThingSpeak Channel ID")),
              const SizedBox(height: 12),
              TextField(controller: thingspeakApiKeyController, decoration: const InputDecoration(labelText: "ThingSpeak API Key")),
              const SizedBox(height: 12),
              TextField(controller: passwordController, obscureText: true, decoration: const InputDecoration(labelText: "Password")),
              const SizedBox(height: 24),
              isLoading
                  ? Lottie.asset("assets/loading.json", width: 120, height: 120)
                  : ElevatedButton(onPressed: signUp, child: const Text("Sign Up")),
            ],
          ),
        ),
      ),
    );
  }
}
