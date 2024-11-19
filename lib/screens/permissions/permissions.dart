import 'dart:async';

import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:permission_handler/permission_handler.dart';

class LocationPermissionScreen extends StatefulWidget {

  const LocationPermissionScreen({super.key});

  @override
  State<LocationPermissionScreen> createState() => _LocationPermissionScreenState();
}

class _LocationPermissionScreenState extends State<LocationPermissionScreen> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    Timer.periodic(Duration(seconds: 1), (timer) {if(mounted){permissions(context); }});
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Location Permission Required'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            RichText(
              text: TextSpan(
                text: 'To access all functionalities of our app, please ',
                style: TextStyle(
                  fontSize: 18.0,
                  color: Colors.black87,
                  height: 1.5,
                ),
                children: <TextSpan>[
                  TextSpan(
                    text: 'click on the "Enable Location Permission" button, then ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'go to '),
                  TextSpan(
                    text: 'Permissions, ',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  TextSpan(text: 'and finally '),
                  TextSpan(
                    text: 'enable location permission.',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(height: 24.0),
            ElevatedButton(
              onPressed: () {
                openAppSettings();
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.black,
                padding: EdgeInsets.symmetric(vertical: 16.0),
              ),
              child: Text(
                'Enable Location Permission',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 18.0,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void permissions(context)async{
    PermissionStatus status = await Permission.location.status;

    if (status.isGranted) {
      GoRouter.of(context).goNamed("Navigation");

    }else{
      return;
    }
  }
}