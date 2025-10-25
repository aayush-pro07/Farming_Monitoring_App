import 'package:flutter/material.dart';

class FarmInfoPage extends StatelessWidget {
  const FarmInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: const SingleChildScrollView(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "🌾 Smart Farm Monitoring System",
              style: TextStyle(
                fontSize: 22,
                fontWeight: FontWeight.bold,
                color: Colors.green,
              ),
            ),
            SizedBox(height: 12),
            Text(
              "This mobile application helps farmers monitor and manage their farms efficiently using IoT technology and cloud-based data storage.",
              style: TextStyle(fontSize: 16, height: 1.5),
            ),
            SizedBox(height: 20),
            Text(
              "📊 Key Features:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "- Real-time monitoring of soil moisture, water level, rain status, and temperature.\n"
              "- Automatic irrigation control based on sensor conditions.\n"
              "- Dynamic dashboard displaying live sensor data.\n"
              "- Secure farmer login and personalized data view.\n"
              "- Detailed pump activity logs and irrigation history.\n"
              "- Field-wise analytics and weather-based predictions.\n"
              "- Cloud data storage using ThingSpeak and MongoDB Atlas.",
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            SizedBox(height: 20),
            Text(
              "🧠 System Workflow:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "1. IoT sensors installed in the farm measure real-time parameters.\n"
              "2. Data is uploaded to ThingSpeak and MongoDB through the Node.js backend.\n"
              "3. The app retrieves and visualizes live data for the farmer.\n"
              "4. Based on soil dryness, water level, and rain detection, the system decides whether to turn the pump ON/OFF automatically.\n"
              "5. Farmers can also veiw the pump status logs and monitor their farm's activities.",
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            SizedBox(height: 20),
            Text(
              "🧩 Technologies Used:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "- Flutter (Front-end Mobile App)\n"
              "- Node.js & Express.js (Backend API)\n"
              "- MongoDB Atlas (Cloud Database)\n"
              "- ThingSpeak (IoT Data Platform)\n"
              "- Arduino/ESP32 (Sensor & Pump Control)\n"
              "- HTTP REST APIs for data communication",
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
            SizedBox(height: 20),
            Text(
              "🌍 Objective:",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                color: Colors.black87,
              ),
            ),
            SizedBox(height: 10),
            Text(
              "To empower farmers with a smart, automated, and data-driven farming solution that reduces water wastage, improves efficiency, and provides actionable insights for better crop yield.",
              style: TextStyle(fontSize: 16, height: 1.6),
            ),
          ],
        ),
      ),
    );
  }
}
