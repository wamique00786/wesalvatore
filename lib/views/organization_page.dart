// ignore_for_file: use_key_in_widget_constructors

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:url_launcher/url_launcher.dart';

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
      backgroundColor: Colors.white, //Colors.teal[50],
      appBar: _buildAppBar(),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: ListView.builder(
          itemCount: organizations.length,
          itemBuilder: (context, index) {
            return _organizationCard(context, organizations[index]);
          },
        ),
      ),
    );
  }

  /// **🔹 Styled App Bar**
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal[700],
      title: Text(
        "Organizations",
        style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(bottom: Radius.circular(20)),
      ),
    );
  }

  /// **🔹 Organization Card Widget**
  Widget _organizationCard(BuildContext context, Map<String, String> org) {
    return Card(
      elevation: 3,
      margin: EdgeInsets.symmetric(vertical: 8),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      child: Padding(
        padding: EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              org["name"]!,
              style: GoogleFonts.poppins(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: Colors.teal[800]),
            ),
            SizedBox(height: 5),
            Text(
              org["description"]!,
              style: GoogleFonts.poppins(fontSize: 14, color: Colors.grey[700]),
            ),
            SizedBox(height: 15),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                TextButton.icon(
                  onPressed: () => _launchURL(org["website"]!),
                  icon: Icon(Icons.public, color: Colors.teal[700]),
                  label: Text("Visit Website",
                      style: TextStyle(color: Colors.teal[700])),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(8)),
                  ),
                  onPressed: () => _showDonationPopup(context, org["name"]!),
                  child: Text("Donate"),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 Opens Website in Browser**
  void _launchURL(String url) async {
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      debugPrint("Could not launch $url");
    }
  }

  /// **🔹 Donation Popup**
  void _showDonationPopup(BuildContext context, String organizationName) {
    TextEditingController amountController = TextEditingController();

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          title: Text("Donate to $organizationName",
              style: GoogleFonts.poppins(fontWeight: FontWeight.bold)),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(
                  labelText: "Enter Amount",
                  border: OutlineInputBorder(),
                ),
              ),
              SizedBox(height: 15),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.teal[700],
                    foregroundColor: Colors.white,
                  ),
                  onPressed: () {
                    Navigator.pop(context); // Close the dialog
                    ScaffoldMessenger.of(context).showSnackBar(
                      SnackBar(
                        content: Text(
                          "Donated \$${amountController.text} to $organizationName",
                          style: GoogleFonts.poppins(),
                        ),
                        duration: Duration(seconds: 2),
                      ),
                    );
                  },
                  child: Text("Donate", style: GoogleFonts.poppins()),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
