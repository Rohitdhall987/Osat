

import 'package:flutter/material.dart';
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/HistoryScreens/Live.dart';

class AllLive extends StatefulWidget {


  const AllLive({super.key});

  @override
  State<AllLive> createState() => _AllLiveState();
}

class _AllLiveState extends State<AllLive> {
  // final UserData _user = UserData();
  // List<Map<String,dynamic>> data=[];
  // bool loaded=false;
  //
  // int? lastId=null;



  // @override
  // void initState() {
  //   // TODO: implement initState
  //   super.initState();
  //   _controller.addListener(_onScrollEvent);
  //   debugPrint(_controller.hasClients);
  //   // getData(lastId);
  //
  //
  //
  // }
  //
  //
  //
  // void _onScrollEvent() {
  //   debugPrint("=========================");
  //   final extentAfter = _controller.position.extentAfter;
  //   debugPrint("last id: $lastId");
  //   if(extentAfter==0.0){
  //     setState(() {
  //
  //     });
  //   }
  // }
  //
  // @override
  // void dispose() {
  //   // TODO: implement dispose
  //   super.dispose();
  //   _controller.dispose();
  // }
  // Future<dynamic> getData(int? lid) async {
  //   Uri url = Uri.https(dotenv.env['DOMAIN']!, "/api/user/TaxiBookingByStatus", {
  //     "user_id": _user.get("id").toString(),
  //     "bookingStatus": "Live",
  //     "last_id":lid.toString()
  //   });
  //
  //   final token = _user.get("token").trim();
  //   debugPrint(url);
  //
  //   http.Response response = await http.post(
  //     url,
  //     headers: {
  //       HttpHeaders.authorizationHeader: 'Bearer $token',
  //     },
  //   );
  //
  //   debugPrint(response.body);
  //
  //   if (response.statusCode == 200) {
  //     loaded = true;
  //
  //     var tempData = jsonDecode(response.body);
  //
  //     // Check if AllBookings exists and is a list
  //     if (tempData["AllBookings"] != null && tempData["AllBookings"] is List) {
  //       for (int i = 0; i < tempData["AllBookings"].length; i++) {
  //         try {
  //           // debugPrint(tempData["AllBookings"][i]);
  //           // Ensure each item is a Map
  //           if (tempData["AllBookings"][i] is Map<String, dynamic>) {
  //             data.add(tempData["AllBookings"][i]);
  //           } else {
  //             debugPrint('Item is not a Map: ${tempData["AllBookings"][i]}');
  //           }
  //         } catch (e) {
  //           debugPrint(e);
  //         }
  //       }
  //     } else {
  //       debugPrint('AllBookings is either null or not a List');
  //     }
  //
  //     debugPrint(data);
  //   } else {
  //     _showSomethingWentWrongDialog();
  //   }
  //
  //   _refreshController.refreshToIdle();
  //
  //   return data;
  // }
  //
  // void _showSomethingWentWrongDialog() {
  //   showDialog(
  //     context: context,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         content: Text(
  //           '⚠️ Oops! Something went wrong. 😔 Please try again later.',
  //           style: Theme.of(context).textTheme.bodyLarge,
  //         ),
  //         actions: <Widget>[
  //           TextButton(
  //             child: Text('OK'),
  //             onPressed: () {
  //               Navigator.of(context).pop();
  //             },
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  // Widget card(Map<String, dynamic> data, int index) {
  //   lastId=data["id"];
  //   Color _color=const Color(0xff7BDD0A);
  //   String image;
  //   //
  //   // switch (data["AllBookings"][index]["status"]) {
  //   //
  //   //   case "created":
  //   //     _color = Colors.black;
  //   //     break;
  //   //   case "booked":
  //   //     _color = const Color(0xff01C042);
  //   //     break;
  //   //   case "completed":
  //   //     _color = const Color(0xff0057DB);
  //   //     break;
  //   //   case "live":
  //   //     _color = const Color(0xff7BDD0A);
  //   //     break;
  //   //   case "cancelled":
  //   //     _color = const Color(0xffDB0D00);
  //   //     break;
  //   //   default:
  //   //     _color = Colors.black; // Default color if status is not recognized
  //   // }
  //
  //   return Padding(
  //     padding: const EdgeInsets.all(8.0),
  //     child: GestureDetector(
  //       onTap: (){
  //         GoRouter.of(context).pushNamed("SingleBookingDetails",
  //             pathParameters: {
  //               "type":"Taxi",
  //               "id":data["id"].toString(),
  //             }
  //         );
  //       },
  //       child: Container(
  //         decoration: BoxDecoration(
  //           color: Colors.white,
  //           border: Border(
  //             left: BorderSide(
  //               color: _color,
  //               width: 3,
  //             ),
  //           ),
  //         ),
  //         child: Column(
  //           crossAxisAlignment: CrossAxisAlignment.start,
  //           children: [
  //             Row(
  //               mainAxisAlignment: MainAxisAlignment.spaceBetween,
  //               children: [
  //                 Row(
  //                   children: [
  //                     const SizedBox(
  //                       width: 8,
  //                     ),
  //                     const Text(
  //                       "Booking No. ",
  //                       style: TextStyle(color: Colors.grey),
  //                     ),
  //                     Text(
  //                       data["bookingNo"].toString(),
  //                       style: const TextStyle(fontWeight: FontWeight.bold),
  //                     ),
  //                   ],
  //                 ),
  //                 Container(
  //                   padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
  //                   color: _color,
  //                   child: Text(
  //                     data["status"],
  //                     style: const TextStyle(color: Colors.white),
  //                   ),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const SizedBox(
  //                   width: 8,
  //                 ),
  //                 Expanded(
  //                   child: Column(
  //                     crossAxisAlignment: CrossAxisAlignment.start,
  //                     children: [
  //                       Row(
  //                         children: [
  //                           const Icon(Icons.location_on),
  //                           const SizedBox(width: 8),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               SizedBox(
  //                                 width: MediaQuery.sizeOf(context).width/1.3,
  //                                 child: Text(data["city"]+", "+data["state"],
  //                                   style:const  TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       overflow: TextOverflow.ellipsis
  //                                   ),
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 width: MediaQuery.sizeOf(context).width/1.3,
  //                                 child: Text(data["from"],
  //                                   style:const  TextStyle(
  //                                       color: Colors.grey,
  //                                       overflow: TextOverflow.ellipsis
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                       const Padding(
  //                         padding: EdgeInsets.all(8.0),
  //                         child: Divider(),
  //                       ),
  //                       Row(
  //                         children: [
  //                           const Icon(
  //                             Icons.radio_button_checked,
  //                             color: Color(0xff7BDD0A),
  //                           ),
  //                           const SizedBox(width: 8),
  //                           Column(
  //                             crossAxisAlignment: CrossAxisAlignment.start,
  //                             children: [
  //                               SizedBox(
  //                                 width: MediaQuery.sizeOf(context).width/1.3,
  //                                 child: Text(data["to_city"].toString()+", "+data["to_state"].toString(),
  //                                   style:const  TextStyle(
  //                                       fontWeight: FontWeight.bold,
  //                                       overflow: TextOverflow.ellipsis
  //                                   ),
  //                                 ),
  //                               ),
  //                               SizedBox(
  //                                 width: MediaQuery.sizeOf(context).width/1.3,
  //                                 child: Text(data["to"],
  //                                   style:const  TextStyle(
  //                                       color: Colors.grey,
  //                                       overflow: TextOverflow.ellipsis
  //                                   ),
  //                                 ),
  //                               ),
  //                             ],
  //                           ),
  //                         ],
  //                       ),
  //                     ],
  //                   ),
  //                 ),
  //                 // const SizedBox(
  //                 //   width: 8,
  //                 // ),
  //                 // Column(
  //                 //   children: [
  //                 //     SizedBox(
  //                 //         height: 40,
  //                 //         child: Image.asset(image)
  //                 //     ),
  //                 //     Text(widget.type)
  //                 //   ],
  //                 // ),
  //                 const SizedBox(
  //                   width: 8,
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(height: 8),
  //             Row(
  //               children: [
  //                 const SizedBox(
  //                   width: 8,
  //                 ),
  //                 const Text(
  //                   "Date: ",
  //                   style: TextStyle(color: Colors.grey),
  //                 ),
  //                 Text(
  //                   data["date"].toString(),
  //                   style: const TextStyle(fontWeight: FontWeight.bold),
  //                 ),
  //               ],
  //             ),
  //             const SizedBox(
  //               height: 8,
  //             ),
  //           ],
  //         ),
  //       ),
  //     ),
  //   );
  // }
  //
  //
  // RefreshController _refreshController= RefreshController();
  //
  //
  //
  // ScrollController _controller=ScrollController();



  @override
  Widget build(BuildContext context) {

    try{
      return DefaultTabController(
        length: 4,
        child: Scaffold(
          appBar: AppBar(
            title: Text("ALl Live"),
            centerTitle: true,
            forceMaterialTransparency: true,
            bottom: PreferredSize(
              preferredSize: const Size.fromHeight(40),
              child: Container(
                width: MediaQuery.of(context).size.width,
                height: 40,
                color: const Color(0xffF6F6F6),
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 8.0),
                  child: TabBar(

                    dividerColor: Colors.transparent,
                    labelPadding: EdgeInsets.zero,
                    indicator: BoxDecoration(
                        borderRadius: BorderRadius.circular(5),
                        color: const Color(0xff101010)
                    ),
                    tabAlignment: TabAlignment.center,
                    labelColor: Colors.white ,
                    labelStyle: const TextStyle(
                        fontWeight: FontWeight.bold
                    ),
                    isScrollable: true,
                    tabs: const [
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Text("Taxi",),
                      ),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Text("Truck",),
                      ),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Text("Bike",),
                      ),
                      Padding(
                        padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                        child: Text("Auto",),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          body: const TabBarView(
              children: [
              Live(url: "TaxiBookingByStatus",type: "Taxi",),
              Live(url: "TransportBookingByStatus",type: "Truck",),
              Live(url: "BikeBookingByStatus",type: "Bike",),
              Live(url: "AutoBookingByStatus",type: "Auto",),
            ]
          ),
        ),
      );
    }catch(e){
      return ErrorPage();
    }


  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     appBar: AppBar(
  //       centerTitle: true,
  //       title: const Text(
  //         "OSAT",
  //         style: TextStyle(
  //             fontSize: 24,
  //             fontWeight: FontWeight.bold
  //         ),
  //       ),
  //       backgroundColor: Colors.white,
  //       forceMaterialTransparency: true,
  //     ),
  //     body: loaded
  //         ? SmartRefresher(
  //       controller: _refreshController,
  //       onRefresh: getData,
  //       child: SingleChildScrollView(
  //           child: Column(
  //             children: [
  //               data["AllBookings"].isNotEmpty
  //                   ? ListView.builder(
  //                 physics: const NeverScrollableScrollPhysics(),
  //                 shrinkWrap: true,
  //                 itemCount: data["AllBookings"].length,
  //                 itemBuilder: (context, index) {
  //                   return card(data, index);
  //                 },
  //               )
  //                   : SizedBox(
  //                 height: MediaQuery.of(context).size.height/1.28,
  //                 width: MediaQuery.of(context).size.width,
  //                 child: const Center(
  //                     child: Text("You don't have any live ride.")),
  //               ),
  //             ],
  //           )),
  //     )
  //         : const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }
}
