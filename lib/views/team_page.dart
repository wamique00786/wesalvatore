// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class TeamPage extends StatelessWidget {
  final List<Map<String, String>> teamMembers = [
    {
      "name": "John Doe",
      "role": "Project Manager",
      "image": "assets/profile1.jpg"
    },
    {
      "name": "Jane Smith",
      "role": "Lead Developer",
      "image": "assets/profile2.jpg"
    },
    {
      "name": "Emily Johnson",
      "role": "UI/UX Designer",
      "image": "assets/profile3.jpg"
    },
    {
      "name": "Michael Brown",
      "role": "Backend Developer",
      "image": "assets/profile1.jpg"
    },
    {
      "name": "Sarah Wilson",
      "role": "QA Engineer",
      "image": "assets/profile2.jpg"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("Meet Our Team"),
          backgroundColor: Colors.blueAccent,
          automaticallyImplyLeading: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
              top: Radius.circular(20),
            ),
          )),
      body: Padding(
        padding: EdgeInsets.all(10),
        child: GridView.builder(
          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
            crossAxisCount: 2, // 2 columns
            crossAxisSpacing: 10,
            mainAxisSpacing: 10,
            childAspectRatio: 0.8, // Controls card height
          ),
          itemCount: teamMembers.length,
          itemBuilder: (context, index) {
            final member = teamMembers[index];
            return Card(
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  CircleAvatar(
                    radius: 40,
                    backgroundImage: NetworkImage(member["image"]!),
                  ),
                  SizedBox(height: 10),
                  Text(
                    member["name"]!,
                    style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  SizedBox(height: 5),
                  Text(
                    member["role"]!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            );
          },
        ),
      ),
    );
  }
}
