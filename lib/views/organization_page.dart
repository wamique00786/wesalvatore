// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';

class OrganizationPage extends StatelessWidget {
  final List<Map<String, String>> organizations = [
    {
      "name": "Animal Welfare Society",
      "description": "Dedicated to the rescue and rehabilitation of animals.",
      "website": "https://example.com"
    },
    {
      "name": "Save the Animals",
      "description": "Working towards the protection of endangered species.",
      "website": "https://example.com"
    },
    {
      "name": "Pet Rescue Foundation",
      "description":
          "A non-profit organization focused on rescuing pets in need.",
      "website": "https://example.com"
    },
    {
      "name": "Wildlife Conservation Society",
      "description": "Committed to conserving wildlife and wild places.",
      "website": "https://example.com"
    },
    {
      "name": "Humane Society International",
      "description": "Working for the welfare of animals worldwide.",
      "website": "https://example.com"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
          title: Text("List of Organizations"),
          backgroundColor: Colors.blueAccent,
          automaticallyImplyLeading: false,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.vertical(
              bottom: Radius.circular(20),
              top: Radius.circular(20),
            ),
          )),
      body: ListView.builder(
        padding: EdgeInsets.all(20),
        itemCount: organizations.length,
        itemBuilder: (context, index) {
          final org = organizations[index];
          return Card(
            elevation: 3,
            margin: EdgeInsets.symmetric(vertical: 8),
            child: Padding(
              padding: EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    org["name"]!,
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 5),
                  Text(
                    org["description"]!,
                    style: TextStyle(fontSize: 14, color: Colors.grey[700]),
                  ),
                  SizedBox(height: 10),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      TextButton(
                        onPressed: () {
                          // Open website link
                        },
                        child: Text("Visit Website",
                            style: TextStyle(color: Colors.blue)),
                      ),
                      ElevatedButton(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          foregroundColor: Colors.white,
                        ),
                        onPressed: () {
                          _showDonationPopup(context, org["name"]!);
                        },
                        child: Text("Donate"),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  void _showDonationPopup(BuildContext context, String organizationName) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Donate to $organizationName"),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: 150,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blue,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                            "Donated \$${amountController.text} to $organizationName"),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text("Donate"),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
