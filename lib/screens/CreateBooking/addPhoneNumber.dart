import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/login.dart';
import 'package:http/http.dart' as http;

class PhoneNumberPage extends StatefulWidget {
  const PhoneNumberPage({super.key});
  @override
  _PhoneNumberPageState createState() => _PhoneNumberPageState();
}

class _PhoneNumberPageState extends State<PhoneNumberPage> {
  final _formKey = GlobalKey<FormState>();
  final _phoneController = TextEditingController();
  final _otpController = TextEditingController();
  Timer? _timer;
  int _start = 60;

  UserData _user = UserData();

  bool _isPhoneValid = false;
  bool _isOtpValid = false;
  bool _isSendOtpButtonDisabled = false;
  bool _isSubmitButtonDisabled = true;
  bool _showGuidanceText = false;

  @override
  void dispose() {
    _phoneController.dispose();
    _otpController.dispose();
    _timer?.cancel();
    super.dispose();
  }

  void _validatePhoneNumber(String value) {
    setState(() {
      _isPhoneValid = value.length == 10 && RegExp(r'^\d{10}$').hasMatch(value);
      // _isSendOtpButtonDisabled = !_isPhoneValid;
      _checkSubmitButtonState();
    });
  }

  void _validateOtp(String value) {
    setState(() {
      _isOtpValid = value.length == 6 && RegExp(r'^\d{6}$').hasMatch(value);
      _checkSubmitButtonState();
    });
  }

  void _checkSubmitButtonState() {
    setState(() {
      _isSubmitButtonDisabled = !(_isPhoneValid && _isOtpValid);
    });
  }

  void _startTimer() {
    const oneSec = Duration(seconds: 1);
    _timer = Timer.periodic(
      oneSec,
          (Timer timer) {
        if (_start == 0) {
          setState(() {
            _isSendOtpButtonDisabled = false;
            _start = 60;
            timer.cancel();
          });
        } else {
          setState(() {
            _start--;
          });
        }
      },
    );
  }

  void _sendOtp() async {
    _validatePhoneNumber(_phoneController.text);
    debugPrint("started");
    if (!_isPhoneValid){
      _showNumberNotValid();
      return;
    }

    debugPrint("reached here");
    final token = _user.get("token").trim();

    http.Response res = await http.post(Uri.parse("https://m.osat.in/api/user/sendOtp?user_id=${_user.get("id")}&phone=${_phoneController.text}"),
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );

    print(res.body);
    if(res.statusCode==200){
      if(jsonDecode(res.body)['status']==0){
        _showOtpDialog(jsonDecode(res.body)['message']);
      }else{
        // Logic to send OTP via API call can be added here
        setState(() {
          _isSendOtpButtonDisabled = true;
          _startTimer();
        });
      }
    }


  }


  Future<void> _showOtpDialog(message) async {
    return showDialog<void>(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('OTP Alert'),
          content:  SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                Text(message.toString()),
              ],
            ),
          ),
        );
      },
    );
  }




  void submit() async {
    if (_isSubmitButtonDisabled) return;

    Uri url = Uri.https(
      dotenv.env['DOMAIN']!,
      "/api/user/addUserPhone",
      {
        "user_id": _user.get("id").toString(),
        "phone": _phoneController.text.toString(),
        "otp": _otpController.text.toString(),
      },
    );
    final token = _user.get("token").trim();

    http.Response response = await http.post(
      url,
      headers: {
        HttpHeaders.authorizationHeader: 'Bearer $token',
      },
    );
    var data = jsonDecode(response.body);

    if (data["message"] == "success") {
      context.pop();
    } else {
      print(data.toString());
      _showSomethingWentWrongDialog(data["message"]);
    }
  }

  void _showSomethingWentWrongDialog(message) {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: '⚠️ Oops! Something went wrong. 😔 Please try again later.'),
                TextSpan(text: message),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showNumberNotValid() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          content: RichText(
            text: TextSpan(
              style: Theme.of(context).textTheme.bodyLarge,
              children: [
                TextSpan(text: _phoneController.text.isNotEmpty?'${_phoneController.text} is not valid.':'Please enter phone number first.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: Text('OK'),
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
        title: Text('Submit Details'),
        centerTitle: true,
        forceMaterialTransparency: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: Column(
            children: <Widget>[
              Padding(
                padding: const EdgeInsets.only(bottom: 16.0),
                child: Text(
                  'Once verified, your phone number cannot be changed. If you need to update it in the future, please contact OSAT support.',
                  style: TextStyle(fontSize:  12),
                ),
              ),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                    bottom: BorderSide()
                  ),
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: TextFormField(
                        maxLength: 10,
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: 'Phone Number',
                          border: InputBorder.none,
                          counterText: ""
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your phone number';
                          }
                          if (value.length != 10 || !RegExp(r'^\d{10}$').hasMatch(value)) {
                            return 'Please enter a valid 10-digit phone number';
                          }
                          return null;
                        },
                        // onChanged: (value){
                        //   if(value.length == 10){
                        //     setState(() {
                        //       _isPhoneValid=true;
                        //     });
                        //   }
                        // },
                      ),
                    ),
                    SizedBox(width: 8),
                    GestureDetector(
                      // style: ElevatedButton.styleFrom(
                      //   backgroundColor: Colors.transparent,
                      //   elevation: 0,
                      //   foregroundColor: Color(0xff7BDD0A),
                      //   padding: EdgeInsets.zero
                      // ),
                      onTap: _isSendOtpButtonDisabled ? null : _sendOtp,
                      child: _isSendOtpButtonDisabled
                          ? Text('Wait $_start s')
                          : Text('Send OTP',
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xff7BDD0A)
                            ),
                      ),

                    ),
                  ],
                ),
              ),
              SizedBox(height: 20),
              Container(
                padding: EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  border: Border(
                      bottom: BorderSide()
                  ),
                ),
                child: TextFormField(
                  controller: _otpController,
                  decoration: InputDecoration(
                    labelText: 'Enter OTP',
                    border: InputBorder.none,
                    counterText: ""
                  ),
                  keyboardType: TextInputType.number,
                  maxLength: 6,
                  onChanged: _validateOtp,
                ),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.black,
                  foregroundColor: Colors.white
                ),
                onPressed: _isSubmitButtonDisabled ? null : submit,
                child: Text('Submit'),
              ),
              if (_showGuidanceText && _isSubmitButtonDisabled)
                Padding(
                  padding: const EdgeInsets.only(top: 8.0),
                  child: Text(
                    'Please enter a valid phone number and OTP to enable the submit button.',
                    style: TextStyle(color: Colors.red),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
