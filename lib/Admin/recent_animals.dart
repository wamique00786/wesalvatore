import 'package:flutter/material.dart';

class RecentAnimalsScreen extends StatelessWidget {
  final List<Map<String, String>> animals = [
    {"name": "Parrot", "species": "Bird", "status": "RESCUED"},
    {"name": "Dog", "species": "Dog", "status": "RESCUED"},
    {"name": "Hen", "species": "Bird", "status": "RESCUED"},
    {"name": "Cat", "species": "Cat", "status": "RESCUED"},
  ];

  RecentAnimalsScreen({super.key});

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
              'Recent Animals',
              style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 10),
            Expanded(
              child: SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  border: TableBorder.all(),
                  columns: [
                    DataColumn(label: Text('Name')),
                    DataColumn(label: Text('Species')),
                    DataColumn(label: Text('Status')),
                    DataColumn(label: Text('Action')),
                  ],
                  rows: animals
                      .map(
                        (animal) => DataRow(cells: [
                          DataCell(Text(animal["name"]!)),
                          DataCell(Text(animal["species"]!)),
                          DataCell(Text(animal["status"]!,
                              style: TextStyle(fontWeight: FontWeight.bold))),
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
