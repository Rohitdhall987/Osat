
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:hive/hive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:http/http.dart' as http;

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  late PackageInfo packageInfo;
  bool userNull = true;
  GoogleSignInAccount? _user;
  late bool isIOS;
  late bool _disposed;

  var box = Hive.box('userData');

  // List<String> scopes = <String>[
  //   'email',
  //   'https://www.googleapis.com/auth/contacts.readonly',
  // ];
  //
  GoogleSignIn _googleSignIn = GoogleSignIn();

  @override
  void initState() {
    super.initState();

    _disposed = false;
    isIOS = false; // Set this to true if needed

    authStateChange();
  }

  @override
  void dispose() {
    _disposed = true;
    super.dispose();
  }

  Future<void> _handleSignIn() async {
    try {
      await _googleSignIn.signIn();
    } catch (error) {
      // Handle error
      //debugdebugPrint("==================$error");
    }
  }

  void authStateChange() async {

    _googleSignIn.signInSilently();
  try{
    if(!(await _googleSignIn.isSignedIn())){
      if(mounted){
        setState(() {
          //debugPrint("dsghsdghdsghsdhgdshsdgdsghhsdgghds");
          userNull=false;
        });
      }
    }
  }catch(e){
    if(mounted){
      setState(() {
        userNull=false;
      });
    }
  }
    _googleSignIn.onCurrentUserChanged.listen((user) async {
      //debugPrint(user);
      //debugPrint(userNull);
      if (!_disposed) {
        _user = user;
        if (_user != null) {
          setState(() {
            userNull = true;
          });
          await _registerUser();




        } else {
          setState(() {
            userNull = false;
          });
        }
      }
    });


  }

  Future<void> _registerUser() async {
    if (_user == null) return;

    try {
      final result = await http.post(Uri.parse("https://${dotenv.env['DOMAIN']!}/api/UserRegister?email=${_user!.email}&uid=${_user!.id}"));

      if (result.statusCode == 200) {
        UserData _data=UserData();
        UserData.add("token", jsonDecode(result.body)["token"]);
        UserData.add("name", jsonDecode(result.body)["user"]["name"]);
        UserData.add("email", jsonDecode(result.body)["user"]["email"]);
        UserData.add("uid", jsonDecode(result.body)["user"]["uid"]);
        UserData.add("id", jsonDecode(result.body)["user"]["id"]);
        GoRouter.of(context).goNamed('Navigation');
        debugPrint("here-----");


        try{
          if(box.get("token")==null){
            http.Response tokenResponse=await http.post(Uri.parse("https://${dotenv.env["NOTIFICATION_URL"]}/setToken_OSAT_USER"),
                body: {
                  "Token":_data.get("msgToken"),
                  "Id":jsonDecode(result.body)["user"]["id"].toString(),
                }
            );


            var tknres=json.decode(tokenResponse.body);

            if(tknres["Status"]==1){

              box.put("token", _data.get("msgToken"));
            }else{
              updateToken(_data.get("msgToken"),jsonDecode(result.body)["user"]["id"].toString());
            }
          }
          else if(!(box.get("token")==_data.get('msgToken'))){
            updateToken(_data.get('msgToken'),jsonDecode(result.body)["user"]["id"].toString());
          }
        }catch(e){
          debugPrint("error----");
          debugPrint(e.toString());
        }

      } else {
        //debugPrint('Failed to register user: ${result.statusCode}');
        //debugPrint('Response body: ${result.body}');
        showStatusCodeInvalidAlert();
      }
    } catch (e) {
      //('Error occurred during registration: $e');
    }
  }


  void updateToken(token,id)async{
    var res=await http.post(Uri.parse("https://${dotenv.env["NOTIFICATION_URL"]}/UpdateToken_OSAT_USER"),
        body: {
          "Token":token,
          "Id":id,
        }
    );
    // print(res.body)
  }


  void showStatusCodeInvalidAlert() {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Status Code Invalid'),
        content: const Text('Please check your internet connection and try again.'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop();
              exit(0);
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset('assets/logo.png', width: MediaQuery.of(context).size.width / 2),
            SizedBox(height: MediaQuery.of(context).size.height / 100),
            Text(
              'Have a better sharing experience',
              style: GoogleFonts.inter(fontSize: 12, fontWeight: FontWeight.w500),
            ),
            SizedBox(height: MediaQuery.of(context).size.height / 30),
            Padding(
              padding: const EdgeInsets.all(24.0),
              child:!userNull? GestureDetector(
                onTap: _handleSignIn,
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(width: 1),
                    borderRadius: BorderRadius.circular(5),
                  ),
                  padding: const EdgeInsets.all(12.0),
                  child: Row(
                    children: [
                      Image.asset('assets/g.png', scale: 8),
                      SizedBox(width: MediaQuery.of(context).size.width / 8),
                      const Text('Sign in with Google', style: TextStyle(fontWeight: FontWeight.bold)),
                    ],
                  ),
                ),
              ):const Center(child: CircularProgressIndicator(),),
            ),
            // Padding(
            //   padding: const EdgeInsets.symmetric(vertical: 0.0,horizontal: 24),
            //   child:GestureDetector(
            //     onTap: _handleSignIn,
            //     child: Container(
            //       decoration: BoxDecoration(
            //         border: Border.all(width: 1),
            //         borderRadius: BorderRadius.circular(5),
            //       ),
            //       padding: const EdgeInsets.all(12.0),
            //       child: Row(
            //         children: [
            //           Image.asset('assets/g.png', scale: 8),
            //           SizedBox(width: MediaQuery.of(context).size.width / 8),
            //           const Text('Register with Google', style: TextStyle(fontWeight: FontWeight.bold)),
            //         ],
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      ),
    );
  }
}

class UserData{
  static final Map<String,dynamic> _data={};
  static void clear(){
    _data.clear();
  }

  static void add(String key ,dynamic value){
    _data.addAll({key:value});
  }
  dynamic get(String key ){
    return _data[key];
  }
}
