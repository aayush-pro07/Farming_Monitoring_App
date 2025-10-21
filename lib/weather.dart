import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});
  @override
  _WeatherTabState createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  String city = "Mumbai";
  String description = "";
  double temperature = 0.0;
  int humidity = 0;
  double windSpeed = 0.0;
  bool isLoading = true;

  Future<void> fetchWeather() async {
    const apiKey = "3cecb5438d5010571d3ffc5941a09b51";
    final url = Uri.parse("https://api.openweathermap.org/data/2.5/weather?q=$city&appid=$apiKey&units=metric");

    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        setState(() {
          description = data["weather"][0]["description"];
          temperature = data["main"]["temp"].toDouble();
          humidity = data["main"]["humidity"].toInt();
          windSpeed = data["wind"]["speed"].toDouble();
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      setState(() => isLoading = false);
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: Lottie.asset("assets/loading.json", width: 150))
        : Padding(
            padding: const EdgeInsets.all(16),
            child: Column(
              children: [
                Text("Weather in $city",
                    style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.green)),
                const SizedBox(height: 20),
                Card(
                  elevation: 6,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Text("$temperature°C", style: const TextStyle(fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 8),
                        Text(description, style: const TextStyle(fontSize: 18)),
                        const SizedBox(height: 16),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            Column(children: [const Icon(Icons.water_drop, color: Colors.blue, size: 28), Text("$humidity% Humidity")]),
                            Column(children: [const Icon(Icons.air, color: Colors.indigo, size: 28), Text("$windSpeed m/s Wind")]),
                          ],
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
