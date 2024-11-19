import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/SelectLocation.dart';
import 'package:http/http.dart'as http;
import 'package:osat/screens/login.dart';

class BikeBooking extends StatefulWidget {
  const BikeBooking({super.key});

  @override
  State<BikeBooking> createState() => _BikeBookingState();
}

class _BikeBookingState extends State<BikeBooking> {
  String toLocation="To";
  String fromLocation="From";


  double? originLat;
  double? originLng;
  double? destLat;
  double? destLng;

  final UserData _user=UserData();

  final DateTime _leavingDate=DateTime.now();

  bool loading=true;

  double? estimatedPrice;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchNumber();
  }


  void fetchNumber()async{
    setState(() {
      loading=false;
    });
    final url = Uri.https(
        dotenv.env['DOMAIN']!,
        "/api/user/checkUserPhone",
        {
          "user_id":_user.get("id").toString(),
        }
    );
    final token = _user.get("token").trim();


    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    var res=jsonDecode(response.body);
    // debugPrint(res);

    if(res["message"]!="success"){
      GoRouter.of(context).pushReplacementNamed("PhoneNumberPage");
    }

    if(mounted){
      await fetchEstimatedPrice();
      setState((){
        loading=true;
      });
    }




  }


  void _showLocationRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: 'Please enter your '),
                TextSpan(
                  text: 'from',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'to',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' locations. 😊 We need this information to plan your trip and provide the best possible experience! 🌟'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }


  void _showSomethingWentWrongDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: '⚠️ Oops! Something went wrong. 😔 Please try again later.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showBookingCantCreateDialog(String reason) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: 'Booking can\'t be created',style: TextStyle(fontWeight: FontWeight.bold)),
                TextSpan(text: reason),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }




  Future<double> calculateDistance(double originLat, double originLng, double destLat, double destLng, String apiKey) async {
    String apiUrl = "https://maps.googleapis.com/maps/api/distancematrix/json";
    String url = "$apiUrl?units=metric&origins=$originLat,$originLng&destinations=$destLat,$destLng&key=$apiKey";

    try {
      debugPrint("Requesting URL: $url");
      var response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        var data = json.decode(response.body);

        if (data["status"] == "OK") {
          // Extract distance from the response
          String distanceText = data["rows"][0]["elements"][0]["distance"]["text"];
          debugPrint("Raw distance text: $distanceText");

          // Convert the distance text to a double value in kilometers
          double distance = _parseDistance(distanceText);

          debugPrint("Parsed distance in km: $distance");
          return distance;
        } else {
          throw Exception("API Error: ${data["status"]}");
        }
      } else {
        throw Exception("HTTP Error: ${response.statusCode}");
      }
    } catch (e) {
      throw Exception("Failed to calculate distance: $e");
    }
  }

  double _parseDistance(String distanceText) {
    // Handle different units in the distance text
    if (distanceText.contains("km")) {
      return double.parse(distanceText.split(" ")[0].replaceAll(',', '.'));
    } else if (distanceText.contains("miles")) {
      return double.parse(distanceText.split(" ")[0].replaceAll(',', '.')) * 1.60934; // Convert miles to kilometers
    } else if (distanceText.contains("m")) {
      return double.parse(distanceText.split(" ")[0].replaceAll(',', '.')) / 1000; // Convert meters to kilometers
    } else {
      throw Exception("Unexpected distance unit: $distanceText");
    }
  }




  Future<void> fetchEstimatedPrice() async {


    final url = Uri.https(
      dotenv.env['DOMAIN']!,
      "/api/user/GetEstimateRidePrice",
      {"text": "fromLocation"},
    );

    final token = _user.get("token").trim();

    try {
      final response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: 'Bearer $token',
        },
      );



      if (response.statusCode == 200) {
        var data = jsonDecode(response.body);
          estimatedPrice= double.parse(data["price"].toString());


      } else {
        throw Exception("Failed to get estimated price");
      }
    } catch (e) {


      _showSomethingWentWrongDialog();
      throw e;
    }
  }
  void _showEstimatedPriceBottomSheet(double estimatedPrice, double distance, String fromLocation, String toLocation) {
    double gstPrice = (estimatedPrice * distance)  * 0.18;
    double totalPrice = (estimatedPrice * distance) + gstPrice;

    showModalBottomSheet(
      context: context,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(15)),
      ),
      backgroundColor: Colors.white,
      isScrollControlled: true,
      builder: (BuildContext context) {
        return Padding(
          padding: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    "Estimated Ride Price",
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 20,
                    ),
                  ),
                ),
                SizedBox(height: 20),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "From ", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      TextSpan(text: fromLocation, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "To ", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      TextSpan(text: toLocation, style:TextStyle(fontWeight: FontWeight.bold, fontSize: 16) ),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Divider(),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Estimated Distance ", style:TextStyle(fontSize: 16, color: Colors.grey[600]) ),
                      TextSpan(text: "${distance.toStringAsFixed(2)} km", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Estimated Price ", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      TextSpan(text: "₹${(estimatedPrice * distance).toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "GST (18%) ", style: TextStyle(fontSize: 16, color: Colors.grey[600])),
                      TextSpan(text: "₹${gstPrice.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                    ],
                  ),
                ),
                SizedBox(height: 10),
                Divider(),
                SizedBox(height: 10),
                Text.rich(
                  TextSpan(
                    children: [
                      TextSpan(text: "Total Price ", style: TextStyle(fontSize: 18, color: Colors.grey[600])),
                      TextSpan(text: "₹${totalPrice.toStringAsFixed(2)}", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                    ],
                  ),
                ),
                SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      child: Text('Cancel', style: TextStyle(color: Colors.black)),
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                    ),
                    TextButton(
                      child: Text('Continue', style: TextStyle(color: Colors.white)),
                      style: TextButton.styleFrom(
                        backgroundColor: Colors.black,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                      ),
                      onPressed: () {
                        Navigator.of(context).pop();
                        createBooking(distance,totalPrice.toStringAsFixed(2)); // Proceed to book the bike
                      },
                    ),
                  ],
                ),
                SizedBox(height: 20),
              ],
            ),
          ),
        );
      },
    );
  }





  void createBooking(double distance,String price) async {

    if(fromLocation=="" || toLocation==""){

      _showLocationRequiredDialog();

      return;
    }
    // double distance=await calculateDistance(fromLocation,toLocation,"AIzaSyD4FmX9tgMknOk8Mmkb8ecBQH49TUFSdYw");
    List<String> addressParts = fromLocation.split(',');

    // Trim whitespace from each part
    addressParts = addressParts.map((part) => part.trim()).toList();

    // Assign parts to variables
    String country = addressParts[addressParts.length - 1];
    String stateWithPostalCode = addressParts[addressParts.length - 2];
    String city = addressParts[addressParts.length - 3];

    // Remove numbers from the state string
    String state = stateWithPostalCode.replaceAll(RegExp(r'\d'), '').trim();


    List<String> to_addressParts = fromLocation.split(',');

    // Trim whitespace from each part
    to_addressParts = to_addressParts.map((part) => part.trim()).toList();

    // Assign parts to variables
    String to_country = to_addressParts[addressParts.length - 1];
    String to_stateWithPostalCode = to_addressParts[addressParts.length - 2];
    String to_city = to_addressParts[addressParts.length - 3];

    // Remove numbers from the state string
    String to_state = to_stateWithPostalCode.replaceAll(RegExp(r'\d'), '').trim();

    setState((){
      loading=false;
    });

    final url = Uri.https(
      dotenv.env['DOMAIN']!,
      "/api/user/bookBikeBooking",
      {
        "user_id": _user.get("id").toString(),
        "from": fromLocation,
        "to": toLocation,
        "km":distance.toString(),
        "date": "${_leavingDate.day}-${_leavingDate.month}-${_leavingDate.year}",
        "price":price,
        "country": country,
        "state": state==""? city: state,
        "city": city,
        "to_country": to_country,
        "to_state": to_state==""? to_city:to_state,
        "to_city": to_city,
        "from_location":"$originLat, $originLng" ,
        "to_location":"$destLat, $destLng"
      },
    );


    debugPrint(url.toString());


    final token = _user.get("token").trim();


    final response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );


    setState((){
      loading=true;
    });
    if (response.statusCode == 200) {
      debugPrint(response.body);
      var data = jsonDecode(response.body);
      if(data["message"]=="success"){
        GoRouter.of(context).pushReplacementNamed("Success",
            pathParameters: {
              "id":data["booking_id"].toString(),
              "no":data["bookingNo"].toString(),
              "type":"Bike"
            }
        );
      }else if(data["message"]=="Already Have a Ride!"){
        _showBookingCantCreateDialog("\nYou already have a bike ride. if you want to create a new ride please cancel the existing ride.");
      }else{

        _showBookingCantCreateDialog("\nSomething unexpected happened.");

        // GoRouter.of(context).pushNamed("Failed");
      }
    } else {
      print(response.body);
      _showSomethingWentWrongDialog();
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xffF6F6F6),
      appBar: AppBar(
        backgroundColor: const Color(0xffF6F6F6),
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Center(
                child: SizedBox(
                  height: 80,
                  child: Image.asset("assets/logo.png")
                  ),
              ),
              const SizedBox(
                height: 80,
              ),
              Row(
                children: [
                  const Text("Book Bike",
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    height: 30,
                      child: Image.asset("assets/bike.png")
                  ),
                ],
              ),
              const SizedBox(
                height: 40,
              ),
              // Text("From",
              //   style: TextStyle(
              //     fontWeight: FontWeight.bold,
              //   ),
              // ),
              // Stack(
              //   alignment: Alignment.center,
              //   children: [
              //     Column(
              //       crossAxisAlignment: CrossAxisAlignment.start,
              //       children: [
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(10),
              //           child: TextField(
              //             decoration: InputDecoration(
              //               border: InputBorder.none,
              //               filled: true,
              //               fillColor: Colors.white,
              //             ),
              //           ),
              //         ),
              //         SizedBox(
              //           height: 10,
              //         ),
              //         Text("To",
              //           style: TextStyle(
              //             fontWeight: FontWeight.bold,
              //           ),
              //         ),
              //         ClipRRect(
              //           borderRadius: BorderRadius.circular(10),
              //           child:const TextField(
              //             decoration: InputDecoration(
              //               border: InputBorder.none,
              //               filled: true,
              //               fillColor: Colors.white,
              //             ),
              //           ),
              //         ),
              //       ],
              //     ),
              //     Container(
              //       height: 50,
              //       width: 50,
              //       decoration: BoxDecoration(
              //         color: Colors.black,
              //         borderRadius: BorderRadius.circular(100),
              //       ),
              //       child: Center(child:
              //       Transform.rotate(
              //           angle: 90 * 3.1415926535 / 180, // Convert 90 degrees to radians
              //           child: const Icon(Icons.sync_alt_rounded,color: Colors.white,)
              //       )
              //       ),
              //     ),
              //   ],
              // ),
              Container(
                color: Colors.white,
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=>SelectLocation(setLocation: (String value, double? lat,double? lng){
                            setState(() {
                              fromLocation=value;
                              originLat=lat;
                              originLng=lng;
                            });

                          }))
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.location_on),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              fromLocation,
                              style:const  TextStyle(
                                fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(
                        width: MediaQuery.sizeOf(context).width/1.5,
                        child: const Divider()
                    ),
                    GestureDetector(
                      onTap: (){
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (context)=>SelectLocation(setLocation: (String value, double? lat,double? lng){
                            setState(() {
                              toLocation=value;
                              destLat =lat;
                              destLng=lng;
                            });

                          }))
                        );
                      },
                      child: Row(
                        children: [
                          const Icon(Icons.radio_button_checked,color: Color(0xff7BDD0A),),
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Text(
                              toLocation,
                              style:const  TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: GestureDetector(
                  onTap: loading? ()async{

                    if(fromLocation=="From" || toLocation=="To"){

                      _showLocationRequiredDialog();

                      return;
                    }

                    setState(() {
                      loading=false;
                    });

                    double distance = await calculateDistance( originLat!, originLng!,  destLat!,  destLng!, "AIzaSyD4FmX9tgMknOk8Mmkb8ecBQH49TUFSdYw");


                    setState(() {
                      loading=true;
                    });

                    if(distance<=0.5 || fromLocation == toLocation){
                      _showBookingCantCreateDialog("\nRide estimated distance should be more the 500m");
                     return;
                    }


                    _showEstimatedPriceBottomSheet(estimatedPrice!, distance,fromLocation,toLocation);


                  }:null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child:  Padding(
                      padding:const EdgeInsets.all(8.0),
                      child: Center(
                        child: loading? const Text("Lets Go",
                          style: TextStyle(
                              color: Colors.white,
                              fontSize: 24
                          ),
                        ):
                        const CircularProgressIndicator(
                          color:Colors.white ,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
