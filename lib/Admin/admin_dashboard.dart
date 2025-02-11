import 'package:flutter/material.dart';
import 'package:wesalvatore/Admin/recent_animals.dart';
import 'package:wesalvatore/Admin/active_volunteer.dart';
import 'package:wesalvatore/views/navbar.dart';

class AdminDashboard extends StatefulWidget {
  const AdminDashboard({super.key});

  @override
  AdminDashboardState createState() => AdminDashboardState();
}

class AdminDashboardState extends State<AdminDashboard> {
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
            onPressed: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => NavBar(),
                  ));
            },
          ),
        ],
        backgroundColor: Colors.black, // Set background color to black
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          double screenWidth = constraints.maxWidth;
          double screenHeight = constraints.maxHeight;

          return Padding(
            padding: EdgeInsets.all(screenWidth * 0.05), // Responsive padding
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Text(
                  'Administrator Dashboard',
                  style: TextStyle(
                    fontSize: screenWidth * 0.05, // Responsive font size
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(height: screenHeight * 0.02), // Responsive spacing
                Expanded(
                  child: ListView(
                    children: [
                      Card(
                        shadowColor: Colors.blueGrey,
                        semanticContainer: true,
                        clipBehavior: Clip.antiAlias,
                        borderOnForeground: false,
                        margin: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        color: Colors.blueGrey,
                        elevation: 8,
                        child: DashboardCard(title: 'Total Animal', value: '0'),
                      ),
                      Card(
                        shadowColor: Colors.blueGrey,
                        semanticContainer: true,
                        clipBehavior: Clip.antiAlias,
                        borderOnForeground: false,
                        margin: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        color: Colors.blueGrey,
                        elevation: 8,
                        child:
                            DashboardCard(title: 'Under Treatment', value: '0'),
                      ),
                      Card(
                        shadowColor: Colors.blueGrey,
                        semanticContainer: true,
                        clipBehavior: Clip.antiAlias,
                        borderOnForeground: false,
                        margin: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        color: Colors.blueGrey,
                        elevation: 8,
                        child: DashboardCard(title: 'Recovered', value: '0'),
                      ),
                      Card(
                        shadowColor: Colors.blueGrey,
                        semanticContainer: true,
                        clipBehavior: Clip.antiAlias,
                        borderOnForeground: false,
                        margin: EdgeInsets.all(16.0),
                        shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30.0)),
                        color: Colors.blueGrey,
                        elevation: 8,
                        child: DashboardCard(
                            title: 'Total Volunteers', value: '3'),
                      ),
                    ],
                  ),
                ),
                SizedBox(height: 30), // Responsive spacing
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => RecentAnimalsScreen()),
                        );
                      },
                      child: Text(
                        'Recent Animals',
                        style: TextStyle(fontSize: 20), // Responsive font size
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (context) => ActiveVolunteersScreen()),
                        );
                      },
                      child: Text(
                        'Active Volunteers',
                        style: TextStyle(fontSize: 20), // Responsive font size
                      ),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}

class DashboardCard extends StatelessWidget {
  final String title;
  final String value;

  const DashboardCard({super.key, required this.title, required this.value});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black),
        borderRadius: BorderRadius.circular(8),
      ),
      padding: EdgeInsets.all(16),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            title,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            textAlign: TextAlign.center,
          ),
          SizedBox(height: 10),
          Text(
            value,
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ],
      ),
    );
  }
}
