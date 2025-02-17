// ignore_for_file: use_key_in_widget_constructors, library_private_types_in_public_api

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class DonationListPage extends StatefulWidget {
  @override
  _DonationListPageState createState() => _DonationListPageState();
}

class _DonationListPageState extends State<DonationListPage>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _fadeAnimation;

  final List<Map<String, String>> donations = [
    {
      'user': 'admin1',
      'amount': '\$50.00',
      'date': '2025-02-11',
      'ngo': 'Animal Welfare'
    },
    {
      'user': 'admin2',
      'amount': '\$50.00',
      'date': '2025-01-11',
      'ngo': 'Animal Welfare'
    },
  ];

  @override
  void initState() {
    super.initState();
    _controller =
        AnimationController(vsync: this, duration: Duration(milliseconds: 700));
    _fadeAnimation = CurvedAnimation(parent: _controller, curve: Curves.easeIn);
    _controller.forward();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white, //Colors.teal[50],
      appBar: _buildAppBar(),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            _titleSection(),
            SizedBox(height: 10),
            _tableHeader(),
            Expanded(
              child: FadeTransition(
                opacity: _fadeAnimation,
                child: ListView.builder(
                  itemCount: donations.length,
                  itemBuilder: (context, index) {
                    return _donationRow(donations[index]);
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  /// **🔹 App Bar - Styled to Match Previous Page**
  AppBar _buildAppBar() {
    return AppBar(
      backgroundColor: Colors.teal[700],
      title: Text(
        'Donation List',
        style: GoogleFonts.poppins(
            fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white),
      ),
      centerTitle: true,
      actions: [
        // ElevatedButton.icon(
        //   onPressed: () {},
        //   icon: Icon(Icons.language, color: Colors.blueAccent),
        //   label: Text('Select Language',
        //       style: TextStyle(color: Colors.blueAccent)),
        //   style: ElevatedButton.styleFrom(
        //     backgroundColor: Colors.white,
        //     shape:
        //         RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
        //   ),
        // ),
      ],
    );
  }

  /// **🔹 Page Title Section**
  Widget _titleSection() {
    return Text(
      'Recent Donations',
      style: GoogleFonts.poppins(
          fontSize: 22, fontWeight: FontWeight.bold, color: Colors.teal[800]),
    );
  }

  /// **🔹 Table Header**
  Widget _tableHeader() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.teal[700],
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: ['User', 'Amount', 'Date', 'NGO']
            .map((title) => _tableText(title, isHeader: true))
            .toList(),
      ),
    );
  }

  /// **🔹 Donation Row**
  Widget _donationRow(Map<String, String> donation) {
    return Container(
      padding: EdgeInsets.symmetric(vertical: 12, horizontal: 8),
      decoration: BoxDecoration(
        border: Border(bottom: BorderSide(color: Colors.grey.shade300)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          _tableText(donation['user']!),
          _tableText(donation['amount']!),
          _tableText(donation['date']!),
          _tableText(donation['ngo']!),
        ],
      ),
    );
  }

  /// **🔹 Table Cell Text Widget (Reusable)**
  Widget _tableText(String text, {bool isHeader = false}) {
    return Expanded(
      child: Text(
        text,
        style: GoogleFonts.poppins(
          fontSize: isHeader ? 16 : 14,
          fontWeight: isHeader ? FontWeight.bold : FontWeight.normal,
          color: isHeader ? Colors.white : Colors.black87,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
}
