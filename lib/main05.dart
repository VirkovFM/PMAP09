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
  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final List<LatLng> _polygonLatLngs = <LatLng>[];
  int _polygonIdCounter = 1;
  static const CameraPosition _kOrigin = CameraPosition(
    target: LatLng(21.15774731319369, -101.70571275200567),
    zoom: 12.4746,
  );
  @override
  void initState() {
    super.initState();
    _setMarker(const LatLng(21.15774731319369, -101.70571275200567));
  }

  void _setMarker(LatLng point) {
    setState(() {
      _markers.add(
        Marker(markerId: const MarkerId('marker'), position: point),
      );
    });
  }

  void _setPolygon() {
    final String polygonIdVal = 'polygon_$_polygonIdCounter';
    _polygonIdCounter++;
    _polygons.add(Polygon(
      polygonId: PolygonId(polygonIdVal),
      points: _polygonLatLngs,
      strokeWidth: 2,
      fillColor: Colors.transparent,
    ));
  }

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
              markers: _markers,
              polygons: _polygons,
              initialCameraPosition: _kOrigin,
              onMapCreated: (GoogleMapController controller) {
                _controller.complete(controller);
              },
              onTap: (point) {
                setState(() {
                  _polygonLatLngs.add(point);
                  _setPolygon();
                });
              },
            ),
          ),
        ],
      ),
    );
  }

  Future<void> _goToPlace(Map<String, dynamic> place) async {
    final double lat = place['geometry']['location']['lat'];
    final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    CameraPosition kPlaceCameraPosition =
        CameraPosition(target: LatLng(lat, lng), zoom: 12);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      kPlaceCameraPosition,
    ));
    _setMarker(LatLng(lat, lng));
  }
}
