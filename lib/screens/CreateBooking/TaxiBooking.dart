
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/SelectLocation.dart';
import 'package:http/http.dart'as http;
import 'package:osat/screens/login.dart';

class TaxiBooking extends StatefulWidget {
  const TaxiBooking({super.key});

  @override
  State<TaxiBooking> createState() => _TaxiBookingState();
}

class _TaxiBookingState extends State<TaxiBooking> {

  int selected=1;

  DateTime _leavingDate=DateTime.now();

  final UserData _user=UserData();

  late DateTime _arrivingDate;

  String fromLocation="From";
  String toLocation="To";

  bool loading=true;

  double? originLat;
  double? originLng;
  double? destLat;
  double? destLng;

  int _passangers=1;
  @override
  void initState() {

    super.initState();
    fetchNumber();
    _arrivingDate=_leavingDate;
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

    if(res["is_number_verified"].toString()!="TRUE"){
      // print(res["is_number_verified"].toString());
      // print(res.toString());
      GoRouter.of(context).pushReplacementNamed("PhoneNumberPage");
    }

    if(mounted){
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

  void _showDetailedLocationRequiredDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: 'Please enter more detailed '),
                TextSpan(
                  text: 'from',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'to',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' locations.'),
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



  void createBooking() async {
    
    if(fromLocation=="From" || toLocation=="To"){

      _showLocationRequiredDialog();

      return;
    }


    late Uri url;

   try{
     List<String> addressParts = fromLocation.split(',');

     // Trim whitespace from each part
     addressParts = addressParts.map((part) => part.trim()).toList();


     // debugPrint(addressParts);

     // Assign parts to variables
     String country = addressParts[addressParts.length - 1];
     String stateWithPostalCode = addressParts[addressParts.length - 2];
     String city = addressParts[addressParts.length - 3];

     // debugPrint(country);
     // debugPrint(stateWithPostalCode);
     // debugPrint(city);

     // Remove numbers from the state string
     String state = stateWithPostalCode.replaceAll(RegExp(r'\d'), '').trim();


     List<String> to_addressParts = toLocation.split(',');

     // Trim whitespace from each part
     to_addressParts = to_addressParts.map((part) => part.trim()).toList();

     //debugPrint(to_addressParts);

     // Assign parts to variables
     String to_country = to_addressParts[to_addressParts.length - 1];
     String to_stateWithPostalCode = to_addressParts[to_addressParts.length - 2];
     String to_city = to_addressParts[to_addressParts.length - 3];

     // debugPrint(to_country);
     // debugPrint(to_stateWithPostalCode);
     // debugPrint(to_city);

     // Remove numbers from the state string
     String to_state = to_stateWithPostalCode.replaceAll(RegExp(r'\d'), '').trim();



     // debugPrint({
     //   "userId": _user.get("id").toString(),
     //   "from": fromLocation,
     //   "to": toLocation,
     //   "date": "${_leavingDate.day}-${_leavingDate.month}-${_leavingDate.year}",
     //   "person": _passangers.toString(),
     //   "country": country,
     //   "state": state,
     //   "city": city,
     //   "to_country": to_country,
     //   "to_state": to_state,
     //   "to_city": to_city,
     //   "trip": selected == 1 ? "one_way" : "round_trip",
     //   "arriving_date":"${_arrivingDate.day}-${_arrivingDate.month}-${_arrivingDate.year}"
     // }.toString());


     url = Uri.https(
       dotenv.env['DOMAIN']!,
       "/api/user/bookTaxiBooking",
       {
         "userId": _user.get("id").toString(),
         "from": fromLocation,
         "to": toLocation,
         "date": "${_leavingDate.day}-${_leavingDate.month}-${_leavingDate.year}",
         "person": _passangers.toString(),
         "country": country,
         "state": state==""? city: state,
         "city": city,
         "to_country": to_country,
         "to_state": to_state==""? to_city:to_state,
         "to_city": to_city,
         "trip": selected == 1 ? "one_way" : "round_trip",
         "arriving_date":"${_arrivingDate.day}-${_arrivingDate.month}-${_arrivingDate.year}",
         "from_location":"$originLat, $originLng" ,
         "to_location":"$destLat, $destLng"
       },
     );
   }
   catch(e){

     // debugPrint(e);

     _showDetailedLocationRequiredDialog();

     return;

   }
    setState((){
      loading=false;
    });





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
      var data = jsonDecode(response.body);
      print(data.toString());
      if(data["message"]=="success"){

        GoRouter.of(context).pushReplacementNamed("Success",
          pathParameters: {
            "id":data["booking_id"].toString(),
            "no":data["booking_number"].toString(),
            "type":"taxi",
          }
        );
      }else{

        GoRouter.of(context).pushNamed("Failed");
      }
    } else {
      debugPrint(response.body);
      _showSomethingWentWrongDialog();
    }
  }

  String formatDate(DateTime date) {
    // Weekday names
    List<String> weekdays = ['Monday', 'Tuesday', 'Wednesday', 'Thursday', 'Friday', 'Saturday', 'Sunday'];
    // Month names
    // List<String> months = [
    //   'January', 'February', 'March', 'April', 'May', 'June', 'July', 'August', 'September', 'October', 'November', 'December'
    // ];

    // Get the weekday name
    String weekday = weekdays[date.weekday - 1];
    // Get the day of the month
    String day = date.day.toString();
    // Get the year
    String year = date.year.toString();

    // Concatenate the parts into the desired format
    return '$weekday, $day, $year';
  }

