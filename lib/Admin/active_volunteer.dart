import 'package:flutter/material.dart';

class ActiveVolunteersScreen extends StatefulWidget {
  const ActiveVolunteersScreen({super.key});

  @override
  ActiveVolunteersScreenState createState() => ActiveVolunteersScreenState();
}

class ActiveVolunteersScreenState extends State<ActiveVolunteersScreen> {
  final List<Map<String, String>> volunteers = [
    {
      "username": "Volunteer1",
      "email": "volunteer1@gmail.com",
      "location": "Not Specified"
    },
    {
      "username": "Volunteer2",
      "email": "volunteer2@gmail.com",
      "location": "Not Specified"
    },
    {
      "username": "Volunteer3",
      "email": "volunteer3@gmail.com",
      "location": "Not Specified"
    },
    {
      "username": "Volunteer4",
      "email": "volunteer4@gmail.com",
      "location": "Not Specified"
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(
          'Wesalvatore',
          style: TextStyle(color: Colors.white), // Change text color to white
        ),
        leading: Icon(
          Icons.pets,
          color: Colors.white, // Change icon color to white
        ), // Paw icon
        actions: [
          IconButton(
            icon: Icon(Icons.menu, color: Colors.white),
            onPressed: () {},
          ),
        ],
        backgroundColor: Colors.black, // Set background color to black
      ),
      body: Padding(
        padding: EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              'Active Volunteers',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(),
                  columns: [
                    DataColumn(label: Text('Username')),
                    DataColumn(label: Text('Email')),
                    DataColumn(label: Text('Location')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: volunteers
                      .map(
                        (volunteer) => DataRow(cells: [
                          DataCell(Text(volunteer["username"]!)),
                          DataCell(Text(volunteer["email"]!)),
                          DataCell(Text(volunteer["location"]!)),
                          DataCell(
                            ElevatedButton(
                              onPressed: () {
                                // Handle "View" button click
                              },
                              child: Text('View'),
                            ),
                          ),
                        ]),
                      )
                      .toList(),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
