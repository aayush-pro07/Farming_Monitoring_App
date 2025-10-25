import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'main.dart';
import 'weather.dart';
import 'logs.dart';
import 'appInfo.dart';

class MainPage extends StatefulWidget {
  const MainPage({super.key});
  @override
  _MainPageState createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  int selectedIndex = 0;

  final List<Widget> pages = [
    const DashboardTab(),
    const WeatherTab(),
    const PumpTab(),
    const FarmInfoPage(),
  ];

  void onTabTapped(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  void logout() async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.clear();
    Navigator.pushReplacementNamed(context, '/login');
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Smart Farm App"),
        backgroundColor: Colors.green,
        actions: [IconButton(onPressed: logout, icon: const Icon(Icons.logout))],
      ),
      body: pages[selectedIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: selectedIndex,
        selectedItemColor: Colors.green,
        unselectedItemColor: Colors.grey,
        showUnselectedLabels: true,
        onTap: onTabTapped,
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.dashboard), label: "Dashboard"),
          BottomNavigationBarItem(icon: Icon(Icons.cloud), label: "Weather"),
          BottomNavigationBarItem(icon: Icon(Icons.water), label: "Pump"),
          BottomNavigationBarItem(icon: Icon(Icons.info), label: "Info"),
        ],
      ),
    );
  }
}

class DashboardTab extends StatefulWidget {
  const DashboardTab({super.key});
  @override
  _DashboardTabState createState() => _DashboardTabState();
}

class _DashboardTabState extends State<DashboardTab> {
  bool isLoading = true;
  Map<String, dynamic> sensorData = {};
  String thingspeakChannel = "";
  String thingspeakApiKey = "";

  final Map<String, Map<String, String>> fieldValueMap = {
    "Rain": {"1": "Detected", "0": "Not Detected"},
    "Rain Status": {"1": "Detected", "0": "Not Detected"},
    "Pump": {"1": "On", "0": "Off"},
    "Pump Status": {"1": "On", "0": "Off"},
    "Soil": {"1": "Dry", "0": "Wet"},
    "Soil Status": {"1": "Dry", "0": "Wet"},
    "Water Level": {"1": "High", "0": "Low"},
  };

  Future<void> fetchFarmerData() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");
      thingspeakChannel = prefs.getString("thingspeakChannel") ?? "";
      thingspeakApiKey = prefs.getString("thingspeakApiKey") ?? "";

      final response = await http.get(
        Uri.parse('$API_URL/farmer/data'),
        headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"},
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          sensorData = Map<String, dynamic>.from(data['sensorData'] ?? {});
          isLoading = false;
        });
      } else {
        throw Exception("Failed to load data");
      }
    } catch (e) {
      setState(() => isLoading = false);
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text("Error: $e")));
    }
  }

  @override
  void initState() {
    super.initState();
    fetchFarmerData();
  }

  @override
  Widget build(BuildContext context) {
    if (isLoading) return Center(child: Lottie.asset("assets/loading.json", width: 120));
    if (sensorData.isEmpty) return const Center(child: Text("No sensor data available", style: TextStyle(fontSize: 16)));

    final filteredKeys = sensorData.keys.where((k) => sensorData[k] != null).toList();

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        mainAxisSpacing: 16,
        crossAxisSpacing: 16,
        childAspectRatio: 1,
      ),
      itemCount: filteredKeys.length,
      itemBuilder: (context, index) {
        final key = filteredKeys[index];
        final rawValue = sensorData[key]?.toString();
        String displayValue = rawValue ?? "Error";

        fieldValueMap.forEach((field, mapping) {
          if (key.toLowerCase().contains(field.toLowerCase())) displayValue = mapping[rawValue] ?? "Error";
        });

        final isPositive = displayValue.contains("On") || displayValue.contains("High") || displayValue.contains("Detected") || displayValue.contains("Dry");

        return Container(
          decoration: BoxDecoration(
            color: Colors.green.shade50,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.3), blurRadius: 5, spreadRadius: 2)],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(key, textAlign: TextAlign.center, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 8),
                  Text(displayValue,
                      textAlign: TextAlign.center,
                      style: TextStyle(color: isPositive ? Colors.green : Colors.red, fontSize: 18, fontWeight: FontWeight.w600)),
                  if (displayValue == "Error") const SizedBox(height: 6),
                  if (displayValue == "Error")
                    const Text("Value not available", style: TextStyle(fontSize: 12, color: Colors.grey), textAlign: TextAlign.center),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
