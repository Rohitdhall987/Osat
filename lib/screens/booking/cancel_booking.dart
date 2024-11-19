import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/login.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

class CancelBookingPage extends StatefulWidget {
  const CancelBookingPage({super.key});
  @override
  State<CancelBookingPage>  createState() => _CancelBookingPageState();
}

class _CancelBookingPageState extends State<CancelBookingPage> {
  TextEditingController otpController = TextEditingController();
  
  final UserData _data=UserData();

  void _showCancelDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          surfaceTintColor: Colors.white,
          title: Text('Are you sure?'),
          content: Text('Are you sure you want to cancel your ride?'),
          actions: <Widget>[
            TextButton(
              child: Text('Cancel Ride'),
              style: TextButton.styleFrom(
                backgroundColor: Colors.transparent,
                foregroundColor: Colors.red,
              ),
              onPressed: () {
                GoRouter.of(context).pushNamed("RideCancelledPage");
                Navigator.of(context).pop();
                // Add your cancel ride logic here
                //print("Ride cancelled");
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
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        forceMaterialTransparency: true,
        title: const Text('Cancel Booking'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
           const Text(
              'Enter OTP to cancel ride',
              style: TextStyle(fontSize: 22.0,
                fontWeight: FontWeight.bold
              ),
            ),
            const SizedBox(height: 8),
             Text(
              'OTP sent to your email ${_data.get("email")}',
              style:const TextStyle(
                color: Colors.grey
              ),
            ),
            const SizedBox(height: 20),
            PinCodeTextField(
              appContext: context,
              length: 6,
              controller: otpController,
              onChanged: (value) {},
              pinTheme: PinTheme(
                inactiveColor: Colors.black,
                activeColor: const Color(0xff7BDD0A),
                shape: PinCodeFieldShape.box,
                borderRadius: BorderRadius.circular(5),
                fieldHeight: 50,
                fieldWidth: 40,
                activeFillColor: Colors.white,
              ),
              onCompleted: (value) {
                // You can add additional actions when the OTP is completed
               // print("Completed: " + value);
              },
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black, // background (button) color
                foregroundColor: Colors.white, // foreground (text) color
                padding: const EdgeInsets.symmetric(horizontal: 30, vertical: 15),

              ),
              onPressed: () {
                _showCancelDialog();
              },
              child:const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}