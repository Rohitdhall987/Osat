import 'package:flutter/material.dart';

class Failed extends StatefulWidget {
  const Failed({super.key,});

  @override
  State<Failed> createState() => _FailedState();
}

class _FailedState extends State<Failed> {
  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
             Icon(Icons.cancel,color: Color(0xffED2749),
              size: 100,
            ),
             Text("Booking Not Created",
              style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 16
              ),
            ),
            Text("Problem to create booking ",
              style:  TextStyle(
                  color: Colors.grey
              ),
            ),
             SizedBox(
              height: 20,
            ),
          ],
        ),
      ),
    );
  }
}
