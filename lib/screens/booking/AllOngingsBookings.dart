import "dart:convert";
import "dart:io";

import"package:flutter/material.dart";
import "package:flutter_dotenv/flutter_dotenv.dart";
import "package:go_router/go_router.dart";
import 'package:http/http.dart'as http;
import "package:osat/screens/ErrorPage.dart";
import "package:osat/screens/login.dart";
import "package:pull_to_refresh/pull_to_refresh.dart";


class AllOnging extends StatefulWidget {

  final String type;
  const AllOnging({super.key, required this.type});

  @override
  State<AllOnging> createState() => _AllOngingState();
}

class _AllOngingState extends State<AllOnging> {



  final UserData _user=UserData();

  var data;
  bool loaded=false;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    getData();
  }
  void getData()async{

    setState(() {
      loaded=false;
    });
    _refreshController.refreshToIdle();

    Uri url =Uri.https(
        dotenv.env['DOMAIN']!,
        "/api/user/AllOngoingTaxi",
        {
          "user_id":_user.get("id").toString()
        }
    );


    final token = _user.get("token").trim();


    http.Response response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    debugPrint(response.body);

    if(response.statusCode==200){
      if(mounted){
        setState(() {
          loaded=true;
          data=jsonDecode(response.body);
        });
      }

    }else{
      //debugPrint(response.body);
      _showSomethingWentWrongDialog();

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



  Widget card(Map<String, dynamic> data, int index) {
    Color _color = Colors.black;







    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: GestureDetector(
        onTap: (){
          GoRouter.of(context).pushNamed("SingleOngoingTaxi",
              pathParameters: {
                "type":widget.type,
                "id":data["ongoingTaxi"][index]["id"].toString(),
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
                          data["ongoingTaxi"][index]["date"].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    color: _color,
                    child: Text(
                      data["ongoingTaxi"][index]["time"],
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
                                  child: Text(data["ongoingTaxi"][index]["city"]+", "+data["ongoingTaxi"][index]["state"],
                                    style:const  TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width/1.8,
                                  child: Text(data["ongoingTaxi"][index]["from"],
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
                                  child: Text(data["ongoingTaxi"][index]["to_city"].toString()+", "+data["ongoingTaxi"][index]["to_state"].toString(),
                                    style:const  TextStyle(
                                        fontWeight: FontWeight.bold,
                                        overflow: TextOverflow.ellipsis
                                    ),
                                  ),
                                ),
                                SizedBox(
                                  width: MediaQuery.sizeOf(context).width/1.8,
                                  child: Text(data["ongoingTaxi"][index]["to"],
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
                    data["ongoingTaxi"][index]["car_name"].toString(),
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
                    "₹ "+data["ongoingTaxi"][index]["avg_price"].toString(),
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
            ],
          ),
        ),
      ),
    );
  }

  RefreshController _refreshController=RefreshController();
  @override
  Widget build(BuildContext context) {


    try{
      return Scaffold(
        appBar: AppBar(
          title: const Text("Available Taxi"),
          centerTitle: true,
          forceMaterialTransparency: true,
        ),
        body:loaded? SmartRefresher(
          controller: _refreshController,
          onRefresh:getData ,
          child: SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(
                    height: 8,
                  ),
                  // Row(
                  //   children: [
                  //     SizedBox(
                  //       width: 8,
                  //     ),
                  //     Container(
                  //       padding: EdgeInsets.all(12),
                  //       decoration: BoxDecoration(
                  //         borderRadius: BorderRadius.circular(100),
                  //         border:Border.all(
                  //           width: 0.5
                  //         )
                  //       ),
                  //       child: Text("Filter"),
                  //     ),
                  //   ],
                  // ),
                  data["ongoingTaxi"].isNotEmpty
                      ? ListView.builder(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemCount: data["ongoingTaxi"].length,
                    itemBuilder: (context, index) {
                      return card(data, index);
                    },
                  )
                      : SizedBox(
                    height: MediaQuery.of(context).size.height/1.28,
                    width: MediaQuery.of(context).size.width,
                    child: const Center(
                        child: Text("No Ride Found")),
                  ),
                ],
              )
          ),
        ):
        const Center(
          child: CircularProgressIndicator(),
        ),
      );
    }catch(e){
      return ErrorPage();
    }
  }
}
