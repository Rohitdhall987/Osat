
import 'dart:convert';
import 'dart:io';



import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/login.dart';
import 'package:pull_to_refresh/pull_to_refresh.dart';

class AllHistory extends StatefulWidget {

  final String url;
  final String type;

   const AllHistory({super.key, required this.url, required this.type});

  @override
  State<AllHistory> createState() => _AllHistoryState();
}

class _AllHistoryState extends State<AllHistory> {

  final UserData _user=UserData();

  List<Map<String,dynamic>> data=[];
  bool loaded=false;

  int? lastId=null;



  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    _controller.addListener(_onScrollEvent);
    debugPrint(_controller.hasClients.toString());
    // getData(lastId);



  }



  void _onScrollEvent() {
    debugPrint("=========================");
    final extentAfter = _controller.position.extentAfter;
    debugPrint("last id: $lastId");
    if(extentAfter==0.0){
      setState(() {

      });
    }
  }

  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _controller.dispose();
  }
  Future<dynamic> getData(int? lid)async{

    Uri url =Uri.https(
      dotenv.env['DOMAIN']!,
      "/api/user/${widget.url}",
      {
        "user_id":_user.get("id").toString(),
        "last_id":lid.toString()
      }
    );


    final token = _user.get("token").trim();

    debugPrint(url.toString());


    http.Response response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    if(response.statusCode==200){

          loaded=true;

          var tempData=jsonDecode(response.body);



          for(int i=0;i<tempData["AllBookings"].length;i++){

            data.add(tempData["AllBookings"][i]);
          }


          debugPrint(data.toString());







    }else{
      //debugPrint(response.body);
      _showSomethingWentWrongDialog();

    }


      _refreshController.refreshToIdle();


    return data;


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



  Widget card(Map<String, dynamic> data, int index) {

    lastId=data["id"];

    debugPrint(lastId.toString());

    Color _color = Colors.black;

    // String image="assets/taxi.png";
    //
    // switch (widget.type) {
    //   case "Taxi":
    //     image = "assets/taxi.png";
    //     break;
    //   case "Truck":
    //     image = "assets/truck.png";
    //     break;
    //   case "Bike":
    //     image = "assets/bike.png";
    //     break;
    //   case "Auto":
    //     image = "assets/rikshaw.png";
    //     break;
    // }

    // switch (data["AllBookings"][index]["status"]) {
    //   case "created":
    //     _color = Colors.black;
    //     break;
    //   case "booked":
    //     _color = const Color(0xff01C042);
    //     break;
    //   case "completed":
    //     _color = const Color(0xff0057DB);
    //     break;
    //   case "live":
    //     _color = const Color(0xff7BDD0A);
    //     break;
    //   case "cancel":
    //     _color = const Color(0xffDB0D00);
    //     break;
    //   default:
    //     _color = Colors.black; // Default color if status is not recognized
    //     break;
    // }

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
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){
          GoRouter.of(context).pushNamed("SingleBookingDetails",
              pathParameters: {
                "type":widget.type,
                "id":data["id"].toString(),
              }
          );
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
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width/1.3,
                                  child: Text(data["from"],
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
                                  width: MediaQuery.sizeOf(context).width/1.3,
                                  child: Text(data["to_city"].toString()+", "+data["to_state"].toString(),
                                    style:const  TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width/1.3,
                                  child: Text(data["to"],
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
              const SizedBox(height: 8),
              Row(
                children: [
                  const SizedBox(
                    width: 8,
                  ),
                  const Text(
                    "Date: ",
                    style: TextStyle(color: Colors.grey),
                  ),
                  Text(
                    data["date"].toString(),
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
      ),
    );
  }

  RefreshController _refreshController=RefreshController();

  ScrollController _controller=ScrollController();




  @override
  Widget build(BuildContext context) {
    try{
      return FutureBuilder(
          future: getData(lastId),
          builder: (context,snapshot){


            if(snapshot.hasData){

              if(data.isEmpty){

                return SizedBox(
                  height: MediaQuery.of(context).size.height/1.28,
                  width: MediaQuery.of(context).size.width,
                  child: const Center(
                      child: Text("You don't have any ride.")),
                );

              }

              return SmartRefresher(
                controller: _refreshController,
                onRefresh:(){
                  setState(() {
                    lastId=null;
                    data.clear();
                  });
                } ,
                child: ListView.builder(
                    physics: const AlwaysScrollableScrollPhysics(),
                    controller: _controller,
                    itemCount: data.length,
                    itemBuilder: (context, index) {

                      return card(data[index],index);

                    }
                ),
              );
            }else{
              return Center(child: CircularProgressIndicator(),);
            }


          }
      );
    }catch(e){
      return ErrorPage();
    }
  }

  // @override
  // Widget build(BuildContext context) {
  //   return Scaffold(
  //     backgroundColor: Colors.transparent,
  //
  //     body:loaded? SmartRefresher(
  //       controller: _refreshController,
  //       onRefresh:()=>getData(lastId) ,
  //       child: SingleChildScrollView(
  //         //physics: NeverScrollableScrollPhysics(),
  //           controller:_controller ,
  //         child: Column(
  //           children: [
  //             const SizedBox(
  //               height: 8,
  //             ),
  //
  //             data.isNotEmpty
  //                 ? ListView.builder(
  //               physics: const NeverScrollableScrollPhysics(),
  //               shrinkWrap: true,
  //               //controller: _controller,
  //               itemCount: data.length,
  //               itemBuilder: (context, index) {
  //                 return card(data[index], index);
  //               },
  //             )
  //                 : SizedBox(
  //               height: MediaQuery.of(context).size.height/1.28,
  //               width: MediaQuery.of(context).size.width,
  //               child: const Center(
  //                   child: Text("You don't have any ride.")),
  //             ),
  //           ],
  //         )
  //       ),
  //     ):
  //     const Center(
  //       child: CircularProgressIndicator(),
  //     ),
  //   );
  // }
}
