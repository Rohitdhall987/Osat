
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:osat/screens/SelectLocation.dart';
import 'package:osat/screens/login.dart';
import 'package:http/http.dart'as http;
import 'package:path/path.dart' as path;


class TruckBooking extends StatefulWidget {
  const TruckBooking({super.key});

  @override
  State<TruckBooking> createState() => _TruckBookingState();
}

class _TruckBookingState extends State<TruckBooking> {



  DateTime _leavingDate=DateTime.now();

  TextEditingController quantity=TextEditingController();
  TextEditingController description=TextEditingController();


  File? _selectedImage;

  final UserData _user=UserData();

  bool loading=true;


  double? originLat;
  double? originLng;
  double? destLat;
  double? destLng;


  // New variables for unit selection
  String? selectedUnit;
  List<String> units = ['kg', 'grams', 'pieces', 'liters']; // Example units


  String toLocation="To";
  String fromLocation="From";


  @override
  void initState() {

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
      setState((){
        loading=true;
      });
    }




  }



  Future<void> _getImageFromGallery() async {
    final picker = ImagePicker();
    final pickedImage = await picker.pickImage(source: ImageSource.gallery);
    if (pickedImage != null) {
      setState(() {
        _selectedImage = File(pickedImage.path);
      });
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
                TextSpan(text: ', '),
                TextSpan(
                  text: 'to',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ', '),
                TextSpan(
                  text: 'weight',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ', and '),
                TextSpan(
                  text: 'description',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' fields.'),
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

  void _showSameLocationDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(
                  text: 'From',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' and '),
                TextSpan(
                  text: 'to',
                  style: TextStyle(fontWeight: FontWeight.bold),
                ),
                TextSpan(text: ' field have some location please change.'),
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
    if(fromLocation=="From" || toLocation=="To" || quantity.text.isEmpty || description.text.isEmpty){
      _showLocationRequiredDialog();
      return;
    }

    if( fromLocation == toLocation){
      _showSameLocationDialog();
      return;
    }

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

    setState((){
      loading=false;
    });

    // Create a multipart request
    var request = http.MultipartRequest('POST', Uri.https(
      dotenv.env['DOMAIN']!,
      "/api/user/bookTransportBooking",
    ));



    // Attach other form fields
    request.fields['user_id'] = _user.get("id").toString();
    request.fields['from'] = fromLocation;
    request.fields['to'] = toLocation;
    request.fields['date'] = "${_leavingDate.day}-${_leavingDate.month}-${_leavingDate.year}";
    request.fields['materialQuantity'] = '${quantity.text} $selectedUnit';
    request.fields['description'] =description.text ;
    request.fields['country'] = country;
    request.fields['state'] = state==""? city: state;
    request.fields['city'] = city;
    request.fields['to_country'] = to_country;
    request.fields['to_state'] = to_state==""? to_city:to_state;
    request.fields['to_city'] = to_city;
    request.fields['from_location'] = "$originLat, $originLng";
    request.fields['to_location'] = "$destLat, $destLng";



    if(_selectedImage!=null){
      // Create a file object from the image path
      File imageFile = _selectedImage!;

      // Add the image file to the request
      request.files.add(http.MultipartFile(
        'materialImg',
        imageFile.readAsBytes().asStream(),
        imageFile.lengthSync(),
        filename: path.basename(imageFile.path),
      ));

    }
    // Set authorization header
    final token = _user.get("token").trim();
    request.headers[HttpHeaders.authorizationHeader] = 'Bearer $token';

    // Send the request
    var response = await request.send();

    setState((){
      loading=true;
    });


    // Check the response
    if (response.statusCode == 200) {
      // Handle successful response
      var responseData = await response.stream.bytesToString();
      var data = jsonDecode(responseData);
      // debugPrint(data);
      if(data["message"]=="success"){



        GoRouter.of(context).pushReplacementNamed("Success",
            pathParameters: {
              "id":data["booking_id"].toString(),
              "no":data["booking_number"].toString(),
              "type":"truck",
            }
        );
      } else {
         print(data.toString());
         print(request.url);
         print(request.headers);
         print(request.fields);
         print('${quantity.text} $selectedUnit');
        GoRouter.of(context).pushNamed("Failed");
      }
    } else {
      //var responseData = await response.stream.bytesToString();
      // var data = jsonDecode(responseData);
      //debugPrint(responseData);
      // Handle error response
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
               Row(
                children: [
                  const Text("Book Truck",
                    style: TextStyle(
                        fontSize: 20
                    ),
                  ),
                  const SizedBox(
                    width: 16,
                  ),
                  SizedBox(
                    height: 30,
                      child: Image.asset("assets/truck.png")
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
              Container(
                color: Colors.white,
                child: Column(
                  children: [
                    // Unit Selection Section
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "UNIT",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Select Unit",
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          // Dropdown for unit selection
                          DropdownButton<String>(
                            hint: const Text("Select Unit"),
                            value: selectedUnit,
                            items: units.map((unit) {
                              return DropdownMenuItem<String>(
                                value: unit,
                                child: Text(unit),
                              );
                            }).toList(),
                            onChanged: (String? value) {
                              setState(() {
                                selectedUnit = value;
                              });
                            },
                          ),
                        ],
                      ),
                    ),
                    const Divider(),

// Quantity Input Section
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "QUANTITY",
                                style: TextStyle(fontWeight: FontWeight.bold),
                              ),
                              Text(
                                "Enter Quantity",
                                style: TextStyle(fontSize: 10, color: Colors.grey),
                              ),
                            ],
                          ),
                          // Quantity input field
                          Row(
                            children: [
                              const SizedBox(width: 8),
                              Container(
                                width: 120,
                                height: 45,
                                decoration: BoxDecoration(
                                  border: Border.all(width: 0.5),
                                  borderRadius: BorderRadius.circular(100),
                                ),
                                child: Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 12.0),
                                  child: Center(
                                    child: TextFormField(
                                      controller: quantity,
                                      keyboardType: TextInputType.number,
                                      maxLength: 3,
                                      style: const TextStyle(color: Colors.grey),
                                      enabled: selectedUnit != null, // Enable only if unit is selected
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        counterText: "",
                                        hintText: "Quantity",
                                      ),
                                      textAlignVertical: TextAlignVertical.top,
                                    ),
                                  ),
                                ),
                              ),
                            ],
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
                                  showDatePicker(context: context, firstDate: _leavingDate, lastDate: DateTime(_leavingDate.year, _leavingDate.month + 1, _leavingDate.day)).then((value) =>{
                                    if(value!=null){
                                      setState(() {
                                        _leavingDate=value;
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
                    Padding(
                      padding: const EdgeInsets.all(12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text("IMAGE OF GOODS",
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              Text("What kind of load? (Optional)",
                                style: TextStyle(
                                    fontSize: 10,
                                    color: Colors.grey
                                ),
                              )
                            ],
                          ),
                          Row(
                            children: [
                              SizedBox(
                                height: 40,
                                child: _selectedImage != null
                                    ? Image.file(
                                  _selectedImage!,
                                )
                                    : Center(child: Text("X",style: TextStyle(fontSize: 24),)),
                              ),
                              IconButton(
                                onPressed: ()async{
                                 await _getImageFromGallery();
                                },
                                icon: const Icon(Icons.broken_image_outlined,),
                              )
                            ],
                          )
                        ],
                      ),
                    ),
                    
                  ],
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              const Text("Description",
                style: TextStyle(
                  fontWeight: FontWeight.bold
                ),
              ),
              Container(
                color: Colors.white,
                child:  Padding(
                  padding:const EdgeInsets.all(8.0),
                  child: TextField(
                    controller: description,
                    maxLines: 4, //or null
                    decoration:const InputDecoration.collapsed(hintText: "Enter your text here"),
                    maxLength: 200,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(vertical: 20.0),
                child: GestureDetector(
                  onTap:loading? createBooking:null,
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
