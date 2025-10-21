import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
//import 'package:lottie/lottie.dart';
import 'main.dart';

class PumpTab extends StatefulWidget {
  const PumpTab({super.key});
  @override
  _PumpTabState createState() => _PumpTabState();
}

class _PumpTabState extends State<PumpTab> {
  List<String> notifications = [];
  String? lastStatus;
  Timer? _timer;

  @override
  void initState() {
    super.initState();
    fetchPumpStatus(initialFetch: true);
    _timer = Timer.periodic(const Duration(seconds: 5), (timer) => fetchPumpStatus());
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }

  Future<void> fetchPumpStatus({bool initialFetch = false}) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final token = prefs.getString("token");

      final response = await http.get(Uri.parse('$API_URL/farmer/data'), headers: {"Content-Type": "application/json", "Authorization": "Bearer $token"});

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        final sensorData = Map<String, dynamic>.from(data['sensorData'] ?? {});
        final status = sensorData['Pump']?.toString() ?? "0";
        final currentStatus = (status == "1") ? "ON" : "OFF";

        if (lastStatus == null) {
          lastStatus = currentStatus;
        } else if (currentStatus != lastStatus) {
          setState(() {
            lastStatus = currentStatus;
            final timestamp = "${DateTime.now().hour.toString().padLeft(2,'0')}:${DateTime.now().minute.toString().padLeft(2,'0')}";
            notifications.insert(0, "[$timestamp] Pump turned $currentStatus");
          });
        }
      }
    } catch (e) {
      if (notifications.isEmpty) return;
      setState(() => notifications.insert(0, "[Error] Failed to fetch pump status"));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: notifications.isEmpty
          ? const Center(child: Text("No pump notifications yet", style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notif = notifications[index];
                final isOn = notif.toLowerCase().contains("on");
                final isError = notif.toLowerCase().contains("error");

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: isError ? Colors.red.shade50 : (isOn ? Colors.green.shade50 : Colors.grey.shade200),
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [BoxShadow(color: Colors.grey.withOpacity(0.2), blurRadius: 4, spreadRadius: 1)],
                  ),
                  child: Text(notif,
                      style: TextStyle(
                        fontSize: 16,
                        fontWeight: FontWeight.w500,
                        color: isError ? Colors.red : (isOn ? Colors.green : Colors.black87),
                      )),
                );
              },
            ),
    );
  }
}
