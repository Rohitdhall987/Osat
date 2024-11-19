
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class Success extends StatefulWidget {
  final String bookingId;
  final String bookingNo;
  final String type;
  const Success({super.key,required this.bookingId, required this.bookingNo,required this.type});

  @override
  State<Success> createState() => _SuccessState();
}

class _SuccessState extends State<Success> {





  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body:Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.check_circle,color: Color(0xff01C042),
              size: 100,
            ),
            const Text("Booking Created Successfully",
              style: TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 16
              ),
            ),
            Text("Booking no. ${widget.bookingNo}",
              style: const TextStyle(
                color: Colors.grey
              ),
            ),
            const SizedBox(
              height: 20,
            ),
            GestureDetector(
              onTap: (){
                GoRouter.of(context).pushReplacementNamed("SingleBookingDetails",
                    pathParameters: {
                      "type":widget.type,
                      "id":widget.bookingId,
                    }
                );
              },
              child: Container(
                width: MediaQuery.sizeOf(context).width/2,
                decoration: BoxDecoration(
                  color: Colors.black,
                  borderRadius: BorderRadius.circular(5),
                ),
                padding: const EdgeInsets.all(16),
                child: const Center(
                  child: Text("View Details",
                    style: TextStyle(
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
