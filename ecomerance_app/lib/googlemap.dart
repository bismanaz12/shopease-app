import 'dart:async';
import 'package:ecomerance_app/Screens/googleprovider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as location;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

class MapPage extends StatefulWidget {
  MapPage({
    super.key,
  });

  @override
  State<MapPage> createState() => _MapPageState();
}

class _MapPageState extends State<MapPage> {
  final location.Location _locationController = location.Location();
  final Completer<GoogleMapController> _mapController =
      Completer<GoogleMapController>();
  String currentAddress = '';
  LatLng? _selectedLocation; // Track the selected location

  static const LatLng _sourceLocation =
      LatLng(37.4223, -122.0848); // Source Location
  static const LatLng _destinationLocation =
      LatLng(37.3346, -122.0090); // Destination Location
  LatLng? _currentLocation;

  Map<PolylineId, Polyline> polylines = {};
  String _distance = '';

  @override
  void initState() {
    super.initState();
    getLocationUpdates();
  }

  @override
  Widget build(BuildContext context) {
    var Address = Provider.of<AddressProvider>(context, listen: false);
    return Scaffold(
      body: Stack(
        children: [
          GoogleMap(
            onMapCreated: (GoogleMapController controller) =>
                _mapController.complete(controller),
            initialCameraPosition: CameraPosition(
              target: _sourceLocation,
              zoom: 13, // Adjusted zoom level
            ),
            markers: {
              if (_currentLocation != null)
                Marker(
                  markerId: MarkerId("currentLocation"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueRed),
                  position: _currentLocation!,
                ),
              if (_selectedLocation !=
                  null) // Add a marker for the selected location
                Marker(
                  markerId: MarkerId("selectedLocation"),
                  icon: BitmapDescriptor.defaultMarkerWithHue(
                      BitmapDescriptor.hueBlue),
                  position: _selectedLocation!,
                ),
              Marker(
                markerId: MarkerId("sourceLocation"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                position: _sourceLocation,
              ),
              Marker(
                markerId: MarkerId("destinationLocation"),
                icon: BitmapDescriptor.defaultMarkerWithHue(
                    BitmapDescriptor.hueRed),
                position: _destinationLocation,
              ),
            },
            polylines: Set<Polyline>.of(polylines.values),
            myLocationButtonEnabled: true,
            onTap: (LatLng position) async {
              String address = await _getAddressFromLatLng(position);
              setState(() {
                _selectedLocation = position;
                currentAddress = address;
                Address.updateAddress(currentAddress);
              });
            },
          ),
          Positioned(
            top: 50,
            left: 10,
            right: 10,
            child: Container(
              padding: EdgeInsets.all(10),
              color: Colors.white,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    'Selected Address',
                    style: TextStyle(
                      fontWeight: FontWeight.w500,
                      fontSize: 16,
                    ),
                  ),
                  SizedBox(height: 5),
                  Text(
                    currentAddress.isNotEmpty
                        ? currentAddress
                        : 'Tap on the map to select a location...', // Display current address
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[700],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      floatingActionButton: Padding(
        padding: const EdgeInsets.only(right: 23),
        child: FloatingActionButton(
          onPressed: _showDistance,
          child: Icon(Icons.info),
        ),
      ),
    );
  }

  Future<void> _cameraToPosition(LatLng pos) async {
    final GoogleMapController controller = await _mapController.future;
    CameraPosition _newCameraPosition = CameraPosition(
      target: pos,
      zoom: 13,
    );
    await controller
        .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
  }

  Future<void> getLocationUpdates() async {
    bool _serviceEnabled;
    location.PermissionStatus _permissionGranted;

    _serviceEnabled = await _locationController.serviceEnabled();
    if (!_serviceEnabled) {
      _serviceEnabled = await _locationController.requestService();
      if (!_serviceEnabled) {
        return;
      }
    }

    _permissionGranted = await _locationController.hasPermission();
    if (_permissionGranted == location.PermissionStatus.denied) {
      _permissionGranted = await _locationController.requestPermission();
      if (_permissionGranted != location.PermissionStatus.granted) {
        return;
      }
    }

    _locationController.onLocationChanged
        .listen((location.LocationData currentLocation) async {
      if (currentLocation.latitude != null &&
          currentLocation.longitude != null) {
        LatLng newLocation =
            LatLng(currentLocation.latitude!, currentLocation.longitude!);
        String address = await _getAddressFromLatLng(newLocation);

        setState(() {
          _currentLocation = newLocation;
          currentAddress = address;

          // currentAddress = widget.Address;

          // Update distance here
          if (_destinationLocation != null) {
            double distanceInMeters = Geolocator.distanceBetween(
              _currentLocation!.latitude,
              _currentLocation!.longitude,
              _destinationLocation.latitude,
              _destinationLocation.longitude,
            );
            _distance =
                '${(distanceInMeters / 1000).toStringAsFixed(2)} km'; // Convert meters to kilometers
          }
        });

        await _cameraToPosition(
            _currentLocation!); // Move camera to current location

        List<LatLng> coordinates = await getCurrentToDestinationPolyline();
        generateCurrentToDestinationPolyline(coordinates);
      }
    });
  }

  Future<String> _getAddressFromLatLng(LatLng latLng) async {
    try {
      List<geocoding.Placemark> placemarks =
          await geocoding.placemarkFromCoordinates(
        latLng.latitude,
        latLng.longitude,
      );
      geocoding.Placemark place = placemarks[0];
      return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
    } catch (e) {
      print("Error getting address: $e");
      return 'Unknown address';
    }
  }

  Future<List<LatLng>> getCurrentToDestinationPolyline() async {
    List<LatLng> coordinates = [];
    PolylinePoints points = PolylinePoints();
    if (_currentLocation != null) {
      PolylineResult result = await points.getRouteBetweenCoordinates(
        googleApiKey:
            'AIzaSyAeprVS-dONDXpY-ZBTuWk1rjNgCad7VnQ', // Replace with your API Key
        request: PolylineRequest(
          origin: PointLatLng(
              _currentLocation!.latitude, _currentLocation!.longitude),
          destination: PointLatLng(
              _destinationLocation.latitude, _destinationLocation.longitude),
          mode: TravelMode.driving,
        ),
      );
      if (result.points.isNotEmpty) {
        coordinates.addAll(result.points
            .map((point) => LatLng(point.latitude, point.longitude)));
      }
    }
    return coordinates;
  }

  void generateCurrentToDestinationPolyline(List<LatLng> polylineCoordinates) {
    PolylineId id = PolylineId("currentToDestination");
    Polyline polyline = Polyline(
      polylineId: id,
      color: Colors.blue,
      points: polylineCoordinates,
      width: 5,
    );
    setState(() {
      polylines[id] = polyline;
    });
  }

  void _showDistance() {
    if (_currentLocation != null) {
      double distanceInMeters = Geolocator.distanceBetween(
        _currentLocation!.latitude,
        _currentLocation!.longitude,
        _destinationLocation.latitude,
        _destinationLocation.longitude,
      );
      setState(() {
        _distance =
            '${(distanceInMeters / 1000).toStringAsFixed(2)} km'; // Convert meters to kilometers
      });
      showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Distance'),
            content: Text('Distance to destination: $_distance'),
            actions: <Widget>[
              TextButton(
                onPressed: () {
                  Navigator.of(context).pop();
                },
                child: Text('OK'),
              ),
            ],
          );
        },
      );
    }
  }
}
