import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_stripe/flutter_stripe.dart';
import 'package:geocoding/geocoding.dart' as geocoding;
import 'package:get/get.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
import 'package:location/location.dart' as location;
import 'package:geolocator/geolocator.dart';
import 'package:provider/provider.dart';

import 'controllers/address_provider.dart';

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
                        ? Address.currentAddress
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
      // floatingActionButton: Padding(
      //   padding: const EdgeInsets.only(right: 23),
      //   child: FloatingActionButton(
      //     onPressed: _showDistance,
      //     child: Icon(Icons.info),
      //   ),
      // ),
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

//   void _showDistance() {
//     if (_currentLocation != null) {
//       double distanceInMeters = Geolocator.distanceBetween(
//         _currentLocation!.latitude,
//         _currentLocation!.longitude,
//         _destinationLocation.latitude,
//         _destinationLocation.longitude,
//       );
//       setState(() {
//         _distance =
//         '${(distanceInMeters / 1000).toStringAsFixed(2)} km'; // Convert meters to kilometers
//       });
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Distance'),
//             content: Text('Distance to destination: $_distance'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// \
}

























// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:geocoding/geocoding.dart' as geocoding;
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:flutter_polyline_points/flutter_polyline_points.dart';
// import 'package:location/location.dart' as location;
// import 'package:geolocator/geolocator.dart';

// class MapPage extends StatefulWidget {
//   const MapPage({super.key});

//   @override
//   State<MapPage> createState() => _MapPageState();
// }

// class _MapPageState extends State<MapPage> {
//   final location.Location _locationController = location.Location();
//   final Completer<GoogleMapController> _mapController =
//       Completer<GoogleMapController>();
//   String _currentAddress = '';
//   LatLng? _selectedLocation; // Track the selected location

//   static const LatLng _sourceLocation =
//       LatLng(37.4223, -122.0848); // Source Location
//   static const LatLng _destinationLocation =
//       LatLng(37.3346, -122.0090); // Destination Location
//   LatLng? _currentLocation;

//   Map<PolylineId, Polyline> polylines = {};
//   String _distance = '';

