import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:package_info_plus/package_info_plus.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {

  @override
  void initState() {
    super.initState();
    _checkVersionAndNavigate();
  }

  Future<void> _checkVersionAndNavigate() async {
    final connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      _showNoInternetDialog();
      return;
    }

    final packageInfo = await PackageInfo.fromPlatform();
    final currentVersion = packageInfo.version;


   try{

     final response = await http.get(Uri.parse('https://${dotenv.env['API']}/versionCheck'));
     if (response.statusCode == 200) {
       final data = jsonDecode(response.body);
       final latestVersion = data['version'];

       if (_isUpdated(currentVersion, latestVersion) || data['skip']) {
         GoRouter.of(context).goNamed('login');
       } else {
         GoRouter.of(context).goNamed('UpdatePage');
       }
     } else {
       _showNoInternetDialog();
     }
   }catch(e){
     _checkVersionAndNavigate();
   }
  }

  bool _isUpdated(String currentVersion, String latestVersion) {
    final currentParts = currentVersion.split('.').map(int.parse).toList();
    final latestParts = latestVersion.split('.').map(int.parse).toList();

    for (int i = 0; i < latestParts.length; i++) {
      if (i >= currentParts.length || currentParts[i] < latestParts[i]) {
        return false;
      } else if (currentParts[i] > latestParts[i]) {
        return true;
      }
    }

    return currentParts.length >= latestParts.length;
  }

  void _showNoInternetDialog() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('No Internet Connection'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: MediaQuery.sizeOf(context).height,
      width: MediaQuery.sizeOf(context).width,
      color: const Color(0xff7BDD0A),
      child: Center(
        child: Image.asset("assets/whiteLogo.png"),
      ),
    );
  }
}
