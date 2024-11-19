import 'package:flutter/material.dart';

class ImageView extends StatelessWidget {
  final String image;
  const ImageView({super.key , required this.image});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: SafeArea(
        child: Center(child: Image.network(image)),
      ),
    );
  }
}
