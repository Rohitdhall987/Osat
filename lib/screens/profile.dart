import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:osat/screens/ErrorPage.dart';
import 'package:osat/screens/login.dart';
import 'package:url_launcher/url_launcher.dart';

class Profile extends StatefulWidget {
  const Profile({super.key});

  @override
  State<Profile> createState() => _ProfileState();
}

class _ProfileState extends State<Profile> {
  final GoogleSignIn _googleSignIn=GoogleSignIn();

  UserData _data=UserData();

  @override
  Widget build(BuildContext context) {
    try{
      return Scaffold(
        appBar: AppBar(
          centerTitle: true,
          title: const Text(
            "OSAT",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: Colors.white,
          forceMaterialTransparency: true,
        ),
        body: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0,horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Profile",
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.sizeOf(context).width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text("Hi, ${_data.get("name")}",
                        style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 18
                        ),
                      ),
                      const SizedBox(
                        height: 4,
                      ),
                      Text(_data.get("email"),
                        style:const TextStyle(
                            color: Colors.grey
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(
                  height: 16,
                ),
                Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(16.0),
                  width: MediaQuery.sizeOf(context).width,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      GestureDetector(
                        onTap: ()async{
                          String _url="https://osat.in/terms.php";
                          if (!await launchUrl(Uri.parse(_url))) {
                            throw Exception('Could not launch $_url');
                          }
                        },
                        child: const Text("Terms & Conditions",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const Divider(),
                      GestureDetector(
                        onTap: ()async{
                          String _url="https://osat.in/privacy.php";
                          if (!await launchUrl(Uri.parse(_url))) {
                            throw Exception('Could not launch $_url');
                          }
                        },
                        child: const Text("Privacy policy",
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      Center(
                        child: GestureDetector(
                            onTap: ()=> _googleSignIn.signOut().then((value) => GoRouter.of(context).goNamed("login")),
                            child:const  Text("Sign out",
                              style: TextStyle(
                                  fontWeight: FontWeight.bold
                              ),
                            )
                        ),
                      ),
                      const SizedBox(
                        height: 16,
                      ),
                      const  Center(
                        child: Text("Version 1.0.17"),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      );
    }catch(e){
      return ErrorPage();
    }
  }
}
