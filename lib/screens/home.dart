

import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/login.dart';
import 'package:http/http.dart'as http;

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> with RouteAware {
  // final List<String> _transports = <String>["Taxi", "Truck", "Bike", "Auto"];

  final UserData _userData=UserData();

  // bool _loading=true;

  var data;

  void refresh(){
    setState(() {

    });
  }

  final RouteObserver<PageRoute> routeObserver = RouteObserver<PageRoute>();

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
// Ensure the ModalRoute is a PageRoute
    final ModalRoute? modalRoute = ModalRoute.of(context);
    if (modalRoute is PageRoute) {
      routeObserver.subscribe(this, modalRoute);
    }
  }

  @override
  void dispose() {
    routeObserver.unsubscribe(this);
    super.dispose();
  }

  @override
  void didPopNext() {
    // This function is called when the user comes back to this screen.
    debugPrint('Back to HomeScreen!');
    _onBackFromNextScreen();
  }

  void _onBackFromNextScreen() {
    refresh();
  }



  
  Future<int> fetchData()async{
    debugPrint("called");
    Uri url=Uri.https(
      dotenv.env["DOMAIN"]!,
      "api/user/UserHome",
      {
        "user_id":_userData.get("id").toString(),
      }
    );
    final token = _userData.get("token").trim();

    //debugPrint(_userData.get("id").toString());

    // setState(() {
    //   _loading=true;
    // });

    http.Response response=await http.post(url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      }
    );
    if(response.statusCode==200){
      data=jsonDecode(response.body);
      debugPrint(data.toString());
    }else{
      //debugPrint(response.statusCode);
      _showSomethingWentWrongDialog();
      return 0;
    }
    // if(mounted){
    //   setState(() {
    //     _loading=false;
    //   });
    // }
    return 1;
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
    try {
      return FutureBuilder(
        future: fetchData(),
        builder: (context,snapshot){
          if(snapshot.hasError){
            return ErrorPage();
          }


          return Scaffold(
            backgroundColor: Colors.black,
            appBar: AppBar(
              centerTitle: true,
              title: const Text(
                "OSAT",
                style: TextStyle(
                    fontSize: 24,
                    fontWeight: FontWeight.bold,
                    color: Colors.white
                ),
              ),
              backgroundColor: Colors.black,
            ),
            body: Column(
              children: [
                const Expanded(
                    flex: 2,
                    child: Column(children: [
                      Text(
                        "Book Your Ride Today",
                        style: TextStyle(fontSize: 22, fontWeight: FontWeight.w900,color: Colors.white),
                      ),
                      Text(
                        "Find affordable RIDES for every budget",
                        style: TextStyle(
                            fontSize: 10,
                            color: Color(0xff7BDD0A)
                        ),
                      ),
                    ],)),
                // const SizedBox(
                //     height: 8),
                // ClipRRect(
                //   borderRadius: BorderRadius.circular(10),
                //   child: CarouselSlider(
                //     options: CarouselOptions(
                //       height: 120,
                //       viewportFraction: 1,
                //     ),
                //     items: [
                //       Padding(
                //         padding: const EdgeInsets.symmetric(horizontal: 8.0),
                //         child: Container(
                //           width: MediaQuery.of(context).size.width,
                //           decoration: BoxDecoration(
                //             color: Colors.yellow,
                //             borderRadius: BorderRadius.circular(10),
                //           ),
                //           // You can add child widgets here if needed
                //         ),
                //       )
                //     ],
                //   ),
                // ),
                Expanded(
                  flex: 8,
                  child:
                  Container(
                    decoration:const BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.only(topLeft: Radius.circular(20),topRight: Radius.circular(20))
                    ),
                    child:snapshot.connectionState == ConnectionState.waiting?
                    const Center(
                      child: CircularProgressIndicator(),
                    )
                        :SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.all(8.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const SizedBox(
                                height: 20),
                            Text(
                              "Hi,${_userData.get("name")}",
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            const SizedBox(
                                height:
                                8),
                            const Text(
                              "Select transport",
                              style: TextStyle(
                                fontSize: 12,
                              ),
                            ),
                            const SizedBox(height: 8),
                            // GridView.builder(
                            //   shrinkWrap:
                            //       true, // Ensure GridView takes only required space
                            //   physics:
                            //       const NeverScrollableScrollPhysics(), // Disable scrolling
                            //   gridDelegate:
                            //       const SliverGridDelegateWithMaxCrossAxisExtent(
                            //     maxCrossAxisExtent: 100, // Adjust as needed
                            //     mainAxisSpacing: 8, // Add spacing between grid items
                            //     crossAxisSpacing: 8,
                            //   ),
                            //   itemCount: _transports
                            //       .length, // Set the number of items in the grid
                            //   itemBuilder: (BuildContext context, int index) {
                            //     // You can customize each grid item here
                            //     return GestureDetector(
                            //       onTap: () {
                            //         setState(() {
                            //           _selected = index;
                            //         });
                            //       },
                            //       child: Container(
                            //         decoration: BoxDecoration(
                            //           color: Colors.grey.shade200,
                            //           borderRadius: BorderRadius.circular(10),
                            //           border: _selected == index
                            //               ? Border.all(
                            //                   width: 2,
                            //                 )
                            //               : null,
                            //         ),
                            //         alignment: Alignment.center,
                            //         child: Text(_transports[index]),
                            //       ),
                            //     );
                            //   },
                            // ),
                            Row(
                              children: [
                                data["Taxi"]=="true"? GestureDetector(
                                  onTap: ()=>GoRouter.of(context).pushNamed("TaxiBooking").then((_)=>setState(() {

                                  })),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    width: (MediaQuery.sizeOf(context).width/4)-12,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xff7BDD0A),
                                                width: 4
                                            )
                                        )
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset("assets/taxi.png"),
                                        ),
                                        const Text("Taxi")
                                      ],
                                    ),
                                  ),
                                ):const SizedBox(),
                                data["Truck"]=="true"?GestureDetector(
                                  onTap: ()=>GoRouter.of(context).pushNamed("TruckBooking").then((_)=>setState(() {

                                  })),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    width: (MediaQuery.sizeOf(context).width/4)-12,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xff7BDD0A),
                                                width: 4
                                            )
                                        )
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset("assets/truck.png"),
                                        ),
                                        const Text("Truck")
                                      ],
                                    ),
                                  ),
                                ):const SizedBox(),
                                data["Bike"]=="true"?GestureDetector(
                                  onTap:data["BikeBooking"].toString()=="null"? ()=>GoRouter.of(context).pushNamed("BikeBooking").then((_)=>setState(() {

                                  })):null,
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    width: (MediaQuery.sizeOf(context).width/4)-12,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xff7BDD0A),
                                                width: 4
                                            )
                                        )
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        data["BikeBooking"].toString()=="null"?Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset("assets/bike.png"),
                                        ):Stack(
                                          alignment: Alignment.center,
                                          children: [

                                            Padding(
                                              padding: const EdgeInsets.all(12.0),
                                              child: Image.asset("assets/bike.png"),
                                            ),
                                            Container(
                                              color: Colors.white.withOpacity(0.5),
                                              width: (MediaQuery.sizeOf(context).width/4)-12,
                                              height: 66,
                                              child: Center(child: Text("Already have 1",textAlign: TextAlign.center,)),
                                            ),
                                          ],
                                        ),
                                        const Text("Bike")
                                      ],
                                    ),
                                  ),
                                ):const SizedBox(),
                                data["Auto"]=="true"?GestureDetector(
                                  onTap: ()=>GoRouter.of(context).pushNamed("AutoBooking").then((_)=>setState(() {

                                  })),
                                  child: Container(
                                    margin: const EdgeInsets.all(4),
                                    width: (MediaQuery.sizeOf(context).width/4)-12,
                                    height: 90,
                                    decoration: const BoxDecoration(
                                        color: Colors.white,
                                        border: Border(
                                            bottom: BorderSide(
                                                color: Color(0xff7BDD0A),
                                                width: 4
                                            )
                                        )
                                    ),
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Padding(
                                          padding: const EdgeInsets.all(12.0),
                                          child: Image.asset("assets/rikshaw.png"),
                                        ),
                                        const Text("Auto")
                                      ],
                                    ),
                                  ),
                                ):const SizedBox(),
                              ],
                            ),
                            const SizedBox(
                              height: 32,
                            ),

                            if(kDebugMode)
                              Column(
                                children: [
                                  const Text("Debug transports (this panel only show in debug mode.)"),
                                  Row(
                                    children: [
                                      GestureDetector(
                                        onTap: ()=>GoRouter.of(context).pushNamed("TaxiBooking").then((_)=>setState(() {

                                        })),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          width: (MediaQuery.sizeOf(context).width/4)-12,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(0xff7BDD0A),
                                                      width: 4
                                                  )
                                              )
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Image.asset("assets/taxi.png"),
                                              ),
                                              const Text("Taxi")
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: ()=>GoRouter.of(context).pushNamed("TruckBooking").then((_)=>setState(() {

                                        })),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          width: (MediaQuery.sizeOf(context).width/4)-12,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(0xff7BDD0A),
                                                      width: 4
                                                  )
                                              )
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Image.asset("assets/truck.png"),
                                              ),
                                              const Text("Truck")
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: ()=>GoRouter.of(context).pushNamed("BikeBooking").then((_)=>setState(() {

                                        })),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          width: (MediaQuery.sizeOf(context).width/4)-12,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(0xff7BDD0A),
                                                      width: 4
                                                  )
                                              )
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Image.asset("assets/bike.png"),
                                              ),
                                              const Text("Bike")
                                            ],
                                          ),
                                        ),
                                      ),
                                      GestureDetector(
                                        onTap: ()=>GoRouter.of(context).pushNamed("AutoBooking").then((_)=>setState(() {

                                        })),
                                        child: Container(
                                          margin: const EdgeInsets.all(4),
                                          width: (MediaQuery.sizeOf(context).width/4)-12,
                                          height: 90,
                                          decoration: const BoxDecoration(
                                              color: Colors.white,
                                              border: Border(
                                                  bottom: BorderSide(
                                                      color: Color(0xff7BDD0A),
                                                      width: 4
                                                  )
                                              )
                                          ),
                                          child: Column(
                                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                            children: [
                                              Padding(
                                                padding: const EdgeInsets.all(12.0),
                                                child: Image.asset("assets/rikshaw.png"),
                                              ),
                                              const Text("Auto")
                                            ],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                ],
                              )
                            ,
                            if(data["OngoingTaxi"].toString()!="0" || data["OngoingTruck"].toString()!="0")
                              Column(
                                children: [
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                    children: [
                                      data["OngoingTaxi"].toString()!="0"?
                                      GestureDetector(
                                        onTap: (){
                                          GoRouter.of(context).pushNamed("AllOnging",
                                              pathParameters: {
                                                "type":"Taxi"
                                              }
                                          ).then((_)=>setState(() {

                                          }));
                                        },
                                        child: Container(
                                          padding: const EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(100),
                                              border: Border.all(
                                                  width: 1,
                                                  color: Colors.grey
                                              )
                                          ),
                                          child: Row(
                                            children: [
                                              const Text("Ongoing Taxi"),
                                              const SizedBox(
                                                width: 16,
                                              ),
                                              Text(data["OngoingTaxi"].toString(),
                                                style: const TextStyle(
                                                    fontWeight: FontWeight.bold
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ):const SizedBox(),
                                      data["OngoingTruck"].toString()!="0"?
                                      Container(
                                        padding: const EdgeInsets.all(8),
                                        decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(100),
                                            border: Border.all(
                                                width: 1,
                                                color: Colors.grey
                                            )
                                        ),
                                        child: Row(
                                          children: [
                                            const Text("Ongoing Truck"),
                                            const SizedBox(
                                              width: 16,
                                            ),
                                            Text(data["OngoingTruck"].toString(),
                                              style: const TextStyle(
                                                  fontWeight: FontWeight.bold
                                              ),
                                            ),
                                          ],
                                        ),
                                      ):const SizedBox(),
                                    ],
                                  ),
                                  const SizedBox(
                                    height: 32,
                                  ),
                                ],
                              ),


                            if(data["TaxiBooking"].toString()!="null" || data["TruckBooking"].toString()!="null" || data["BikeBooking"].toString()!="null" || data["AutoBooking"].toString()!="null" )
                              Text("Existing Rides"),

                            if(data["TaxiBooking"].toString()!="null")
                              card(data["TaxiBooking"], "Taxi"),

                            if(data["TruckBooking"].toString()!="null")
                              card(data["TruckBooking"], "Truck"),

                            if(data["BikeBooking"].toString()!="null")
                              card(data["BikeBooking"], "Bike"),

                            if(data["AutoBooking"].toString()!="null")
                              card(data["AutoBooking"], "Auto"),
                          ],
                        ),
                      ),
                    ),
                  ),
                )
              ],
            ),
            floatingActionButton:data!=null?data["LiveRides"].toString()!="0"?GestureDetector(
              onTap: (){
                GoRouter.of(context).pushNamed("AllLive").then((_)=>setState(() {

                }));
              },
              child: Container(
                margin: const EdgeInsets.only(bottom: 8),
                decoration: BoxDecoration(
                    color: const Color(0xff7BDD0A),
                    borderRadius: BorderRadius.circular(100)
                ),
                padding: const EdgeInsets.symmetric(vertical: 8,horizontal: 32),
                child:  Text("Your ${data["LiveRides"]} live Rides",
                  style: const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ):null:null,
            floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
          );
        },
      );
    }catch(e){

      return ErrorPage();
   }
  }

  Widget card(Map<String, dynamic> data, String type) {

    Color _color = Colors.black;
    

    switch (data["status"]) {
      case "Created":
        _color = Colors.black;
        break;
      case "Booked":
        _color = const Color(0xff01C042);
        break;
      case "Completed":
        _color = const Color(0xff0057DB);
        break;
      case "Live":
        _color = const Color(0xff7BDD0A);
        break;
      case "Cancel":
        _color = const Color(0xffDB0D00);
        break;
      default:
        _color = Colors.black; // Default color if status is not recognized
        break;
    }

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8.0),
      child: GestureDetector(
        onTap: (){
          GoRouter.of(context).pushNamed("SingleBookingDetails",
              pathParameters: {
                "type":type,
                "id":data["id"].toString(),
              }
          ).then((_)=>setState(() {

          }));
        },
        child: Container(
          decoration: BoxDecoration(
            color: Colors.white,
            border: Border(
              left: BorderSide(
                color: _color,
                width: 3,
              ),
            ),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 8),
                  child: Text("$type Booking",style: TextStyle(fontWeight: FontWeight.bold),)
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      const SizedBox(
                        width: 8,
                      ),
                      const Text(
                        "Booking No. ",
                        style: TextStyle(color: Colors.grey),
                      ),
                      Text(
                        data["bookingNo"].toString(),
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    color: _color,
                    child: Text(
                      data["status"],
                      style: const TextStyle(color: Colors.white),
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
                                  width: MediaQuery.sizeOf(context).width/1.3,
                                  child: Text(data["city"]+", "+data["state"],
                                    style:const  TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: MediaQuery.sizeOf(context).width/1.3,
                                //   child: Text(data["from"],
                                //     style:const  TextStyle(
                                //         color: Colors.grey,
                                //         overflow: TextOverflow.ellipsis
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                        Divider(),
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
                                  width: MediaQuery.sizeOf(context).width/1.3,
                                  child: Text(data["to_city"].toString()+", "+data["to_state"].toString(),
                                    style:const  TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                                // SizedBox(
                                //   width: MediaQuery.sizeOf(context).width/1.3,
                                //   child: Text(data["to"],
                                //     style:const  TextStyle(
                                //         color: Colors.grey,
                                //         overflow: TextOverflow.ellipsis
                                //     ),
                                //   ),
                                // ),
                              ],
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  // const SizedBox(
                  //   width: 8,
                  // ),
                  // Column(
                  //   children: [
                  //     SizedBox(
                  //         height: 40,
                  //         child: Image.asset(image)
                  //     ),
                  //     Text(widget.type)
                  //   ],
                  // ),
                  const SizedBox(
                    width: 8,
                  ),
                ],
              ),
              // const SizedBox(height: 8),
              // Row(
              //   children: [
              //     const SizedBox(
              //       width: 8,
              //     ),
              //     const Text(
              //       "Date: ",
              //       style: TextStyle(color: Colors.grey),
              //     ),
              //     Text(
              //       data["date"].toString(),
              //       style: const TextStyle(fontWeight: FontWeight.bold),
              //     ),
              //   ],
              // ),
              const SizedBox(
                height: 8,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
