
import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/login.dart';
import 'package:http/http.dart'as http;
import 'package:socket_io_client/socket_io_client.dart' as IO;


class SingleBookingDetails extends StatefulWidget {
  final String type;
  final String id;
  const SingleBookingDetails({super.key,required this.type,required this.id});

  @override
  State<SingleBookingDetails> createState() => _SingleBookingDetailsState();
}

class _SingleBookingDetailsState extends State<SingleBookingDetails> {



  final UserData _data=UserData();

   Timer? _timer;
  IO.Socket? _socket;

  var data;
  Map<String,dynamic> priceData={};
  List<dynamic>? priceList=[];

  bool loaded=false;
  late Color _color;

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    connectToSocket();
    pageLoad();
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
      print(widget.id+widget.type.toUpperCase());
      _socket!.emit("SetBookingPriceFromOwner", "${widget.id+widget.type.toUpperCase()}");
    });

    _socket!.on(widget.id+widget.type.toUpperCase(), (data){
    // _socket!.on("280TAXI", (data){
      print(data);
      int index = priceList!.indexWhere((item) => item['id'] == data['id']);

      setState(() {
        if (index != -1) {
            if( data['Price'] == "N/A"){
              priceList!.removeAt(index);
            }else{
              priceList![index] = data;
            }
        } else {
          priceList!.add(data);
        }
      });
    });


  }

  void pageLoad(){
    debugPrint(widget.type);
    if(widget.type=="Taxi" ||widget.type=="taxi"){
      fetchTaxiData();
    }else if(widget.type=="Truck" || widget.type=="truck"){
      fetchTruckData();
    }else if(widget.type=="Bike" || widget.type=="bike"){
      fetchBikeData();
    }else if(widget.type=="Auto" || widget.type=="auto"){
      fetchAutoData();
    }
  }




  @override
  void dispose() {
    // TODO: implement dispose
    super.dispose();
    _socket!.dispose();
    if(_timer!=null){
      _timer?.cancel();
    }
  }



  void fetchTruckData()async{
    debugPrint(_data.get("id").toString(),);
    debugPrint(widget.id.toString());

    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/SingleTruckBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleTaxiBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleTruckBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Bike":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleBikeBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Auto":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleAutoBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    // }


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

      debugPrint(response.body);

      if (response.statusCode == 200) {

        data = jsonDecode( response.body);

        //debugPrint(data);

        if(data["message"]!="success"){
          _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
        }else{

          switch (data["BookingDetail"]["status"]) {
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

          if(data["BookingDetail"]["status"]=="Created"){
            fetchTaxiPrice();
            // if(!kDebugMode){
            //   _timer=Timer.periodic(const Duration(seconds: 10), (_)=>fetchTruckData());
            // }
          }
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
  void fetchTaxiData({bool? again})async{

    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/SingleTaxiBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleTaxiBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleTruckBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Bike":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleBikeBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Auto":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/SingleAutoBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    // }


    String token=_data.get("token");

    if(mounted){
      setState(() {
        loaded=again ?? false;
      });
    }


    try {
      http.Response response=await http.post(url,
          headers: {
            HttpHeaders.authorizationHeader:"Bearer $token"
          }
      );

     // debugPrint(response.body);

      if (response.statusCode == 200) {

        data = jsonDecode( response.body);

        //debugPrint(data);

        if(data["message"]!="success"){
          _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
        }else{

          switch (data["BookingDetail"]["status"]) {
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

          if(data["BookingDetail"]["status"]=="Created"){
            fetchTaxiPrice();
              // if(!kDebugMode){
              //   _timer=Timer.periodic(const Duration(seconds: 10), (_)=>fetchTaxiData(again: true));
              // }
          }
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
  void fetchBikeData({bool? again})async{

    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/SingleBikeBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );




    String token=_data.get("token");

    if(mounted){
      setState(() {
        loaded=again ?? false;
      });
    }


    try {
      http.Response response=await http.post(url,
          headers: {
            HttpHeaders.authorizationHeader:"Bearer $token"
          }
      );

      // debugPrint(response.body);

      if (response.statusCode == 200) {

        data = jsonDecode( response.body);

        debugPrint("---dsdf sedf--"+data.toString());

        if(data["message"]!="success"){
          _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
        }else{

          switch (data["BookingDetail"]["status"]) {
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

          if(data["BookingDetail"]["status"]!="Cancel" && data["BookingDetail"]["status"]!="Completed"  && mounted){
            // fetchTaxiPrice();

            debugPrint((data["BookingDetail"]["status"]!="Cancel").toString() );
            Future.delayed(Duration(seconds: 5),()=>fetchBikeData(again: true));
          }
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint (e.toString());
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }


    if(mounted){
      setState(() {
        loaded=true;
      });
    }

  }
  void fetchAutoData()async{

    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/SingleAutoBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );




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

      // debugPrint(response.body);

      if (response.statusCode == 200) {

        data = jsonDecode( response.body);

        debugPrint("-----sd sd "+data.toString());

        if(data["message"]!="success"){
          _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
        }else{

          switch (data["BookingDetail"]["status"]) {
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

          if(data["BookingDetail"]["status"]=="Created"){
            // fetchTaxiPrice();
            if(!kDebugMode){
              _timer=Timer.periodic(const Duration(seconds: 10), (_)=>
              {});
            }
          }
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint (e.toString());
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }


    if(mounted){
      setState(() {
        loaded=true;
      });
    }

  }



  void fetchTaxiPrice()async{


    Uri url=Uri.https(
        dotenv.env["NOTIFICATION_URL"]!,
        "/GetBookingBidsByBookingId",

    );


    print(url);

    // String token=_data.get("token");


    try {
      http.Response response=await http.post(url,
          // headers: {
          //   HttpHeaders.authorizationHeader:"Bearer $token"
          // }
        body: {
          "BookingId": widget.id.toString(),
          "Type":widget.type.toUpperCase()
        }
      );

      print({
        "BookingId": widget.id.toString(),
        "Type":widget.type.toUpperCase()
      });

      if (response.statusCode == 200) {


        priceData = jsonDecode( response.body);


        debugPrint(priceData.toString());

        if(priceData["Status"]==1){
          List temp = priceData["Result"];
          setState(() {
            temp.forEach((data){
              if(data["Price"]!="N/A"){
                priceList!.add(data);
              }
            });
          });
        }else{
          _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.$e');
    }

  }
  // void fetchTruckPrice()async{
  //
  //
  //   Uri url=Uri.https(
  //       dotenv.env["DOMAIN"]!,
  //       "api/user/GetTruckBookingPriceList",
  //       {
  //         "user_id":_data.get("id").toString(),
  //         "booking_id":widget.id.toString()
  //       }
  //   );
  //
  //   debugPrint(url.toString());
  //
  //
  //   // switch (widget.type) {
  //   //   case "Taxi":
  //   //     url=Uri.https(
  //   //         dotenv.env["DOMAIN"]!,
  //   //         "api/user/GetTaxiBookingPriceList",
  //   //         {
  //   //           "user_id":_data.get("id").toString(),
  //   //           "booking_id":widget.id.toString()
  //   //         }
  //   //     );
  //   //     break;
  //   //   case "Truck":
  //   //     url=Uri.https(
  //   //         dotenv.env["DOMAIN"]!,
  //   //         "api/user/GetTruckBookingPriceList",
  //   //         {
  //   //           "user_id":_data.get("id").toString(),
  //   //           "booking_id":widget.id.toString()
  //   //         }
  //   //     );
  //   //     break;
  //   // }
  //
  //   String token=_data.get("token");
  //
  //
  //   try {
  //     http.Response response=await http.post(url,
  //         headers: {
  //           HttpHeaders.authorizationHeader:"Bearer $token"
  //         }
  //     );
  //
  //     if (response.statusCode == 200) {
  //
  //
  //       priceData = jsonDecode( response.body);
  //
  //
  //       debugPrint(priceData.toString());
  //
  //       if(priceData["message"].trim()=="Success"){
  //         setState(() {
  //           debugPrint ("set state called $priceData");
  //         });
  //       }else{
  //         _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
  //       }
  //
  //     } else {
  //       _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
  //     }
  //   } catch (e) {
  //     _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
  //   }
  //
  // }

  void cancelTaxiRide()async{
    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/CancelTaxiBooking",
        {
          "user_id":_data.get("id").toString(),
          "bookingNo":widget.id.toString()
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/CancelTaxiBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "bookingNo":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/CancelTransportBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    // }


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


      debugPrint(response.body.toString());
      if (response.statusCode == 200) {

        var Caneldata = jsonDecode( response.body);

        //debugPrint(Caneldata);

        if(Caneldata["message"]=="success"){
          GoRouter.of(context).pushReplacementNamed("RideCancelledPage");
        }else{
          Caneldata=[];
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }

    setState(() {
      loaded=true;
    });
  }
  void cancelTruckRide()async{
    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/CancelTruckBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/CancelTaxiBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "bookingNo":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/CancelTransportBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    // }


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

        var Caneldata = jsonDecode( response.body);

        //debugPrint(Caneldata);

        if(Caneldata["message"]=="success"){
          GoRouter.of(context).pushReplacementNamed("RideCancelledPage");
        }else{
          Caneldata=[];
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }

    setState(() {
      loaded=true;
    });
  }

  void cancelBikeRide(String? reason, String otherReason)async{
// Construct the URL without query parameters if using request body
    Uri url = Uri.https(
      dotenv.env["DOMAIN"]!,
      "api/user/CancelBikeBooking",
    );

    Map<String, String> requestBody = {
      "user_id": _data.get("id").toString(),
      "booking_id": widget.id.toString(),
      "reason": reason ?? otherReason,
    };

    String token = _data.get("token");

    setState(() {
      loaded = false;
    });

    try {
      http.Response response = await http.post(
        url,
        headers: {
          HttpHeaders.authorizationHeader: "Bearer $token",
          HttpHeaders.contentTypeHeader: "application/json",
        },
        body: jsonEncode(requestBody),
      );

      // Handle the response
      if (response.statusCode == 200) {
        var cancelData = jsonDecode(response.body);

        if (cancelData["message"] == "success") {
          GoRouter.of(context).pushReplacementNamed("RideCancelledPage");
        } else {
          cancelData = [];
        }
      } else {
        print(response.body);
        _showAlertDialog(
          context,
          'Error',
          'Something went wrong. Status code: ${response.statusCode}',
        );
      }
    } catch (e) {
      _showAlertDialog(
        context,
        'Error',
        'Something went wrong. Please try again later.',
      );
    }

    setState(() {
      loaded = true;
    });

  }



  void cancelAutoRide()async{
    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/CancelAutoBooking",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString()
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/CancelTaxiBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "bookingNo":widget.id.toString()
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/CancelTransportBooking",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString()
    //         }
    //     );
    //     break;
    // }


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

        var Caneldata = jsonDecode( response.body);

        //debugPrint(Caneldata);

        if(Caneldata["message"]=="success"){
          GoRouter.of(context).pushReplacementNamed("RideCancelledPage");
        }else{
          Caneldata=[];
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }

    setState(() {
      loaded=true;
    });
  }


  void acceptTaxiPrice(owner_id,price)async{
    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/TaxiConfirmedFromUser",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString(),
          "owner_id":owner_id.toString(),
          "price":price.toString(),
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/TaxiConfirmedFromUser",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString(),
    //           "owner_id":owner_id.toString(),
    //           "price":price.toString(),
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/TruckConfirmedFromUser",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString(),
    //           "owner_id":owner_id.toString(),
    //           "price":price.toString(),
    //         }
    //     );
    //     break;
    // }


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

      print(response.body);

      if (response.statusCode == 200) {

       var res = jsonDecode( response.body);

        debugPrint(res.toString());

        if(res["message"]=="success"){
        //  debugPrint("====================success");
          GoRouter.of(context).pushReplacementNamed("RideBookedPage");
        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }

    setState(() {
      loaded=true;
    });
  }

  void acceptTruckPrice(owner_id,price)async{
    Uri url=Uri.https(
        dotenv.env["DOMAIN"]!,
        "api/user/TruckConfirmedFromUser",
        {
          "user_id":_data.get("id").toString(),
          "booking_id":widget.id.toString(),
          "owner_id":owner_id.toString(),
          "price":price.toString(),
        }
    );


    // switch (widget.type) {
    //   case "Taxi":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/TaxiConfirmedFromUser",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString(),
    //           "owner_id":owner_id.toString(),
    //           "price":price.toString(),
    //         }
    //     );
    //     break;
    //   case "Truck":
    //     url=Uri.https(
    //         dotenv.env["DOMAIN"]!,
    //         "api/user/TruckConfirmedFromUser",
    //         {
    //           "user_id":_data.get("id").toString(),
    //           "booking_id":widget.id.toString(),
    //           "owner_id":owner_id.toString(),
    //           "price":price.toString(),
    //         }
    //     );
    //     break;
    // }


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

        var res = jsonDecode( response.body);

        debugPrint(url.toString());
        debugPrint(res.toString());

        if(res["message"]=="success"){
          //  debugPrint("====================success");
          GoRouter.of(context).pushReplacementNamed("RideBookedPage");
        }else{
          debugPrint((res["message"]=="success").toString());
          debugPrint(res["message"]);

        }

      } else {
        _showAlertDialog(context, 'Error', 'Something went wrong. Status code: ${response.statusCode}');
      }
    } catch (e) {
      debugPrint(e.toString());
      _showAlertDialog(context, 'Error', 'Something went wrong. Please try again later.');
    }

    setState(() {
      loaded=true;
    });
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

  void _showCancelDialog() {
    String? _selectedReason;
    TextEditingController _otherReasonController = TextEditingController();
    bool _showOtherField = _selectedReason == 'Other';
    bool _isSubmitting = false;
    bool _hasError = false;
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return StatefulBuilder(
          builder: (BuildContext context, StateSetter setModalState) {


            return AlertDialog(
              surfaceTintColor: Colors.white,
              title: Text('Are you sure?'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text('Are you sure you want to cancel your ride?'),
                    SizedBox(height: 16),
                    // DropdownButton styled with a border
                    Container(
                      decoration: BoxDecoration(
                        border: Border.all(
                          color: _hasError && _selectedReason == null ? Colors.red : Colors.grey,
                        ),
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: DropdownButton<String>(
                        hint: Text('Select reason'),
                        value: _selectedReason,
                        items: [
                          'Change of plans',
                          'Too expensive',
                          'Found another option',
                          'Other',
                        ].map((String reason) {
                          return DropdownMenuItem<String>(
                            value: reason,
                            child: Text(reason),
                          );
                        }).toList(),
                        onChanged: (String? newValue) {
                          setModalState(() {
                            _selectedReason = newValue;
                            _showOtherField = newValue == 'Other';
                            _hasError = false; // Reset error when user makes a selection
                          });
                        },
                        isExpanded: true,
                        underline: SizedBox(), // Remove the default underline
                      ),
                    ),
                    if (_showOtherField)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: TextFormField(
                          controller: _otherReasonController,
                          decoration: InputDecoration(
                            labelText: 'Please specify',
                            border: OutlineInputBorder(),
                            errorText: _hasError && _selectedReason == 'Other' && _otherReasonController.text.isEmpty
                                ? 'This field is required'
                                : null,
                          ),
                        ),
                      ),
                    if (_hasError)
                      Padding(
                        padding: const EdgeInsets.only(top: 8.0),
                        child: Text(
                          'Please fill in all required fields.',
                          style: TextStyle(color: Colors.red),
                        ),
                      ),
                  ],
                ),
              ),
              actions: <Widget>[
                TextButton(
                  child: _isSubmitting
                      ? CircularProgressIndicator()
                      : Text('Cancel Ride'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.red,
                  ),
                  onPressed: () async {
                    if (_isSubmitting) return;

                    if (_selectedReason == null || (_selectedReason == 'Other' && _otherReasonController.text.isEmpty)) {
                      setModalState(() {
                        _hasError = true;
                      });
                      return;
                    }

                    setModalState(() {
                      _isSubmitting = true;
                      _hasError = false;
                    });

                    // Handle ride cancellation based on type
                    if (widget.type == "taxi" || widget.type == "Taxi") {
                       cancelTaxiRide();
                    } else if (widget.type == "truck" || widget.type == "Truck") {
                       cancelTruckRide();
                    } else if (widget.type == "bike" || widget.type == "Bike") {
                      cancelBikeRide(_selectedReason, _otherReasonController.text);
                    } else if (widget.type == "auto" || widget.type == "Auto") {
                       cancelAutoRide();
                    }

                    // debugPrint the reason if needed
                    debugPrint('Cancellation reason: ${_selectedReason}');
                    if (_selectedReason == 'Other') {
                      debugPrint('Other reason: ${_otherReasonController.text}');
                    }

                    Navigator.of(context).pop();
                  },
                ),
                TextButton(
                  child: Text('No'),
                  style: TextButton.styleFrom(
                    backgroundColor: Colors.transparent,
                    foregroundColor: Colors.black,
                  ),
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                ),
              ],
            );
          },
        );
      },
    );
  }






  void _showPriceDialog(owner_id,price) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: Text('Are you sure?'),
          content: Text('Are you sure you want to accept this price for your ride?'),
          actions: <Widget>[
            TextButton(
              child: Text('No'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.black,
              ),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: Text('Accept Price'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.green,
              ),
              onPressed: () {
                if(widget.type=="Taxi" ||widget.type=="taxi"){
                  acceptTaxiPrice(owner_id,price);
                }else{
                  debugPrint("truck   ===");
                  acceptTruckPrice(owner_id, price);
                }


                Navigator.of(context).pop();
                // Add your cancel ride logic here
               // debugPrint("Accept Price");
              },
            ),


          ],
        );
      },
    );
  }




  Widget taxiDetails(){
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: _color ,
            child:data["BookingDetail"]!=null? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Booking No ",
                        style: const TextStyle(
                            color: Colors.white
                        ),
                      ),
                      Text(data["BookingDetail"]["bookingNo"].toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                  Text(data["BookingDetail"]["status"].toString(),
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  )
                ],
              ),
            ):const SizedBox(),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,),
            child: Text(widget.type,
              style:const TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(data["BookingDetail"]["from"].toString(),
                        style:const  TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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
                    Expanded(
                      child: Text(
                        data["BookingDetail"]["to"].toString(),
                        style: const TextStyle(
                            color: Colors.grey
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              children: [
                const Text("Trip Type: ",
                ),
                Text(data["BookingDetail"]["trip_type"]=="one_way"?"One Way":"Round Trip",
                  style: const TextStyle(fontWeight: FontWeight.bold),
                )
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Text("Passangers"),
                    Text(" ${data["BookingDetail"]["person"]}",
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                data["BookingDetail"]["trip_type"]=="one_way"?Row(
                  children: [
                    const Text(
                      "Date: ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      data["BookingDetail"]["date"].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
                    :
                Column(
                  crossAxisAlignment: CrossAxisAlignment.end,
                  children: [
                    Row(
                      children: [
                        const Text(
                          "Leaving Date ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          data["BookingDetail"]["date"].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        const Text(
                          "Arriving Date ",
                          style: TextStyle(color: Colors.grey),
                        ),
                        Text(
                          data["BookingDetail"]["arriving_date"].toString(),
                          style: const TextStyle(fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                data["price"].toString()!="[]"? Column(
                  children: [
                    Text("Ride Amount",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10
                      ),
                    ),
                    Text("₹"+data["price"].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28
                      ),
                    ),
                  ],
                ):const SizedBox(),
                data["BookingDetail"]["status"]!="Live"&&data["BookingDetail"]["status"]!="Cancel"&&data["BookingDetail"]["status"]!="Completed"?
                GestureDetector(
                  onTap: _showCancelDialog,
                  child: const Text(
                    "Cancel Ride",
                    style: TextStyle(color: Colors.red),
                  ),
                ):const SizedBox(),
              ],
            ),
          ),
          data["BookingDetail"]["status"]=="Live" || data["BookingDetail"]["status"]=="Booked"|| data["BookingDetail"]["status"]=="Assigned"?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Start OTP",
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    Text(data["start_otp"].toString()),
                  ],
                ),
                Column(
                  children: [
                    Text("End OTP",
                        style: TextStyle(
                            color: Colors.grey.shade800,
                            fontWeight: FontWeight.bold,
                            fontSize: 16
                        )
                    ),
                    Text(data["end_otp"].toString()),
                  ],
                ),
              ],
            ),
          )
              :SizedBox(),
        ],
      ),
    );
  }



  Widget truckDetails(){
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            color: _color ,
            child:data["BookingDetail"]!=null? Padding(
              padding: const EdgeInsets.all(8.0),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    children: [
                      Text("Booking No ",
                        style: const TextStyle(
                            color: Colors.white
                        ),
                      ),
                      Text(data["BookingDetail"]["bookingNo"].toString(),
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white
                        ),
                      ),
                    ],
                  ),
                  Text(data["BookingDetail"]["status"].toString(),
                    style: const TextStyle(
                        color: Colors.white
                    ),
                  )
                ],
              ),
            ):const SizedBox(),
          ),
          const SizedBox(
            height: 4,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0,),
            child: Text(widget.type,
              style:const TextStyle(
                  fontWeight: FontWeight.bold
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    const Icon(Icons.location_on),
                    const SizedBox(width: 8),
                    Expanded(
                      child: Text(data["BookingDetail"]["from"].toString(),
                        style:const  TextStyle(
                          color: Colors.grey,
                        ),
                      ),
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
                    Expanded(
                      child: Text(
                        data["BookingDetail"]["to"].toString(),
                        style: const TextStyle(
                            color: Colors.grey
                        ),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    const Text("Weight:"),
                    Text(" ${data["BookingDetail"]["goodsQuantity"]} Kg",
                      style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),
                    ),
                  ],
                ),
                Row(
                  children: [
                    const Text(
                      "Date: ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      data["BookingDetail"]["date"].toString(),
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                )
              ],
            ),
          ),
          data["BookingDetail"]["image"]!=null?
          GestureDetector(
            onTap: ()=>GoRouter.of(context).pushNamed("ImageView",
            pathParameters: {
              "image":data["BookingDetail"]["image"],
            }
            ),
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: const Row(
                children: [

                  Icon(Icons.image),
                  SizedBox(
                    width: 16,
                  ),


                  Text("Image")
                ],
              ),
            ),
          )
              :
          const SizedBox(),
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Description:"),
                Text(" ${data["BookingDetail"]["desciption"]}",
                  style: TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ],
            ),
          ),

          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                data["price"].toString()!="null"? Column(
                  children: [
                    Text("Ride Amount",
                      style: TextStyle(
                          color: Colors.grey,
                          fontWeight: FontWeight.bold,
                          fontSize: 10
                      ),
                    ),
                    Text("₹"+data["price"].toString(),
                      style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 28
                      ),
                    ),
                  ],
                ):const SizedBox(),
                data["BookingDetail"]["status"]!="Live"&&data["BookingDetail"]["status"]!="Cancel"&&data["BookingDetail"]["status"]!="Completed"?
                GestureDetector(
                  onTap: _showCancelDialog,
                  child: const Text(
                    "Cancel Ride",
                    style: TextStyle(color: Colors.red),
                  ),
                ):const SizedBox(),
              ],
            ),
          ),

          data["BookingDetail"]["status"]=="Live" || data["BookingDetail"]["status"]=="Booked"|| data["BookingDetail"]["status"]=="Assigned"?
          Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  children: [
                    Text("Start OTP",
                      style: TextStyle(
                          color: Colors.grey.shade800,
                          fontWeight: FontWeight.bold,
                          fontSize: 16
                      ),
                    ),
                    Text(data["start_otp"].toString()),
                  ],
                ),
                // Column(
                //   children: [
                //     Text("End OTP",
                //         style: TextStyle(
                //             color: Colors.grey.shade800,
                //             fontWeight: FontWeight.bold,
                //             fontSize: 16
                //         )
                //     ),
                //     Text(data["end_otp"].toString()),
                //   ],
                // ),
              ],
            ),
          )
              :SizedBox(),
        ],
      ),
    );
  }


  Widget BikeDetails(){
    return Column(
      children: [
        Container(
          color: Colors.white,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                color: _color ,
                child:data["BookingDetail"]!=null? Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Text("Booking No ",
                            style: const TextStyle(
                                color: Colors.white
                            ),
                          ),
                          Text(data["BookingDetail"]["bookingNo"].toString(),
                            style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                color: Colors.white
                            ),
                          ),
                        ],
                      ),
                      Text(data["BookingDetail"]["status"].toString(),
                        style: const TextStyle(
                            color: Colors.white
                        ),
                      )
                    ],
                  ),
                ):const SizedBox(),
              ),
              const SizedBox(
                height: 4,
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0,),
                child: Text(widget.type,
                  style:const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const Icon(Icons.location_on),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(data["BookingDetail"]["from"].toString(),
                            style:const  TextStyle(
                              color: Colors.grey,
                            ),
                          ),
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
                        Expanded(
                          child: Text(
                            data["BookingDetail"]["to"].toString(),
                            style: const TextStyle(
                                color: Colors.grey
                            ),
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 8),
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  children: [
                    const Text(
                      "Date: ",
                      style: TextStyle(color: Colors.grey),
                    ),
                    Text(
                      data["BookingDetail"]["date"].split(" ")[0],
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ),

              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    data["BookingDetail"]["price"].toString()!="null"? Column(
                      children: [
                        Text("Ride Amount",
                          style: TextStyle(
                              color: Colors.grey,
                              fontWeight: FontWeight.bold,
                              fontSize: 10
                          ),
                        ),
                        Text("₹"+double.parse(data["BookingDetail"]["price"].toString()).toStringAsFixed(2),
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontSize: 28
                          ),
                        ),
                      ],
                    ):const SizedBox(),
                    data["BookingDetail"]["status"]!="Live"&&data["BookingDetail"]["status"]!="Cancel"&&data["BookingDetail"]["status"]!="Completed"?
                    GestureDetector(
                      onTap: _showCancelDialog,
                      child: const Text(
                        "Cancel Ride",
                        style: TextStyle(color: Colors.red),
                      ),
                    ):const SizedBox(),
                  ],
                ),
              ),

              data["BookingDetail"]["status"]=="Live" || data["BookingDetail"]["status"]=="Booked"|| data["BookingDetail"]["status"]=="Assigned"?
              Padding(
                padding: const EdgeInsets.all(8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      children: [
                        Text("Start OTP",
                          style: TextStyle(
                              color: Colors.grey.shade800,
                              fontWeight: FontWeight.bold,
                              fontSize: 16
                          ),
                        ),
                        Text(data["start_otp"].toString()),
                      ],
                    ),
                    // Column(
                    //   children: [
                    //     Text("End OTP",
                    //         style: TextStyle(
                    //             color: Colors.grey.shade800,
                    //             fontWeight: FontWeight.bold,
                    //             fontSize: 16
                    //         )
                    //     ),
                    //     Text(data["end_otp"].toString()),
                    //   ],
                    // ),
                  ],
                ),
              )
                  :SizedBox(),
            ],
          ),
        ),


        if(data["BookingDetail"]["status"]=="Created" )
          Column(
            children: [
              SizedBox(
                height: 34,
              ),
              const Text("Captain is coming please wait",
                style: TextStyle(
                    fontWeight: FontWeight.bold,
                    color: Colors.red
                ),
              ),
              TimerProgressIndicator(onComplete: (){
                _showAlertDialog(context, "Sorry", "Caption is not available on this root right now.\n You can create another ride.");
                cancelBikeRide("Expired","Expired");
              },
                initialMinutes: calculateTimeDifference(DateTime.parse(data["BookingDetail"]["date"])),
              ),
            ],
          )

      ],
    );
  }






  @override

  Widget build(BuildContext context) {


      try{
        return Scaffold(
          appBar: AppBar(
            title: Text("Booking Details"),
            centerTitle: true,
            forceMaterialTransparency: true,
            backgroundColor:const Color(0xffF6F6F6),
          ),
          body:loaded? SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(

                children: [
                  if(widget.type=="Taxi" ||widget.type=="taxi")taxiDetails(),
                  if(widget.type=="Truck" ||widget.type=="truck")truckDetails(),
                  if(widget.type=="Bike" ||widget.type=="bike")BikeDetails(),
                  if(widget.type=="Auto" ||widget.type=="Auto")BikeDetails(),
                  SizedBox(
                    height: 16,
                  ),
                  priceList != null
                      ? priceList!.isNotEmpty?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Available Prices",
                        style: TextStyle(
                            fontWeight: FontWeight.bold
                        ),
                      ),
                      SizedBox(
                        height: 8,
                      ),
                      ListView.builder(
                          physics: const NeverScrollableScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: priceList!.length,
                          itemBuilder: (context, index) {
                            if(priceList![index]["Price"].toString()=="N/A"){
                              return SizedBox();
                            }
                            return GestureDetector(
                              onTap: ()=> _showPriceDialog(priceList![index]["ownerId"],priceList![index]["Price"]),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(vertical: 8.0),
                                child: Container(
                                  padding: const EdgeInsets.all(8.0),
                                  color: Colors.white,
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(child: Text("Name",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )),
                                          Expanded(flex: 3,child: Text(priceList![index]["ownerName"].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold
                                            ),
                                          )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        children: [
                                          Expanded(child: Text("Company",
                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          )),
                                          Expanded(flex: 3,child:Text(priceList![index]["ownerCompanyName"].toString() ,
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold
                                            ),
                                          )),
                                        ],
                                      ),
                                      SizedBox(
                                        height: 4,
                                      ),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          Expanded(child: Text("Price",

                                            style: TextStyle(
                                              color: Colors.grey,
                                            ),
                                          ),),
                                          Expanded(flex: 3,child: Text("₹"+priceList![index]["Price"].toString(),
                                            style: TextStyle(
                                                fontWeight: FontWeight.bold
                                            ),
                                          )),
                                        ],
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            );
                          }),
                    ],
                  ):data["BookingDetail"]["status"]=="Created"?  Text("Please wait for price"):SizedBox()
                      :data["BookingDetail"]["status"]=="Created"? Text("Please wait for price"):SizedBox(),



                  data["driver_details"].toString()!="[]"&&data!=null?Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Driver Details",style: TextStyle(
                          fontWeight: FontWeight.bold
                      ),),
                      Container(
                          margin:const EdgeInsets.symmetric(vertical: 8),
                          width: MediaQuery.sizeOf(context).width,
                          color: Colors.white,
                          child:Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [

                                Row(
                                  children: [
                                    Expanded(child: Text("Name",

                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    ),),
                                    Expanded(flex: 5,child: Text(data["driver_details"]["name"].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),
                                    )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text("Email",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )),
                                    Expanded(flex: 5,child: Text(data["driver_details"]["email"].toString(),
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),
                                    )),
                                  ],
                                ),
                                Row(
                                  children: [
                                    Expanded(child: Text("Phone",
                                      style: TextStyle(
                                        color: Colors.grey,
                                      ),
                                    )),
                                    Expanded(flex: 5,child:Text(data["driver_details"]["phone"].toString() ,
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold
                                      ),
                                    )),
                                  ],
                                ),
                              ],
                            ),
                          )
                      ),
                    ],
                  ):SizedBox(),
                  data["BookingDetail"]["status"].toString()=="Live"?
                  // SizedBox(
                  //   height: MediaQuery.sizeOf(context).height/6,
                  //   width: MediaQuery.sizeOf(context).width,
                  //   child: LiveLocationMap(destination: data["BookingDetail"]["to"].toString(),),
                  // )
                  ElevatedButton(
                      style: ButtonStyle(
                          backgroundColor: WidgetStateProperty.resolveWith<Color?>(
                                (Set<WidgetState> states) {
                              if (states.contains(WidgetState.pressed)) {
                                return Theme.of(context).colorScheme.primary.withOpacity(0.5);
                              }
                              return Theme.of(context).colorScheme.primary; // Use the component's default.
                            },
                          )
                      ),
                      onPressed: (){
                        debugPrint(data["BookingDetail"]["to_location"].toString()+
                        data["BookingDetail"]["from_location"].toString(),);
                        debugPrint(data.toString());
                        GoRouter.of(context).pushNamed("LiveLocationMap",


                            pathParameters: {
                              "des":data["BookingDetail"]["to_location"].toString(),
                              "from":data["BookingDetail"]["from_location"].toString(),
                              "id":data["BookingDetail"]["id"].toString(),
                              "type":widget.type
                            }
                        );
                      },
                      child: Text("Live Map",style: TextStyle(color: Colors.white),)
                  )
                      :SizedBox()

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

  double calculateTimeDifference(DateTime dateTime) {
    const int maxMinutes = 4; // Maximum time is 4 minutes
    DateTime currentTime = DateTime.now();

    // Calculate the difference in seconds
    int differenceInSeconds = currentTime.difference(dateTime).inSeconds;

    // Convert the difference to minutes
    double differenceInMinutes = differenceInSeconds / 60;

    // Return the difference if less than 4 minutes, otherwise return 4.0
    if (differenceInMinutes < maxMinutes) {
      return differenceInMinutes;
    } else {
      return maxMinutes.toDouble();
    }
  }

}



