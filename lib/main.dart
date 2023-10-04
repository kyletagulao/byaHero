import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

void main() {
  runApp(const MapSample());
}

class MapSample extends StatefulWidget {
  const MapSample({Key? key}) : super(key: key);

  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
  Completer<GoogleMapController>();

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
    zoom: 14.4746,
  );

  @override
  void initState() {
    super.initState();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        // Handle the case where the user denies location permission
        print("Location permissions are denied");
        // You might want to show a dialog or a snackbar to inform the user
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // Handle the case where the user permanently denies location permission
      print("Location permissions are permanently denied");
      // You might want to show a dialog or a snackbar to inform the user
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      home: Scaffold(
        body: GoogleMap(
          mapType: MapType.hybrid,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToTheUserLocation,
          label: const Text('Go to My Location'),
          icon: const Icon(Icons.location_on),
        ),
      ),
    );
  }

  Future<void> _goToTheUserLocation() async {
    final GoogleMapController controller = await _controller.future;

    try {
      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng userLocation = LatLng(position.latitude, position.longitude);
      await controller.animateCamera(CameraUpdate.newLatLng(userLocation));
    } catch (e) {
      print("Error getting location: $e");
      // Handle the case where getting the location failed
    }
  }
}
