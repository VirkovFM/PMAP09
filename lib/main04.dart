import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pmap09/location_service.dart';
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
  final TextEditingController _searchController = TextEditingController();
  static const CameraPosition _kOrigin = CameraPosition(
    target: LatLng(21.15774731319369, -101.70571275200567),
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
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Google Maps'),
      ),
      body: Column(
        children: [
          Row(
            children: [
              Expanded(
                child: TextFormField(
                    controller: _searchController,
                    textCapitalization: TextCapitalization.words,
                    decoration:
                        const InputDecoration(hintText: 'Search by City'),
                    onChanged: (value) {
                      print(value);
                    }),
              ),
              IconButton(
                onPressed: () async {
                  var place =
                      await LocationService().getPlace(_searchController.text);
                  _goToPlace(place);
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: {_kGoogleOriginMarker, _kGoogleStadiumMarker},
              // polylines: {
              //   _kPolyline,
              //   },
              // polygons: {
              //   _kPolygon,
              // },
              initialCameraPosition: _kOrigin,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
            ),
          ),
        ],
      ),
      // floatingActionButton: FloatingActionButton.extended(
      //   onPressed: _goToTheLake,
      //   label: const Text('To the Bravos Stadium!'),
      //   icon: const Icon(Icons.directions_boat),
      // ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    CameraPosition kPlaceCameraPosition = CameraPosition(
        // bearing: 192.8334901395799,
        target: LatLng(lat, lng),
        // tilt: 59.440717697143555,
        zoom: 12);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      kPlaceCameraPosition,
    ));
  }
}
