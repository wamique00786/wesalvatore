import 'package:flutter/material.dart';
import 'package:flutter_map/flutter_map.dart';
import 'package:latlong2/latlong.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class RescueMap extends StatefulWidget {
  final LatLng currentPosition;
  final LatLng destination;

  const RescueMap({
    super.key,
    required this.currentPosition,
    required this.destination,
  });

  @override
  _RescueMapState createState() => _RescueMapState();
}

class _RescueMapState extends State<RescueMap> {
  late List<LatLng> _routePoints = [];
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _getRoute();
  }

  // Function to get the directions from OSRM API
  Future<void> _getRoute() async {
    try {
      final response = await http.get(Uri.parse(
          'http://router.project-osrm.org/route/v1/driving/${widget.currentPosition.longitude},${widget.currentPosition.latitude};${widget.destination.longitude},${widget.destination.latitude}?overview=full&geometries=geojson'));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final route = data['routes'][0]['geometry']['coordinates'];
        setState(() {
          _routePoints =
              route.map<LatLng>((point) => LatLng(point[1], point[0])).toList();
          _isLoading = false;
        });
      } else {
        throw Exception('Failed to load route');
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error fetching route: $e')),
      );
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return _isLoading
        ? const Center(child: CircularProgressIndicator())
        : FlutterMap(
            options: MapOptions(
              initialCenter: widget.currentPosition,
              initialZoom: 14.0,
            ),
            children: [
              TileLayer(
                urlTemplate: 'https://tile.openstreetmap.org/{z}/{x}/{y}.png',
                userAgentPackageName: 'com.example.app',
              ),
              if (_routePoints.isNotEmpty)
                PolylineLayer(
                  polylines: [
                    Polyline(
                      points: _routePoints,
                      strokeWidth: 3.5,
                      color: Colors.blue,
                    ),
                  ],
                ),
              MarkerLayer(
                markers: [
                  Marker(
                    point: widget.currentPosition,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin,
                        color: Colors.green, size: 35),
                  ),
                  Marker(
                    point: widget.destination,
                    width: 40,
                    height: 40,
                    child: const Icon(Icons.location_pin,
                        color: Colors.red, size: 35),
                  ),
                ],
              ),
            ],
          );
  }
}
