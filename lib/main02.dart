import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

void main() => runApp(const MyApp());

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      title: 'Flutter Google Maps Demo',
      home: MapSample(),
    );
  }
}

class MapSample extends StatefulWidget {
  const MapSample({super.key});
  @override
  State<MapSample> createState() => MapSampleState();
}

class MapSampleState extends State<MapSample> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();

//pnto origen
  static const CameraPosition _kOrigin = CameraPosition(
    target: LatLng(21.0923774, -101.7469267),
    zoom: 12.4746,
  );

  static const _kGoogleOriginMarker = Marker(
    markerId: MarkerId('_kGooglePlaceOrigin'),
    infoWindow: InfoWindow(title: 'Costco Wholesale'),
    icon: BitmapDescriptor.defaultMarker,
    position: LatLng(21.15774731319369, -101.70571275200567),
  );
  static final Marker _kGoogleStadiumMarker = Marker(
    markerId: const MarkerId('_kGooglePlaceTarget'),
    infoWindow: const InfoWindow(title: 'Bienvenidos a la Fortaleza'),
    icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
    position: const LatLng(21.145068403474465, -101.65972443336388),
  );

//PUNTO DESTINO
  static const CameraPosition _kCollege = CameraPosition(
      bearing: 192.8334901395799,
      // target: LatLng(37.43296265331129, -122.08832357078792),
      target: LatLng(21.0923774, -101.7469267),
      tilt: 59.440717697143555,
      zoom: 19.151926040649414);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: GoogleMap(
        mapType: MapType.terrain,
        markers: {_kGoogleOriginMarker, _kGoogleStadiumMarker},
        initialCameraPosition: _kOrigin,
        onMapCreated: (GoogleMapController controller) {
          _controller.complete(controller);
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _goToTheLake,
        label: const Text('To the Happiness!'),
        icon: const Icon(Icons.directions_boat),
      ),
    );
  }

  Future<void> _goToTheLake() async {
    final GoogleMapController controller = await _controller.future;
    controller.animateCamera(CameraUpdate.newCameraPosition(_kCollege));
    //controller.animateCamera(CameraUpdate.newCameraPosition(_kTarget));
  }
}
