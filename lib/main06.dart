import 'dart:async';
import 'package:flutter/material.dart';
import 'package:pmap09/location_service.dart';
import 'package:flutter_polyline_points/flutter_polyline_points.dart';
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
  final TextEditingController _originController = TextEditingController();
  final TextEditingController _destinationController = TextEditingController();
  final Set<Marker> _markers = <Marker>{};
  final Set<Polygon> _polygons = <Polygon>{};
  final Set<Polyline> _polylines = <Polyline>{};
  final List<LatLng> _polygonLatLngs = <LatLng>[];
  int _polygonIdCounter = 1;
  int _polylineIdCounter = 1;
  int _markerIdCounter = 1;
  static const CameraPosition _kOrigin = CameraPosition(
    target: LatLng(21.15774731319369, -101.70571275200567),
    zoom: 12.4746,
  );
  @override
  void initState() {
    super.initState();
    // _setMarker(const LatLng(21.15774731319369, -101.70571275200567), BitmapDescriptor.defaultMarker);
  }

  void _setMarker(LatLng point, BitmapDescriptor icon) {
    setState(() {
      final String markerIdVal = 'marker_$_markerIdCounter';
      _markerIdCounter++;
      _markers.add(
        Marker(
          markerId: MarkerId(markerIdVal),
          position: point,
          icon: icon,
        ),
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

  void _setPolyline(List<PointLatLng> points) {
    final String polylineIdVal = 'polyline_$_polylineIdCounter';
    _polylineIdCounter++;
    _polylines.add(
      Polyline(
        polylineId: PolylineId(polylineIdVal),
        width: 2,
        color: Colors.blue,
        points: points
            .map((point) => LatLng(point.latitude, point.longitude))
            .toList(),
      ),
    );
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
                child: Column(
                  children: [
                    TextFormField(
                        controller: _originController,
                        // textCapitalization: TextCapitalization.words,
                        decoration: const InputDecoration(hintText: ' Origin '),
                        onChanged: (value) {
                          print(value);
                        }),
                    TextFormField(
                        controller: _destinationController,
                        // textCapitalization: TextCapitalization.words,
                        decoration:
                            const InputDecoration(hintText: ' Destination'),
                        onChanged: (value) {
                          print(value);
                        }),
                  ],
                ),
              ),
              IconButton(
                onPressed: () async {
                  // var place = await LocationService().getPlace(_searchController.text);
                  // _goToPlace(place);
                  var directions = await LocationService().getDirections(
                      _originController.text, _destinationController.text);
                  _goToPlace(
                      directions['start_location']['lat'],
                      directions['start_location']['lng'],
                      directions['bounds_ne'],
                      directions['bounds_sw']);
                  _setPolyline(directions['polyline_decoded']);
                  _setMarker(
                      LatLng(directions['end_location']['lat'],
                          directions['end_location']['lng']),
                      BitmapDescriptor.defaultMarkerWithHue(
                          BitmapDescriptor.hueBlue));
                },
                icon: const Icon(Icons.search),
              ),
            ],
          ),
          // Row(
          //   children: [
          //     Expanded(child: TextFormField(
          //       controller: _searchController,
          //       // textCapitalization: TextCapitalization.words,
          //       decoration: const InputDecoration(hintText: 'Search by City'),
          //       onChanged: (value) {
          //         print(value);
          //       }
          //       ),
          //     ),
          //     IconButton(
          //       onPressed: () async {
          //         var place = await LocationService().getPlace(_searchController.text);
          //         _goToPlace(place);
          //       },
          //       icon: const Icon(Icons.search),
          //       ),
          //   ],
          // ),
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              markers: _markers,
              polygons: _polygons,
              polylines: _polylines,
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

  Future<void> _goToPlace(
    // Map<String, dynamic> place
    double lat,
    double lng,
    Map<String, dynamic> boundsNe,
    Map<String, dynamic> boundsSw,
  ) async {
    // final double lat = place['geometry']['location']['lat'];
    // final double lng = place['geometry']['location']['lng'];
    final GoogleMapController controller = await _controller.future;
    CameraPosition kPlaceCameraPosition =
        CameraPosition(target: LatLng(lat, lng), zoom: 12);
    controller.animateCamera(CameraUpdate.newCameraPosition(
      kPlaceCameraPosition,
    ));
    controller.animateCamera(CameraUpdate.newLatLngBounds(
        LatLngBounds(
            southwest: LatLng(boundsSw['lat'], boundsSw['lng']),
            northeast: LatLng(boundsNe['lat'], boundsNe['lng'])),
        25));
    _setMarker(LatLng(lat, lng), BitmapDescriptor.defaultMarker);
  }
}
