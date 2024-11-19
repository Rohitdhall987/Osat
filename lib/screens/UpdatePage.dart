import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class UpdatePage extends StatelessWidget {
  const UpdatePage({super.key});
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Update Required'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'The app is not updated. Please go to the Play Store and update the app.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  String _url="https://play.google.com/store/games?hl=en";
                  if (!await launchUrl(Uri.parse(_url))) {
                    throw Exception('Could not launch $_url');
                  }
                },
                child: Text('Go to Play Store'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}