class TimerProgressIndicator extends StatefulWidget {
  final double initialMinutes; // Add this to accept initial time
  final VoidCallback? onComplete;

  TimerProgressIndicator({required this.initialMinutes, this.onComplete});

  @override
  _TimerProgressIndicatorState createState() => _TimerProgressIndicatorState();
}

class _TimerProgressIndicatorState extends State<TimerProgressIndicator> {
  static const int maxDuration = 4 * 60; // 4 minutes in seconds
  late double elapsedSeconds;
  Timer? _timer;

  IO.Socket? _socket;

  @override
  void initState() {
    super.initState();
    // Set elapsedSeconds based on the initialMinutes
    elapsedSeconds = (widget.initialMinutes * 60);
    startTimer();
  }

  void startTimer() {
    _timer = Timer.periodic(Duration(seconds: 1), (timer) {
      setState(() {
        elapsedSeconds++;
        if (elapsedSeconds >= maxDuration) {
          timer.cancel();
          if (widget.onComplete != null) {
            widget.onComplete!(); // Call the onComplete function
          }
        }
      });
    });
  }

  double get _progressValue {
    return elapsedSeconds / maxDuration;
  }

  @override
  void dispose() {
    _timer?.cancel();
    _socket!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          LinearProgressIndicator(
            value: _progressValue,
            backgroundColor: Colors.grey[300],
            valueColor: AlwaysStoppedAnimation<Color>(Color(0xff7BDD0A)),
            minHeight: 10,
          ),
          SizedBox(height: 20),
          Text(
            '${(maxDuration - elapsedSeconds) ~/ 60} min ${(maxDuration - elapsedSeconds) % 60} sec',
            style: TextStyle(fontSize: 20),
          ),
        ],
      ),
    );
  }
}
