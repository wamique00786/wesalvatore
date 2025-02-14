// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class CareerPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Deep Navy Blue Background
          Container(
            decoration: const BoxDecoration(
              color: Color(0xFF001F3D), // Deep Navy Blue
            ),
          ),

          // Content
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Join Our Team",
                    style: TextStyle(
                      fontSize: 36,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White title text
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    "Discover exciting opportunities and grow your career with us.",
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.white70, // Light gray for the subtext
                    ),
                  ),
                  const SizedBox(height: 30),
                  // "Current Openings" Title
                  Text(
                    "Current Openings",
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white, // White for the heading
                    ),
                  ),
                  const SizedBox(height: 20),
                  Expanded(
                    child: ListView(
                      children: [
                        jobCard("Flutter Developer", "Remote", "Full-Time"),
                        jobCard("UI/UX Designer", "New York", "Part-Time"),
                        jobCard(
                            "Backend Engineer", "San Francisco", "Full-Time"),
                        jobCard("Product Manager", "Remote", "Contract"),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget jobCard(String title, String location, String type) {
    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
      color: Color(0xFFFFF59D), // Soft Yellow Card Background
      child: ListTile(
        contentPadding: const EdgeInsets.all(16),
        title: Text(
          title,
          style: const TextStyle(
              fontSize: 20, fontWeight: FontWeight.bold, color: Colors.black),
        ),
        subtitle: Text(
          "$location • $type",
          style: const TextStyle(fontSize: 16, color: Colors.black54),
        ),
        trailing: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Color(0xFFFF7043), // Coral Button
            shape:
                RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          ),
          onPressed: () {},
          child: const Text(
            "Apply Now",
            style: TextStyle(color: Colors.white),
          ),
        ),
      ),
    );
  }
}
