import 'package:flutter/material.dart';

class ErrorPage extends StatelessWidget {

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(Icons.error, color: Colors.red, size: 80),
            SizedBox(height: 16),
            Text(
              'Something went wrong!',
              style: TextStyle(fontSize: 24, color: Colors.red),
            ),
            SizedBox(height: 8),
            Text(
              'Please try again later.',
              style: TextStyle(fontSize: 16),
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                // Optionally, add a retry function here
                Navigator.pop(context);
              },
              child: Text('Go Back'),
            ),
          ],
        ),
      ),
    );
  }
}