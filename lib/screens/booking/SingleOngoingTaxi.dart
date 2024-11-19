
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/login.dart';
import 'package:http/http.dart'as http;


class SingleOngoingTaxi extends StatefulWidget {
  final String type;
  final String id;
  const SingleOngoingTaxi({super.key,required this.type,required this.id});

  @override
  State<SingleOngoingTaxi> createState() => _SingleOngoingTaxiState();
}

class _SingleOngoingTaxiState extends State<SingleOngoingTaxi> {



  final UserData _data=UserData();

  Timer? _timer;

  var data;
  var priceData;

  bool loaded=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    fetchData();
  }


  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    if(_timer!=null){
      _timer?.cancel();
    }
  }


  void fetchData()async{

    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/SingleOngoingTaxiBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );


    switch (widget.type) {
      case "Taxi":
        url=Uri.https(
            dotenv.env["DOMAIN"]!,
            "api/user/SingleOngoingTaxiBooking",
            {
              "user_id":_data.get("id").toString(),
              "booking_id":widget.id.toString()
            }
        );
        break;
      case "Truck":
        url=Uri.https(
            dotenv.env["DOMAIN"]!,
            "api/user/SingleOngoingTaxiBooking",
            {
              "user_id":_data.get("id").toString(),
              "booking_id":widget.id.toString()
            }
        );
        break;
    }


    String token=_data.get("token");

    setState(() {
      loaded=false;
    });


    try {
      http.Response response=await http.post(url,
          headers: {
            HttpHeaders.authorizationHeader:"Bearer $token"
          }
      );

      if (response.statusCode == 200) {

        data = jsonDecode( response.body);

        debugPrint(data);

        if(data["message"]!="success"){
          _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }


    if(mounted){
      setState(() {
        loaded=true;
      });
    }

  }


  void _showAlertDialog(BuildContext context, String title, String message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(title),
          content: Text(message),
          actions: <Widget>[
            TextButton(
              child:const Text('OK'),
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
          title: Text("Booking Details",
          ),
          centerTitle: true,
          forceMaterialTransparency: true,
          backgroundColor:const Color(0xffF6F6F6),
        ),
        body:loaded? SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [

                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border(
                      left: BorderSide(
                        color: Colors.black,
                        width: 3,
                      ),
                    ),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Row(
                              children: [
                                const SizedBox(
                                  width: 8,
                                ),
                                const Text(
                                  "Date ",
                                  style: TextStyle(color: Colors.grey),
                                ),
                                Text(
                                  data["ongoingTaxi"]["date"].toString(),
                                  style: const TextStyle(fontWeight: FontWeight.bold),
                                ),
                              ],
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            color: Colors.black,
                            child: Text(
                              data["ongoingTaxi"]["time"].toString(),
                              style: const TextStyle(color: Colors.white,
                                  fontWeight: FontWeight.bold
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  children: [
                                    const Icon(Icons.location_on),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width/1.8,
                                          child: Text(data["ongoingTaxi"]["city"].toString()+", "+data["ongoingTaxi"]["state"].toString(),
                                            style:const  TextStyle(
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width/1.8,
                                          child: Text(data["ongoingTaxi"]["from"].toString(),
                                            style:const  TextStyle(
                                                color: Colors.grey,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const Padding(
                                  padding: EdgeInsets.all(8.0),
                                  child: Divider(),
                                ),
                                Row(
                                  children: [
                                    const Icon(
                                      Icons.radio_button_checked,
                                      color: Color(0xff7BDD0A),
                                    ),
                                    const SizedBox(width: 8),
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width/1.8,
                                          child: Text(data["ongoingTaxi"]["to_city"].toString()+", "+data["ongoingTaxi"]["to_state"].toString(),
                                            style:const  TextStyle(
                                                fontWeight: FontWeight.bold,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
                                        SizedBox(
                                          width: MediaQuery.sizeOf(context).width/1.8,
                                          child: Text(data["ongoingTaxi"]["to"].toString(),
                                            style:const  TextStyle(
                                                color: Colors.grey,
                                                overflow: TextOverflow.ellipsis
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(
                            width: 8,
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          const  Text(
                            "Car ",
                            style: TextStyle(color:Colors.grey),
                          ),
                          Text(
                            data["ongoingTaxi"]["car_name"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "₹ "+data["ongoingTaxi"]["avg_price"].toString(),
                            style: TextStyle(color: Colors.blue,fontWeight: FontWeight.bold,fontSize: 24),
                          ),
                          Text(
                            " /Person",
                            style: const TextStyle(color: Colors.grey),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          const SizedBox(
                            width: 8,
                          ),
                          Text(
                            "Booking No.",
                            style: TextStyle(color: Colors.grey),
                          ),
                          Text(
                            data["ongoingTaxi"]["bookingNo"].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      ),
                      const SizedBox(
                        height: 8,
                      ),
                    ],
                  ),
                ),
                SizedBox(
                  height: 16,
                ),
                Text("Driver Details",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
                SizedBox(
                  height: 16,
                ),


                Container(
                  padding: EdgeInsets.all(8),
                  color: Colors.white,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text("Driver Name ",style: TextStyle(color: Colors.grey),),
                          Text(data["ongoingTaxi"]["driver_name"].toString()),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Row(
                        children: [
                          Text("Phone No. ",style: TextStyle(color: Colors.grey),),
                          Text(data["ongoingTaxi"]["driver_phone"].toString()),
                        ],
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      Text("Compony Name",style: TextStyle(color: Colors.grey),),
                      Text(data["ongoingTaxi"]["company_name"].toString(),
                        style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                    ],
                  ),
                )

              ],
            ),
          ),
        ):
        const Center(
          child: CircularProgressIndicator(),
        )
        ,
      );
    }catch(e){
      return ErrorPage();
    }
  }
}
