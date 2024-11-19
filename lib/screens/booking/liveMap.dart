import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/login.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;


class LiveLocationMap extends StatefulWidget {
  final String destination;
  final String id;
  final String from;
  final String type;
  const LiveLocationMap({super.key, required this.destination, required this.id, required this.from ,required this.type});

  @override
  _LiveLocationMapState createState() => _LiveLocationMapState();
}

class _LiveLocationMapState extends State<LiveLocationMap> {
  late GoogleMapController _mapController;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  final UserData _user = UserData();
  final List<LatLng> _polylineCoordinates = [];
  final Set<Marker> _markers = {};
  LatLng? _destinationPosition;
  LatLng? _startPosition;
  Timer? _timer;
  BitmapDescriptor? _carIcon;
  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    _setCustomMarkerIcon();
    connectToSocket();
    // _timer = Timer.periodic(const Duration(seconds: 5), (timer) {
    //   _updateLocation();
    // });
    // _showDestinationOnMap(widget.destination);
    // _showStartOnMap(widget.from);

    _setCoordinates();
  }


  void connectToSocket()async{

    if(_socket !=null){
      return;
    }

    _socket = IO.io("https://member.osat.in", {
      "transports": ["websocket"],
      "autoConnect": false,
    });

    _socket!.connect();


    _socket!.onConnect((_) {
      print("connected");
      print(_socket!.connected);

      _socket!.emit("SetLiveLocation",widget.id+widget.type.toUpperCase()+"LIVE");
      print("listening on ${widget.id+widget.type.toUpperCase()+"LIVE"}");

    });

    _socket!.on(widget.id+widget.type.toUpperCase()+"LIVE", (data){
      print(data);
      print("here");
      _updateLocation(lng: data["lng"],lat: data["lat"]);

    });

  }

  @override
  void dispose() {
    _timer?.cancel();
    _socket!.dispose();
    super.dispose();
  }

  void _setCoordinates() {
    // Split the destination and start coordinates strings into LatLng
    final destinationCoords = widget.destination.split(',');
    final fromCoords = widget.from.split(',');

    _destinationPosition = LatLng(
      double.parse(destinationCoords[0].trim()),
      double.parse(destinationCoords[1].trim()),
    );

    _startPosition = LatLng(
      double.parse(fromCoords[0].trim()),
      double.parse(fromCoords[1].trim()),
    );

    // Add markers on the map for the start and destination positions
    _markers.add(Marker(
      markerId: MarkerId('start'),
      position: _startPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
    ));

    _markers.add(Marker(
      markerId: MarkerId('destination'),
      position: _destinationPosition!,
      icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
    ));

    _drawPath();



    setState(() {});
  }




  Future<void> _setCustomMarkerIcon() async {
    print("type------");
    print(widget.type);
    _carIcon = await BitmapDescriptor.asset(
      const ImageConfiguration(size: Size(48, 48)),
      widget.type=="Taxi"?'assets/car_icon.png':'assets/bikePin.png',
    );
  }

  Future<LatLng> _getCurrentLatLng() async {
    try {
      Uri url = Uri.https(
        dotenv.env['DOMAIN']!,
        "/api/user/TaxiDriverLocation",
        {"driver_id": widget.id},
      );
      final token = _user.get("token").trim();
      http.Response response = await http.post(url, headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      });
      var res = jsonDecode(response.body);
      return LatLng(double.parse(res["latitude"]), double.parse(res["longitude"]));
    } catch (e) {
      return LatLng(0.0, 0.0);
    }
  }

  Future<void> _updateLocation({lat, lng}) async {
     // LatLng position = await _getCurrentLatLng();
     LatLng position = LatLng(lat, lng);
    if (mounted) {
      setState(() {
        print("object====$position");
        _currentPosition = position;
        _showCarLocationOnMap(_currentPosition);
        _drawPath();
      });
    }else{
      print("object====$position");
    }
  }

  void _showCarLocationOnMap(LatLng position) {
    _mapController.animateCamera(CameraUpdate.newLatLngZoom(position, 16));

    setState(() {
      _currentPosition = position;
      _markers.removeWhere((m) => m.markerId.value == 'currentLocation');
      _markers.add(
        Marker(
          markerId: MarkerId('currentLocation'),
          position: _currentPosition,
          icon: _carIcon ?? BitmapDescriptor.defaultMarker,
        ),
      );
    });
  }

  // Future<void> _showDestinationOnMap(LatLng destination) async {
  //   setState(() {
  //     _destinationPosition = destination;
  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId('destinationLocation'),
  //         position: _destinationPosition!,
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
  //       ),
  //     );
  //     _drawPath();
  //   });
  //   _mapController.animateCamera(CameraUpdate.newLatLng(_destinationPosition!));
  // }
  //
  // Future<void> _showStartOnMap(LatLng start) async {
  //   setState(() {
  //     _startPosition = start;
  //     _markers.add(
  //       Marker(
  //         markerId: MarkerId('startLocation'),
  //         position: _startPosition!,
  //         icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
  //       ),
  //     );
  //     _drawPath();
  //   });
  //   _mapController.animateCamera(CameraUpdate.newLatLng(_startPosition!));
  // }

  Future<void> _drawPath() async {
    if (_destinationPosition == null) return;

    final String apiKey = dotenv.env['GOOGLE_MAPS_API_KEY']!;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${_startPosition!.latitude},${_startPosition!.longitude}&destination=${_destinationPosition!.latitude},${_destinationPosition!.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));
    if (response.statusCode == 200) {
      final Map<String, dynamic> data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final String polyline = data['routes'][0]['overview_polyline']['points'];
        setState(() {
          _polylineCoordinates.clear();
          _polylineCoordinates.addAll(_decodePolyline(polyline));
        });
      }
    }
  }

  List<LatLng> _decodePolyline(String polyline) {
    List<LatLng> points = [];
    int index = 0, len = polyline.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = polyline.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      points.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return points;
  }

  @override
  Widget build(BuildContext context) {
    try {
      return Scaffold(
        body: GoogleMap(
          initialCameraPosition: CameraPosition(
            target: _currentPosition,
            zoom: 14.0,
          ),
          onMapCreated: (GoogleMapController controller) {
            _mapController = controller;
            _mapController.animateCamera(CameraUpdate.newLatLngZoom(_startPosition!, 16));
          },
          markers: _markers,
          polylines: Set<Polyline>.of(
            <Polyline>[
              Polyline(
                polylineId: PolylineId('path'),
                points: _polylineCoordinates,
                color: Colors.green,
                width: 5,
              ),
            ],
          ),
          style: '''[
  {
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2b2b2b"
      }
    ]
  },
  {
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#a0c391"
      }
    ]
  },
  {
    "elementType": "labels.text.stroke",
    "stylers": [
      {
        "color": "#1f1f1f"
      }
    ]
  },
  {
    "featureType": "administrative.country",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "administrative.land_parcel",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6a6a6a"
      }
    ]
  },
  {
    "featureType": "administrative.province",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#4e4e4e"
      }
    ]
  },
  {
    "featureType": "landscape.man_made",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#383838"
      }
    ]
  },
  {
    "featureType": "landscape.natural",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#3c3f3a"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#4c5333"
      }
    ]
  },
  {
    "featureType": "poi",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#9db37b"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#26571f"
      }
    ]
  },
  {
    "featureType": "poi.park",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6ab00d"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#454545"
      }
    ]
  },
  {
    "featureType": "road",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#a1a1a1"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#5b5b5b"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "geometry.stroke",
    "stylers": [
      {
        "color": "#3e3e3e"
      }
    ]
  },
  {
    "featureType": "road.highway",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#c5d29a"
      }
    ]
  },
  {
    "featureType": "transit",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#8aa462"
      }
    ]
  },
  {
    "featureType": "transit.line",
    "elementType": "geometry.fill",
    "stylers": [
      {
        "color": "#525d45"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "geometry",
    "stylers": [
      {
        "color": "#2a2e2a"
      }
    ]
  },
  {
    "featureType": "water",
    "elementType": "labels.text.fill",
    "stylers": [
      {
        "color": "#6e7d67"
      }
    ]
  }
]

''',
        ),
      );
    } catch (e) {
      return ErrorPage();
    }
  }
}
