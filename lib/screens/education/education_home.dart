import 'package:flutter/material.dart';

class EducationHome extends StatelessWidget {
  const EducationHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // POZADINA
          Positioned.fill(
            child: Image.asset(
              'assets/images/main_bg.jpg', // stavi sliku ovde
              fit: BoxFit.cover,
            ),
          ),

          // "Start learning with Luna"
          Positioned(
            top: 180,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                // logika za početak
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text("Start learning with Luna"),
            ),
          ),

          // "Beginner"
          Positioned(
            top: 280,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                // beginner lekcija
              },
              child: const Text("Beginner"),
            ),
          ),

          // "Intermediate"
          Positioned(
            top: 350,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                // intermediate lekcija
              },
              child: const Text("Intermediate"),
            ),
          ),

          // "Advanced"
          Positioned(
            top: 420,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                // advanced lekcija
              },
              child: const Text("Advanced"),
            ),
          ),

          // "Trading Psychology"
          Positioned(
            top: 490,
            left: 40,
            right: 40,
            child: ElevatedButton(
              onPressed: () {
                // trading psychology
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF2196F3),
              ),
              child: const Text("Trading Psychology"),
            ),
          ),
        ],
      ),
    );
  }
}
