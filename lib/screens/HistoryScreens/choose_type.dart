
import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart'as http;
import 'package:osat/screens/ErrorPage.dart';

class ChooseType extends StatefulWidget {
  const  ChooseType({super.key});

  @override
  State<ChooseType> createState() => _ChooseTypeState();
}

class _ChooseTypeState extends State<ChooseType> {




  bool _loading=false;

  var data;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }

  void fetchData()async{
    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/AvailableTransport",
    );

    setState(() {
      _loading=false;
    });

    http.Response response=await http.get(url);
    if(response.statusCode==200){
      data=jsonDecode(response.body);
      //debugPrint(data);

    }else{
      //debugPrint(response.statusCode);
      _showSomethingWentWrongDialog();
    }
    if(mounted){
      setState(() {
        _loading=true;
      });
    }
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
  @override
  Widget build(BuildContext context) {
    try{
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "OSAT",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.white,
          forceMaterialTransparency: true,
        ),
        body:_loading?SingleChildScrollView(
          child: Column(
            children: [
              Row(
                children: [
                  data["Taxi"]=="true"?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        GoRouter.of(context).pushNamed("History",
                            pathParameters: {
                              "bookingType":"AllTaxiBooking",
                              "type":"Taxi"
                            }
                        );
                      },
                      child: Container(
                        width: (MediaQuery.sizeOf(context).width/2)-16,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 4,
                                    color: Color(0xff7BDD0A)
                                )
                            )
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                width: MediaQuery.sizeOf(context).width/4,
                                height: MediaQuery.sizeOf(context).width/4,
                                child: Image.asset("assets/taxi.png")
                            ),
                            const Text("Taxi Booking Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):const SizedBox(),
                  data["Truck"]=="true"?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        GoRouter.of(context).pushNamed("History",
                            pathParameters: {
                              "bookingType":"AllTransportBooking",
                              "type":"Truck"
                            }
                        );
                      },
                      child: Container(
                        width: (MediaQuery.sizeOf(context).width/2)-16,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 4,
                                    color: Color(0xff7BDD0A)
                                )
                            )
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                width: MediaQuery.sizeOf(context).width/4,
                                height: MediaQuery.sizeOf(context).width/4,
                                child: Image.asset("assets/truck.png")
                            ),
                            const Text("Truck Booking Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):const SizedBox(),
                ],
              ),
              Row(
                children: [
                  data["Bike"]=="true"?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        GoRouter.of(context).pushNamed("History",
                            pathParameters: {
                              "bookingType":"AllBikeBooking",
                              "type":"Bike"
                            }
                        );
                      },
                      child: Container(
                        width: (MediaQuery.sizeOf(context).width/2)-16,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 4,
                                    color: Color(0xff7BDD0A)
                                )
                            )
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                width: MediaQuery.sizeOf(context).width/4,
                                height: MediaQuery.sizeOf(context).width/4,
                                child: Image.asset("assets/bike.png")
                            ),
                            const Text("Bike Booking Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):const SizedBox(),
                  data["Auto"]=="true"?Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: GestureDetector(
                      onTap: (){
                        GoRouter.of(context).pushNamed("History",
                            pathParameters: {
                              "bookingType":"AllAutoBooking",
                              "type":"Auto"
                            }
                        );
                      },
                      child: Container(
                        width: (MediaQuery.sizeOf(context).width/2)-16,
                        decoration: const BoxDecoration(
                            color: Colors.white,
                            border: Border(
                                bottom: BorderSide(
                                    width: 4,
                                    color: Color(0xff7BDD0A)
                                )
                            )
                        ),
                        child: Column(
                          children: [
                            SizedBox(
                                width: MediaQuery.sizeOf(context).width/4,
                                height: MediaQuery.sizeOf(context).width/4,
                                child: Image.asset("assets/rikshaw.png")
                            ),
                            const Text("Auto Booking Details",
                              style: TextStyle(
                                  fontWeight: FontWeight.w500
                              ),
                            ),
                            const SizedBox(
                              height: 10,
                            ),
                          ],
                        ),
                      ),
                    ),
                  ):const SizedBox(),
                ],
              ),
              if(kDebugMode)
                Column(
                  children: [
                    SizedBox(
                      height: 20,
                    ),
                    const Text("Debug transports (this panel only show in debug mode.)"),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: (){
                              GoRouter.of(context).pushNamed("History",
                                  pathParameters: {
                                    "bookingType":"AllTaxiBooking",
                                    "type":"Taxi"
                                  }
                              );
                            },
                            child: Container(
                              width: (MediaQuery.sizeOf(context).width/2)-16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 4,
                                          color: Color(0xff7BDD0A)
                                      )
                                  )
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context).width/4,
                                      height: MediaQuery.sizeOf(context).width/4,
                                      child: Image.asset("assets/taxi.png")
                                  ),
                                  const Text("Taxi Booking Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: (){
                              GoRouter.of(context).pushNamed("History",
                                  pathParameters: {
                                    "bookingType":"AllTransportBooking",
                                    "type":"Truck"
                                  }
                              );
                            },
                            child: Container(
                              width: (MediaQuery.sizeOf(context).width/2)-16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 4,
                                          color: Color(0xff7BDD0A)
                                      )
                                  )
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context).width/4,
                                      height: MediaQuery.sizeOf(context).width/4,
                                      child: Image.asset("assets/truck.png")
                                  ),
                                  const Text("Truck Booking Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: (){
                              GoRouter.of(context).pushNamed("History",
                                  pathParameters: {
                                    "bookingType":"AllBikeBooking",
                                    "type":"Bike"
                                  }
                              );
                            },
                            child: Container(
                              width: (MediaQuery.sizeOf(context).width/2)-16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 4,
                                          color: Color(0xff7BDD0A)
                                      )
                                  )
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context).width/4,
                                      height: MediaQuery.sizeOf(context).width/4,
                                      child: Image.asset("assets/bike.png")
                                  ),
                                  const Text("Bike Booking Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: GestureDetector(
                            onTap: (){
                              GoRouter.of(context).pushNamed("History",
                                  pathParameters: {
                                    "bookingType":"AllAutoBooking",
                                    "type":"Auto"
                                  }
                              );
                            },
                            child: Container(
                              width: (MediaQuery.sizeOf(context).width/2)-16,
                              decoration: const BoxDecoration(
                                  color: Colors.white,
                                  border: Border(
                                      bottom: BorderSide(
                                          width: 4,
                                          color: Color(0xff7BDD0A)
                                      )
                                  )
                              ),
                              child: Column(
                                children: [
                                  SizedBox(
                                      width: MediaQuery.sizeOf(context).width/4,
                                      height: MediaQuery.sizeOf(context).width/4,
                                      child: Image.asset("assets/rikshaw.png")
                                  ),
                                  const Text("Auto Booking Details",
                                    style: TextStyle(
                                        fontWeight: FontWeight.w500
                                    ),
                                  ),
                                  const SizedBox(
                                    height: 10,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                )
            ],
          ),
        ):const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }catch(e){
      return ErrorPage();
    }


  }
}
