import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:permission_handler/permission_handler.dart';
import 'package:go_router/go_router.dart';

class SelectLocation extends StatefulWidget {
  final dynamic setLocation;

  const SelectLocation({super.key, required this.setLocation});

  @override
  State<SelectLocation> createState() => _SelectLocationState();
}

class _SelectLocationState extends State<SelectLocation> {
  late GoogleMapController _mapController;
  List<String> places = [];
  Map<String, String> placeIds = {};
  LatLng _latLng = const LatLng(0, 0); // Default value to avoid null issues
  LatLng? _selectedLocation;
  Set<Marker> _markers = {};
  String? address;
  double? lat;
  double? lng;

  Future<void> fetchPlaces(String value, VoidCallback callback) async {
    if (value.isEmpty) {
      setState(() {
        places = [];
        placeIds = {};
      });
      return;
    }

    Uri url = Uri.https(
      "maps.googleapis.com",
      "/maps/api/place/autocomplete/json",
      {
        "input": value,
        "key": dotenv.env["GOOGLE_MAPS_API_KEY"], // Replace with your actual API key
      },
    );
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var predictions = json['predictions'];



      setState(() {
        placeIds = {for (var p in predictions) p['description']: p['place_id']};
        places = List<String>.from(predictions.map((p) => p['description']));
      });

      debugPrint(places.toString());
      callback(); // Trigger a rebuild
    } else {
      setState(() {
        places = [];
        placeIds = {};
      });


      callback(); // Trigger a rebuild even on failure
    }
  }

  Future<void> fetchPlaceDetails(String? placeId) async {
    if (placeId == null) {
      return;
    }

   setState(() {
     address=null;
   });

    Uri url = Uri.https(
      "maps.googleapis.com",
      "/maps/api/place/details/json",
      {
        "place_id": placeId,
        "key": "AIzaSyD4FmX9tgMknOk8Mmkb8ecBQH49TUFSdYw",
      },
    );

    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);
      var location = json['result']['geometry']['location'];

      setState(() {
        _selectedLocation = LatLng(location['lat'], location['lng']);
        lat = location['lat'];  // Update lat
        lng = location['lng'];  // Update lng
        address = json['result']['formatted_address'];
        _markers = {
          Marker(
            markerId: MarkerId(placeId),
            position: _selectedLocation!,
            infoWindow: InfoWindow(title: address),
          ),
        };
      });
      _goToSelectedPlace();
    }
  }

  void _goToSelectedPlace() {
    if (_selectedLocation != null) {
      _mapController.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation!, 18),
      );
    }
  }

  Future<void> fetchAddressFromLatLng(LatLng latLng) async {
    lat = latLng.latitude;
    lng = latLng.longitude;

    Uri url = Uri.https(
      "maps.googleapis.com",
      "/maps/api/geocode/json",
      {
        "latlng": "${latLng.latitude},${latLng.longitude}",
        "key": "AIzaSyD4FmX9tgMknOk8Mmkb8ecBQH49TUFSdYw",
      },
    );
    http.Response response = await http.get(url);

    if (response.statusCode == 200) {
      var json = jsonDecode(response.body);

      if (json['results'].isNotEmpty) {
        var result = json['results'][0];
        address = result['formatted_address'];
        setState(() {
          _selectedLocation = latLng;
          _markers = {
            Marker(
              markerId: MarkerId("selected-location"),
              position: latLng,
              infoWindow: InfoWindow(title: address),
            ),
          };
          _goToSelectedPlace(); // Move map and set marker
        });
      }
    }
  }

  @override
  void initState() {
    super.initState();
    Permission.location.request().then((status) {
      if (status.isGranted) {
        _getUserLocation();
      }
    });
  }

  void _getUserLocation() async {
    setState(() {
      address =null;
    });
    var position;

    try{
      position = await Geolocator.getCurrentPosition(
          desiredAccuracy: LocationAccuracy.high);

      if (mounted) {
        setState(() {
          _latLng = LatLng(position.latitude, position.longitude);
        });

      }
    }catch(e){
      if (mounted) {
        setState(() {
          _latLng = LatLng( 28.644800, 77.216721);
        });

      }
    }




    await fetchAddressFromLatLng(_latLng);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff2b2b2b),
      body: SafeArea(
        child: Column(
          children: [
            Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                children: [
              Autocomplete<String>(
              optionsBuilder: (TextEditingValue textEditingValue) async {
                if (textEditingValue.text.isEmpty) {
                return const Iterable<String>.empty();
                }
                await fetchPlaces(textEditingValue.text, () {
                setState(() {}); // Trigger a rebuild
                });
                return places;
                },
                  onSelected: (String selection) async {
                    try {
                      await fetchPlaceDetails(placeIds[selection]!);
                    } catch (e) {
                      // Handle error
                    }
                  },
                  fieldViewBuilder: (
                      BuildContext context,
                      TextEditingController textEditingController,
                      FocusNode focusNode,
                      VoidCallback onFieldSubmitted,
                      ) {
                    return TextField(
                      controller: textEditingController,
                      focusNode: focusNode,

                      onChanged: (_){
                        setState(() {

                        });
                      },

                      decoration: const InputDecoration(
                        labelText: 'Enter location',
                        labelStyle: TextStyle(
                          color: Colors.white
                        )
                      ),
                      style: TextStyle(
                        color: Colors.white
                      ),

                    );
                  },
                  optionsViewBuilder: (
                      BuildContext context,
                      AutocompleteOnSelected<String> onSelected,
                      Iterable<String> options,
                      ) {
                    return Align(
                      alignment: Alignment.topLeft,
                      child: Material(
                        child: SizedBox(
                          height: 200,
                          child: ListView.builder(
                            itemCount: options.length,
                            itemBuilder: (BuildContext context, int index) {
                              final option = options.elementAt(index);
                              return ListTile(
                                title: Text(option),
                                onTap: () {
                                  onSelected(option);
                                },
                              );
                            },
                          ),
                        ),
                      ),
                    );
                  },
      )
                ],
              ),
            ),
            Expanded(
              child: Stack(
                children: [
                  GoogleMap(
                    initialCameraPosition:
                    CameraPosition(target: _latLng, zoom: 18),
                    markers: _markers,
                    onMapCreated: (GoogleMapController controller) {
                      _mapController = controller;
                    },
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
                    onTap: (latLng) {
                      fetchAddressFromLatLng(latLng);
                    },
                  ),
                  Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            onPressed: _getUserLocation,
                            child: const Row(
                              children: [
                                Icon(Icons.my_location, color: Color(0xff7BDD0A)),
                                SizedBox(
                                  width: 20,
                                ),
                                Text(
                                  "Current location",
                                  style: TextStyle(color: Color(0xff7BDD0A)),
                                )
                              ],
                            ),
                          ),
                        ],
                      ),


                      Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: address != null ?ElevatedButton(
                            style: ElevatedButton.styleFrom(
                                backgroundColor: Colors.black),
                            onPressed: () {
                              widget.setLocation(address!, lat, lng);
                              context.pop();
                            },
                            child: const Text(
                              "Confirm location",
                              style: TextStyle(color: Color(0xff7BDD0A)),
                            ))
                            :
                          CircularProgressIndicator(color: Colors.white,)
                        ,
                      ),
                    ],
                  )
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }



}
