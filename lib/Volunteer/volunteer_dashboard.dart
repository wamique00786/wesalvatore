import 'package:flutter/material.dart';
import 'package:flutter_osm_plugin/flutter_osm_plugin.dart';
import 'package:wesalvatore/widgets/task_card.dart';

class VolunteerDashboard extends StatefulWidget {
  const VolunteerDashboard({super.key});

  @override
  VolunteerDashboardState createState() => VolunteerDashboardState();
}

class VolunteerDashboardState extends State<VolunteerDashboard> {
  MapController controller = MapController(
    initPosition: GeoPoint(latitude: 37.7749, longitude: -122.4194),
    areaLimit: BoundingBox(
      east: 10.4922941,
      north: 47.8084648,
      south: 45.817995,
      west: 5.9559113,
    ),
  );

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          'Volunteer Dashboard',
          style: TextStyle(color: Colors.white),
        ),
        backgroundColor: Colors.blueGrey[900],
        actions: [
          DropdownButtonHideUnderline(
            child: DropdownButton<String>(
              icon: const Icon(Icons.language, color: Colors.white),
              items: const [
                DropdownMenuItem(value: "en", child: Text("English")),
                DropdownMenuItem(value: "es", child: Text("Español")),
              ],
              onChanged: (value) {},
            ),
          ),
        ],
      ),
      drawer: Drawer(
        backgroundColor: Color.fromARGB(255, 250, 250, 255),
      ),
      body: Padding(
        padding: EdgeInsets.all(screenWidth * 0.04), // Responsive padding
        child: Column(
          children: [
            Expanded(
              child: LayoutBuilder(
                builder: (context, constraints) {
                  return SingleChildScrollView(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        TaskCard(
                          title: "Available Tasks",
                          tasks: [
                            TaskItem(
                              title: "Feed the cats at the shelter",
                              description:
                                  "Feed the cats and check their health.",
                              buttonLabel: "Mark as Completed",
                            ),
                          ],
                        ),
                        SizedBox(
                            height: screenHeight * 0.02), // Responsive spacing
                        TaskCard(
                          title: "Completed Tasks",
                          tasks: [
                            TaskItem(
                              title: "Feed the dogs at the shelter",
                              description:
                                  "Make sure to feed all the dogs and check their water supply.",
                              buttonLabel: "Completed",
                            ),
                          ],
                        ),
                      ],
                    ),
                  );
                },
              ),
            ),
            SizedBox(height: screenHeight * 0.02), // Responsive spacing
            Container(
              height: screenHeight * 0.3, // Responsive height
              width: double.infinity,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10),
                border: Border.all(color: Colors.grey),
              ),
              child: OSMFlutter(
                controller: controller,
                mapIsLoading: const Center(child: CircularProgressIndicator()),
                osmOption: OSMOption(
                  zoomOption: const ZoomOption(
                    initZoom: 12.0,
                    minZoomLevel: 3,
                    maxZoomLevel: 19,
                    stepZoom: 1.0,
                  ),
                  userTrackingOption: const UserTrackingOption(
                    enableTracking: true,
                    unFollowUser: false, // Corrected parameter name
                  ),
                  showZoomController: true,
                  showDefaultInfoWindow: true,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
