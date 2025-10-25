import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:lottie/lottie.dart';
import 'package:geolocator/geolocator.dart';

class WeatherTab extends StatefulWidget {
  const WeatherTab({super.key});
  @override
  _WeatherTabState createState() => _WeatherTabState();
}

class _WeatherTabState extends State<WeatherTab> {
  bool isLoading = true;
  String city = "";
  double temperature = 0.0;
  String description = "";
  List<dynamic> forecast = [];

  final String apiKey = "3cecb5438d5010571d3ffc5941a09b51";

  @override
  void initState() {
    super.initState();
    fetchWeather();
  }

  Future<void> fetchWeather() async {
    try {
      // Ask for permission if not granted
      await Geolocator.requestPermission();

      // Get user location
      Position position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);
      double lat = position.latitude;
      double lon = position.longitude;

      // Fetch 3-day forecast from OpenWeatherMap
      final url = Uri.parse(
          "https://api.openweathermap.org/data/2.5/forecast?lat=$lat&lon=$lon&appid=$apiKey&units=metric");

      final response = await http.get(url);
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);

        setState(() {
          city = data["city"]["name"];
          final current = data["list"][0];
          temperature = current["main"]["temp"].toDouble();
          description = current["weather"][0]["description"];
          // Pick 4 readings (1 per day)
          forecast = List.generate(4, (i) => data["list"][i * 8]);
          isLoading = false;
        });
      } else {
        setState(() => isLoading = false);
      }
    } catch (e) {
      print("Error fetching weather: $e");
      setState(() => isLoading = false);
    }
  }

  // Choose color based on weather
  Color getWeatherColor(String desc) {
    if (desc.contains("rain")) return Colors.blue.shade100;
    if (desc.contains("cloud")) return Colors.grey.shade300;
    if (desc.contains("clear")) return Colors.orange.shade100;
    if (desc.contains("sun")) return Colors.yellow.shade100;
    return Colors.green.shade100;
  }

  // Choose icon based on weather
  IconData getWeatherIcon(String desc) {
    if (desc.contains("rain")) return Icons.beach_access;
    if (desc.contains("cloud")) return Icons.cloud;
    if (desc.contains("clear")) return Icons.wb_sunny;
    if (desc.contains("storm")) return Icons.flash_on;
    return Icons.thermostat;
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? Center(child: Lottie.asset("assets/loading.json", width: 150))
        : SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  "Weather in $city",
                  style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.green),
                ),
                const SizedBox(height: 20),

                // Current Weather Card
                Card(
                  color: getWeatherColor(description),
                  elevation: 6,
                  shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(16)),
                  child: Padding(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      children: [
                        Icon(getWeatherIcon(description),
                            size: 60, color: Colors.green.shade800),
                        const SizedBox(height: 8),
                        Text("$temperature°C",
                            style: const TextStyle(
                                fontSize: 36, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 6),
                        Text(
                          description[0].toUpperCase() +
                              description.substring(1),
                          style: const TextStyle(
                              fontSize: 18, fontStyle: FontStyle.italic),
                        ),
                      ],
                    ),
                  ),
                ),

                const SizedBox(height: 30),
                const Text(
                  "Next 3 Days Forecast",
                  style: TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal),
                ),
                const SizedBox(height: 10),

                // Forecast List
                ...forecast.skip(1).map((day) {
                  DateTime date = DateTime.parse(day["dt_txt"]);
                  double temp = day["main"]["temp"].toDouble();
                  String desc = day["weather"][0]["description"];
                  return Card(
                    color: getWeatherColor(desc),
                    margin: const EdgeInsets.symmetric(vertical: 6),
                    child: ListTile(
                      leading: Icon(getWeatherIcon(desc),
                          color: Colors.teal.shade700, size: 30),
                      title: Text(
                        "${date.day}/${date.month}  -  ${desc[0].toUpperCase()}${desc.substring(1)}",
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: Text(
                        "$temp°C",
                        style: const TextStyle(
                            fontSize: 18, fontWeight: FontWeight.bold),
                      ),
                    ),
                  );
                }).toList(),
              ],
            ),
          );
  }
}