//   @override
//   void initState() {
//     super.initState();
//     getLocationUpdates();
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: Stack(
//         children: [
//           GoogleMap(
//             onMapCreated: (GoogleMapController controller) =>
//                 _mapController.complete(controller),
//             initialCameraPosition: CameraPosition(
//               target: _sourceLocation,
//               zoom: 25,
//             ),
//             markers: {
//               if (_currentLocation != null)
//                 Marker(
//                   markerId: MarkerId("currentLocation"),
//                   icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueRed),
//                   position: _currentLocation!,
//                 ),
//               if (_selectedLocation !=
//                   null) // Add a marker for the selected location
//                 Marker(
//                   markerId: MarkerId("selectedLocation"),
//                   icon: BitmapDescriptor.defaultMarkerWithHue(
//                       BitmapDescriptor.hueBlue),
//                   position: _selectedLocation!,
//                 ),
//               Marker(
//                 markerId: MarkerId("sourceLocation"),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                     BitmapDescriptor.hueRed),
//                 position: _sourceLocation,
//               ),
//               Marker(
//                 markerId: MarkerId("destinationLocation"),
//                 icon: BitmapDescriptor.defaultMarkerWithHue(
//                     BitmapDescriptor.hueRed),
//                 position: _destinationLocation,
//               ),
//             },
//             polylines: Set<Polyline>.of(polylines.values),
//             myLocationButtonEnabled: true,
//             onTap: (LatLng position) async {
//               String address = await _getAddressFromLatLng(position);
//               setState(() {
//                 _selectedLocation = position;
//                 _currentAddress = address;
//               });
//             },
//           ),
//           Positioned(
//             top: 50,
//             left: 10,
//             right: 10,
//             child: Container(
//               padding: EdgeInsets.all(10),
//               color: Colors.white,
//               child: Column(
//                 crossAxisAlignment: CrossAxisAlignment.start,
//                 children: [
//                   Text(
//                     'Selected Address',
//                     style: TextStyle(
//                       fontWeight: FontWeight.w500,
//                       fontSize: 16,
//                     ),
//                   ),
//                   SizedBox(height: 5),
//                   Text(
//                     _currentAddress.isNotEmpty
//                         ? _currentAddress
//                         : 'Tap on the map to select a location...', // Display current address
//                     style: TextStyle(
//                       fontSize: 14,
//                       color: Colors.grey[700],
//                     ),
//                   ),
//                 ],
//               ),
//             ),
//           ),
//         ],
//       ),
//       floatingActionButton: Padding(
//         padding: const EdgeInsets.only(right: 23),
//         child: FloatingActionButton(
//           onPressed: _showDistance,
//           child: Icon(Icons.info),
//         ),
//       ),
//     );
//   }

//   Future<void> _cameraToPosition(LatLng pos) async {
//     final GoogleMapController controller = await _mapController.future;
//     CameraPosition _newCameraPosition = CameraPosition(
//       target: pos,
//       zoom: 13,
//     );
//     await controller
//         .animateCamera(CameraUpdate.newCameraPosition(_newCameraPosition));
//   }

//   Future<void> getLocationUpdates() async {
//     bool _serviceEnabled;
//     location.PermissionStatus _permissionGranted;

//     _serviceEnabled = await _locationController.serviceEnabled();
//     if (!_serviceEnabled) {
//       _serviceEnabled = await _locationController.requestService();
//       if (!_serviceEnabled) {
//         return;
//       }
//     }

//     _permissionGranted = await _locationController.hasPermission();
//     if (_permissionGranted == location.PermissionStatus.denied) {
//       _permissionGranted = await _locationController.requestPermission();
//       if (_permissionGranted != location.PermissionStatus.granted) {
//         return;
//       }
//     }

//     _locationController.onLocationChanged
//         .listen((location.LocationData currentLocation) async {
//       if (currentLocation.latitude != null &&
//           currentLocation.longitude != null) {
//         LatLng newLocation =
//             LatLng(currentLocation.latitude!, currentLocation.longitude!);
//         String address = await _getAddressFromLatLng(newLocation);

//         setState(() {
//           _currentLocation = newLocation;
//           _currentAddress = address;
//           _cameraToPosition(_currentLocation!);
//         });

//         getCurrentToDestinationPolyline().then(
//           (coordinates) => generateCurrentToDestinationPolyline(coordinates),
//         );
//       }
//     });
//   }

//   Future<String> _getAddressFromLatLng(LatLng latLng) async {
//     try {
//       List<geocoding.Placemark> placemarks =
//           await geocoding.placemarkFromCoordinates(
//         latLng.latitude,
//         latLng.longitude,
//       );
//       geocoding.Placemark place = placemarks[0];
//       return '${place.street ?? ''}, ${place.subLocality ?? ''}, ${place.locality ?? ''}, ${place.postalCode ?? ''}, ${place.country ?? ''}';
//     } catch (e) {
//       print("Error getting address: $e");
//       return 'Unknown address';
//     }
//   }

//   Future<List<LatLng>> getCurrentToDestinationPolyline() async {
//     List<LatLng> coordinates = [];
//     PolylinePoints points = PolylinePoints();
//     if (_currentLocation != null) {
//       PolylineResult result = await points.getRouteBetweenCoordinates(
//         googleApiKey: 'YOUR_API_KEY', // Replace with your API Key
//         request: PolylineRequest(
//           origin: PointLatLng(
//               _currentLocation!.latitude, _currentLocation!.longitude),
//           destination: PointLatLng(
//               _destinationLocation.latitude, _destinationLocation.longitude),
//           mode: TravelMode.driving,
//         ),
//       );
//       if (result.points.isNotEmpty) {
//         coordinates.addAll(result.points
//             .map((point) => LatLng(point.latitude, point.longitude)));
//       }
//     }
//     return coordinates;
//   }

//   void generateCurrentToDestinationPolyline(List<LatLng> polylineCoordinates) {
//     PolylineId id = PolylineId("currentToDestination");
//     Polyline polyline = Polyline(
//       polylineId: id,
//       color: Colors.blue,
//       points: polylineCoordinates,
//       width: 5,
//     );
//     setState(() {
//       polylines[id] = polyline;
//     });
//   }

//   void _showDistance() {
//     if (_currentLocation != null) {
//       double distanceInMeters = Geolocator.distanceBetween(
//         _currentLocation!.latitude,
//         _currentLocation!.longitude,
//         _destinationLocation.latitude,
//         _destinationLocation.longitude,
//       );
//       setState(() {
//         _distance =
//             '${(distanceInMeters / 1000).toStringAsFixed(2)} km'; // Convert meters to kilometers
//       });
//       showDialog(
//         context: context,
//         builder: (context) {
//           return AlertDialog(
//             title: Text('Distance'),
//             content: Text('Distance to destination: $_distance'),
//             actions: <Widget>[
//               TextButton(
//                 onPressed: () {
//                   Navigator.of(context).pop();
//                 },
//                 child: Text('OK'),
//               ),
//             ],
//           );
//         },
//       );
//     }
//   }
// }
















































// import 'dart:async';
// import 'dart:ui' as ui;
// import 'package:custom_info_window/custom_info_window.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/gestures.dart';
// import 'package:flutter/material.dart';
// import 'package:flutter/services.dart';
// import 'package:google_maps_flutter/google_maps_flutter.dart';
// import 'package:location/location.dart';

// class GoogleMapScreen extends StatefulWidget {
//   const GoogleMapScreen({super.key, required this.restaurant});

//   static const routeName = 'map-screen';
//   final Map<String, dynamic> restaurant;

//   @override
//   State<GoogleMapScreen> createState() => _GoogleMapScreenState();
// }

// class _GoogleMapScreenState extends State<GoogleMapScreen> {
//   CustomInfoWindowController customInfoWindowController =
//       CustomInfoWindowController();

//   String imagePath =
//       'https://foodie.junaidali.tk/storage/app/public/restaurant/cover/';
//   LocationData? locationData;
//   BitmapDescriptor? destinationMarkerIcon;
//   BitmapDescriptor? riderMarkerIcon;

//   final LatLng gugasht =
//       LatLng(37.7949, -122.3994); // Coordinates for "Gourmet Haven"
//   Set<Marker> markers = {};
//   List<LatLng> latlng = [];
//   List<LatLng> polylineCoordinates = [];

//   @override
//   void initState() {
//     super.initState();
//     getLocation();
//     initializeMarkers();
//   }

//   Future<void> getLocation() async {
//     Location location = Location();

//     bool serviceEnabled;
//     PermissionStatus permissionGranted;

//     serviceEnabled = await location.serviceEnabled();
//     if (!serviceEnabled) {
//       serviceEnabled = await location.requestService();
//       if (!serviceEnabled) {
//         // Handle service not enabled
//         return;
//       }
//     }

//     permissionGranted = await location.hasPermission();
//     if (permissionGranted == PermissionStatus.denied) {
//       permissionGranted = await location.requestPermission();
//       if (permissionGranted != PermissionStatus.granted) {
//         // Handle permission not granted
//         return;
//       }
//     }

//     locationData = await location.getLocation();
//     setState(() {});
//   }

//   Future<void> initializeMarkers() async {
//     try {
//       destinationMarkerIcon =
//           await createMarkerIcon('assets/icons/MealMonkeyLogo.png', 100, 100);
//       riderMarkerIcon = await createMarkerIcon('assets/icons/RiderIcon.png',
//           100, 100); // Replace with your rider icon

//       final restaurants = widget.restaurant['Restaurants'] as List<dynamic>?;

//       if (restaurants == null) {
//         print("No restaurants found in the data.");
//         return;
//       }

//       for (int i = 0; i < restaurants.length; i++) {
//         final restaurant = restaurants[i] as Map<String, dynamic>?;

//         if (restaurant == null) {
//           print("Restaurant data is null for index $i.");
//           continue;
//         }

//         final latitude = restaurant['latitude'] as String?;
//         final longitude = restaurant['longitude'] as String?;

//         if (latitude == null || longitude == null) {
//           print("Latitude or Longitude is null for restaurant $i.");
//           continue;
//         }

//         final latLng = LatLng(double.parse(latitude), double.parse(longitude));
//         latlng.add(latLng);

//         // Add marker for each restaurant
//         markers.add(Marker(
//           onTap: () {
//             customInfoWindowController.addInfoWindow!(
//                 Container(
//                   height: 300,
//                   width: 70,
//                   decoration: BoxDecoration(
//                       color: Colors.white,
//                       borderRadius: BorderRadius.circular(10),
//                       border: Border.all(color: Colors.grey)),
//                   child: Column(
//                       mainAxisAlignment: MainAxisAlignment.start,
//                       crossAxisAlignment: CrossAxisAlignment.start,
//                       children: [
//                         Container(
//                           height: 60,
//                           width: double.infinity,
//                           decoration: BoxDecoration(
//                               color: Colors.red,
//                               image: DecorationImage(
//                                   image: NetworkImage(
//                                     '$imagePath${restaurant['coverPhoto']}',
//                                   ),
//                                   fit: BoxFit.cover,
//                                   filterQuality: FilterQuality.high),
//                               borderRadius:
//                                   const BorderRadius.all(Radius.circular(10))),
//                         ),
//                         Text(
//                           restaurant['name'] ?? 'No Name',
//                           style: const TextStyle(
//                               color: Colors.black, fontFamily: 'Inter-regular'),
//                         ),
//                         Text(
//                           restaurant['address'] ?? 'No Address',
//                           maxLines: 2,
//                           style: const TextStyle(
//                               color: Colors.black, fontFamily: 'Inter-regular'),
//                         )
//                       ]),
//                 ),
//                 latLng);
//           },
//           markerId: MarkerId(i.toString()),
//           icon: destinationMarkerIcon!,
//           position: latLng,
//         ));
//       }

//       if (locationData != null) {
//         final riderLatLng =
//             LatLng(locationData!.latitude!, locationData!.longitude!);

//         // Add marker for rider
//         markers.add(Marker(
//           markerId: MarkerId('rider'),
//           position: riderLatLng,
//           icon: riderMarkerIcon!,
//           infoWindow: InfoWindow(title: 'Your Location'),
//         ));

//         // Add marker for destination (Gourmet Haven)
//         markers.add(Marker(
//           markerId: MarkerId('destination'),
//           position: gugasht,
//           icon: destinationMarkerIcon!,
//           infoWindow: InfoWindow(title: 'Gourmet Haven'),
//         ));

//         // Add polyline between rider and destination
//         polylineCoordinates.add(riderLatLng);
//         polylineCoordinates.add(gugasht);

//         setState(() {});
//       }
//     } catch (e) {
//       print("Error initializing markers: $e");
//     }
//   }

//   Future<BitmapDescriptor> createMarkerIcon(
//       String iconPath, double width, double height) async {
//     final byteData = await rootBundle.load(iconPath);
//     final buffer = byteData.buffer.asUint8List();
//     final codec = await ui.instantiateImageCodec(buffer,
//         targetHeight: height.toInt(), targetWidth: width.toInt());
//     final ui.FrameInfo frameInfo = await codec.getNextFrame();
//     final ByteData? byteDataResized =
//         await frameInfo.image.toByteData(format: ui.ImageByteFormat.png);

//     return BitmapDescriptor.fromBytes(byteDataResized!.buffer.asUint8List());
//   }

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       body: locationData == null
//           ? const Center(
//               child: CircularProgressIndicator(),
//             )
//           : Stack(
//               children: [
//                 GoogleMap(
//                   onMapCreated: (controller) => customInfoWindowController
//                       .googleMapController = controller,
//                   onCameraMove: (position) =>
//                       customInfoWindowController.onCameraMove!(),
//                   initialCameraPosition: CameraPosition(
//                     target: latlng.isNotEmpty ? latlng[0] : LatLng(0.0, 0.0),
//                     zoom: 13,
//                   ),
//                   markers: markers,
//                   polylines: {
//                     Polyline(
//                       polylineId: PolylineId('route'),
//                       points: polylineCoordinates,
//                       color: Colors.blue,
//                       width: 5,
//                     )
//                   },
//                   gestureRecognizers:
//                       <Factory<OneSequenceGestureRecognizer>>{}.toSet(),
//                 ),
//                 CustomInfoWindow(
//                   controller: customInfoWindowController,
//                   height: 100,
//                   width: 300,
//                   offset: 35,
//                 )
//               ],
//             ),
//     );
//   }
// }