  @override
  Widget build(BuildContext context) {
    DateTime currentDate = DateTime.now();
    DateTime lastDate = DateTime(currentDate.year, currentDate.month + 1, currentDate.day);

    return Scaffold(
      appBar: AppBar(
        title: Text("Create Booking"),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  const Text("Book Taxi",
                    style: TextStyle(
                      fontSize: 20
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    height: 30,
                      child: Image.asset("assets/taxi.png")
                  ),
                ],
              ),
              const Text("Get compare rates on booking",
                style: TextStyle(
                  fontSize: 10
                ),
              ),
              const SizedBox(
                height: 40,
              ),
             //  Text("From",
             //    style: TextStyle(
             //      fontWeight: FontWeight.bold,
             //    ),
             //  ),
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
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(vertical: 16.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [

                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selected=1;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(100),
                                border: Border.all(
                                  width: 0.5,
                                )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(selected==1?Icons.check_circle:Icons.circle,color: Colors.black,),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      'One Way',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: (){
                              setState(() {
                                selected=2;
                              });
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(100),
                                  border: Border.all(
                                      width: 0.5
                                  )
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 16),
                                child: Row(
                                  children: [
                                    Icon(selected==2?Icons.check_circle:Icons.circle, color: Colors.black,),
                                    const SizedBox(
                                      width: 8,
                                    ),
                                    const Text(
                                      'Round Trip',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                    const Divider(),
                    Padding(
                      padding:const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                         const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("LEAVING",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("Pick a date",
                                style: TextStyle(
                                  fontSize: 10,
                                  color: Colors.grey
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              Text(formatDate(_leavingDate),
                                style:const TextStyle(
                                  fontWeight: FontWeight.bold
                                ),
                              ),
                              IconButton(
                                  onPressed: (){
                                    showDatePicker(context: context, firstDate: currentDate, lastDate: lastDate).then((value) =>
                                      {
                                        if(value!=null){
                                          setState(() {
                                            _leavingDate=value;
                                            if(_leavingDate.isAfter(_arrivingDate)){
                                              _arrivingDate=_leavingDate;
                                            }
                                          })
                                        }
                                      }
                                    );
                                  },
                                  icon: const Icon(Icons.calendar_today_outlined,),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    const Divider(),
                    selected==2?
                    Column(
                      children: [
                        Padding(
                          padding:const EdgeInsets.all(12.0),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              const Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text("ARRIVING",
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                  Text("Pick a date",
                                    style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.grey
                                    ),
                                  )
                                ],
                              ),
                              Row(
                                children: [
                                  Text(formatDate(_arrivingDate),
                                    style:const TextStyle(
                                        fontWeight: FontWeight.bold
                                    ),
                                  ),
                                  IconButton(
                                    onPressed: (){
                                      showDatePicker(context: context, firstDate: _leavingDate, lastDate: DateTime(_leavingDate.year, _leavingDate.month + 1, _leavingDate.day)).then((value) =>
                                          {
                                            if(value!=null){
                                              setState(() {
                                                _arrivingDate=value;
                                              })
                                            }
                                          }
                                      );
                                    },
                                    icon: const Icon(Icons.calendar_today_outlined,),
                                  )
                                ],
                              )
                            ],
                          ),
                        ),
                        const Divider(),
                        Text("${_arrivingDate.difference(_leavingDate).inDays +1} DAY${_leavingDate.difference(_arrivingDate).inDays != 0 ? 'S' : ''} TRIP",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.grey,
                            fontSize: 18,
                          ),
                        )

                      ],
                    )
                        :
                        const SizedBox(),

                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("PASSANGERS",
                                style: TextStyle(
                                    fontWeight: FontWeight.bold
                                ),
                              ),
                              Text("How many travelers?",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey
                                ),
                              )
                            ],
                          ),

                          Column(
                            children: [
                              Row(
                                children: [
                                  GestureDetector(
                                    onTap: (){
                                      if(_passangers>1){
                                        setState(() {
                                          _passangers--;
                                        });
                                      }
                                    },
                                      child: Icon(Icons.arrow_left,
                                      size: 34,
                                      color: _passangers==1?Colors.grey:Colors.black,
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  Text("$_passangers",
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 24
                                    ),
                                  ),
                                  const SizedBox(
                                    width: 8,
                                  ),
                                  GestureDetector(
                                    onTap: (){
                                      if(_passangers<7){
                                        setState(() {
                                          _passangers++;
                                        });
                                      }
                                    },
                                    child: Icon(Icons.arrow_right,
                                      size: 34,
                                      color: _passangers==7?Colors.grey:Colors.black,
                                    ),
                                  )
                                ],
                              ),
                              const Text("Maximum 7",
                                style: TextStyle(
                                  fontSize: 8,
                                  color: Colors.grey
                                ),
                              )
                            ],
                          )
                        ],
                      ),
                    )
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: GestureDetector(
                  onTap: loading? createBooking:null,
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.black,
                    ),
                    child:  Padding(
                      padding:const  EdgeInsets.all(8.0),
                      child: Center(
                        child:loading? const Text("Lets Go",
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
