import 'package:flutter/material.dart';

class FarmInfoPage extends StatelessWidget {
  const FarmInfoPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Padding(
      padding: EdgeInsets.all(16),
      child: Text(
        "Smart Farm Features:\n"
        "- Real-time temperature, humidity, soil, water level monitoring\n"
        "- Rain prediction\n"
        "- Pump scheduling\n"
        "- Field-wise analytics\n"
        "- Farmer-specific data saved in MongoDB",
        style: TextStyle(fontSize: 16, height: 1.5),
      ),
    );
  }
}
