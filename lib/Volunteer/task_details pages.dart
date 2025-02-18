import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:geolocator/geolocator.dart';
import 'package:latlong2/latlong.dart';
import './rescue_map_page.dart';

class TaskDetailsPages extends StatefulWidget {
  TaskDetailsPages({super.key});

  @override
  State<TaskDetailsPages> createState() => _TaskDetailsPagesState();
}

class _TaskDetailsPagesState extends State<TaskDetailsPages> {
  final LatLng destination = LatLng(23.369167, 85.343056);

  LatLng? startingLocation;

  void _getCurrentLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      LatLng newLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        startingLocation = newLocation;
      });
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error getting location: $e'),
      ));
    }
  }

  @override
  void initState() {
    super.initState();
    _getCurrentLocation();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Cat Rescue Task Details"),
        backgroundColor: Colors.orange,
      ),
      body: Stack(
        children: [
          Text("Feed the cat "),
          Text("Details about the task  "),
          startingLocation == null
              ? const Center(child: CircularProgressIndicator())
              : Container(
                  height: 400,
                  width: 400,
                  padding: EdgeInsets.all(8),
                  child: RescueMap(
                    currentPosition: startingLocation!,
                    destination: destination,
                  ),
                ),
        ],
      ),
    );
  }
}
