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
  Set<Marker> _markers = {}; // Set to hold markers

  BitmapDescriptor userIcon = BitmapDescriptor.defaultMarker;

  static const CameraPosition _kGooglePlex = CameraPosition(
    target: LatLng(37.43296265331129, -122.08832357078792),
    zoom: 14.4746,
  );

  void setCustomIcon() {
    BitmapDescriptor.fromAssetImage(ImageConfiguration.empty, "assets/user.png").then(
      (icon) {
        userIcon = icon;
      },
    );
  }

  @override
  void initState() {
    super.initState();
    setCustomIcon();
    _requestLocationPermission();
  }

  Future<void> _requestLocationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        print("Location permissions are denied");
      }
    }

    if (permission == LocationPermission.deniedForever) {
      print("Location permissions are permanently denied");
    }
  }

  Future<void> _goToTheUserLocation() async {
    final GoogleMapController controller = await _controller.future;

    try {
      Position position =
      await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      LatLng userLocation = LatLng(position.latitude, position.longitude);

      setState(() {
        _markers.clear(); // Clear existing markers
        _markers.add(
          Marker(
            markerId: MarkerId("user_location"),
            position: userLocation,
            icon: userIcon,
          ),
        );
      });

      await controller.animateCamera(CameraUpdate.newLatLng(userLocation));
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: GoogleMap(
          mapType: MapType.normal,
          initialCameraPosition: _kGooglePlex,
          onMapCreated: (GoogleMapController controller) {
            _controller.complete(controller);
          },
          zoomControlsEnabled: false,
          markers: _markers,
        ),
        floatingActionButton: FloatingActionButton.extended(
          onPressed: _goToTheUserLocation,
          label: const Text('Go to My Location'),
          icon: const Icon(Icons.location_on),
        ),
      ),
    );
  }
}
