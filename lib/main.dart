import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:go_router/go_router.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/adapters.dart';
import 'package:osat/firebase_options.dart';
import 'package:osat/screens/AllLive.dart';
import 'package:osat/screens/CreateBooking/AutoBooking.dart';
import 'package:osat/screens/CreateBooking/BikeBooking.dart';
import 'package:osat/screens/CreateBooking/TaxiBooking.dart';
import 'package:osat/screens/CreateBooking/TruckBooking.dart';
import 'package:osat/screens/CreateBooking/addPhoneNumber.dart';
import 'package:osat/screens/HistoryScreens/History.dart';
import 'package:osat/screens/Imageview.dart';
import 'package:osat/screens/UpdatePage.dart';
import 'package:osat/screens/booking/AllOngingsBookings.dart';
import 'package:osat/screens/booking/SingleOngoingTaxi.dart';
import 'package:osat/screens/booking/cancel_booking.dart';
import 'package:osat/screens/booking/liveMap.dart';
import 'package:osat/screens/booking/single_booking_detail.dart';
import 'package:osat/screens/message/booked_successfully.dart';
import 'package:osat/screens/message/cancelled_successful.dart';
import 'package:osat/screens/message/failed.dart';
import 'package:osat/screens/message/success_created.dart';
import 'package:osat/screens/navigation.dart';
import 'package:osat/screens/permissions/permissions.dart';
import 'package:osat/screens/splash_screen.dart';
import 'package:osat/screens/login.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';

import "package:http/http.dart"as http;


Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
}


final navigatorKey = GlobalKey<NavigatorState>();
String? InitRoute="/";
var message;

const AndroidNotificationChannel channel = AndroidNotificationChannel(
  'high_importance_channel_omshribhakti', // id
  'high importance channel omshribhakti', // title

  importance: Importance.max,
  playSound: true,
  sound: RawResourceAndroidNotificationSound("notification"),
);

final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin = FlutterLocalNotificationsPlugin();

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: ".env");
  await Hive.initFlutter();
  await Hive.openBox('userData');
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);
  await flutterLocalNotificationsPlugin.resolvePlatformSpecificImplementation<AndroidFlutterLocalNotificationsPlugin>()?.createNotificationChannel(channel);

  await FirebaseMessaging.instance.setForegroundNotificationPresentationOptions(
    alert: true,
    badge: true,
    sound: true,
  );

  FirebaseMessaging.instance.requestPermission(
    announcement: true,
    alert: true,
    badge: true,
    carPlay: true,
    criticalAlert: true,
    provisional: true,
    sound: true,
  );
  message = await FirebaseMessaging.instance.getInitialMessage();
  if ( message != null && message.data['route'] !=null ){
    InitRoute = message.data['route'];
  }

  runApp(MyApp());
}

class MyApp extends StatefulWidget {
   MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {


  @override
  void initState() {
    super.initState();

    var initialzationSettingsAndroid =
    AndroidInitializationSettings('@mipmap/ic_launcher');
    var initializationSettings =
    InitializationSettings(android: initialzationSettingsAndroid);

    FirebaseMessaging.onMessage.listen((RemoteMessage message) async {
      RemoteNotification? notification = message.notification;
      AndroidNotification? android = message.notification?.android;
      if (notification != null && android != null) {
        flutterLocalNotificationsPlugin.show(
            notification.hashCode,
            notification.title,
            notification.body,
            NotificationDetails(
              android: AndroidNotificationDetails(
                channel.id,
                channel.name,
                color: Colors.blue,
                // TODO add a proper drawable resource to android, for now using
                //      one that already exists in example app.
                icon: "@mipmap/ic_launcher",
                playSound: true,
              ),
            ));

        await flutterLocalNotificationsPlugin.initialize(
            initializationSettings,
            onDidReceiveNotificationResponse: (payload){
            }
        );
      }

    });

    getToken();

  }

  String? token = "";
  getToken() async {
    token = await FirebaseMessaging.instance.getToken();



    UserData.add('msgToken',token);
    // http.Response tokenResponse=await http.post(Uri.parse("https://${dotenv.env["NOTIFICATION_URL"]}/getToken"),

     // debugPrint(token);
  }



  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: kDebugMode,
      theme: ThemeData(
        scaffoldBackgroundColor: const Color(0xffF6F6F6),
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xff7BDD0A),
          primary: Colors.black,
          secondary: Colors.white,
          surface:  const Color(0xffF6F6F6),
        ),
        useMaterial3: true,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      routerConfig: _router,
    );
  }

  final GoRouter _router = GoRouter(
    routes:[
      GoRoute(
        path: '/',
        builder: (context,state) {
          return const SplashScreen();
        },
      ),
      GoRoute(
        path: '/login',
        name: 'login',
        builder: (context,state) {
          return const LoginScreen();
        },
      ),
      GoRoute(
        path: '/Navigation',
        name: 'Navigation',
        builder: (context,state) {
          return const Navigation();
        },
      ),
      GoRoute(
        path: '/TaxiBooking',
        name: 'TaxiBooking',
        builder: (context,state) {
          return const TaxiBooking();
        },
      ),
      GoRoute(
        path: '/TruckBooking',
        name: 'TruckBooking',
        builder: (context,state) {
          return const TruckBooking();
        },
      ),
      GoRoute(
        path: '/BikeBooking',
        name: 'BikeBooking',
        builder: (context,state) {
          return const BikeBooking();
        },
      ),
      GoRoute(
        path: '/AutoBooking',
        name: 'AutoBooking',
        builder: (context,state) {
          return const AutoBooking();
        },
      ),
      GoRoute(
        path: '/Success/:id/:no/:type',
        name: 'Success',
        builder: (context,state) {
          return  Success(bookingId:state.pathParameters["id"]!,bookingNo:state.pathParameters["no"]!,type:state.pathParameters["type"]!,);
        },
      ),
      GoRoute(
        path: '/Failed',
        name: 'Failed',
        builder: (context,state) {
          return  const Failed();
        },
      ),
      GoRoute(
        path: '/History/:bookingType/:type',
        name: 'History',
        builder: (context,state) {
          return  History(bookingType:state.pathParameters["bookingType"]!,type:state.pathParameters["type"]!);
        },
      ),
      GoRoute(
        path: '/SingleBookingDetails/:type/:id',
        name: 'SingleBookingDetails',
        builder: (context,state) {
          return  SingleBookingDetails(type:state.pathParameters["type"]!,id: state.pathParameters["id"]!,);
        },
      ),
      GoRoute(
        path: '/LocationPermissionScreen',
        name: 'LocationPermissionScreen',
        builder: (context,state) {
          return const  LocationPermissionScreen();
        },
      ),
      GoRoute(
        path: '/CancelBookingPage',
        name: 'CancelBookingPage',
        builder: (context,state) {
          return  const CancelBookingPage();
        },
      ),
      GoRoute(
        path: '/RideCancelledPage',
        name: 'RideCancelledPage',
        builder: (context,state) {
          return  RideCancelledPage();
        },
      ),
      GoRoute(
        path: '/RideBookedPage',
        name: 'RideBookedPage',
        builder: (context,state) {
          return  RideBookedPage();
        },
      ),
      GoRoute(
        path: '/PhoneNumberPage',
        name: 'PhoneNumberPage',
        builder: (context,state) {
          return  const PhoneNumberPage();
        },
      ),
      GoRoute(
        path: '/LiveLocationMap/:des/:from/:id/:type',
        name: 'LiveLocationMap',
        builder: (context,state) {
          return LiveLocationMap(destination: state.pathParameters["des"]!,from: state.pathParameters["from"]!,id: state.pathParameters["id"]!,type:state.pathParameters["type"]! ,);
        },
      ),
      GoRoute(
        path: '/AllLive',
        name: 'AllLive',
        builder: (context,state) {
          return const AllLive();
        },

      ),
      GoRoute(
        path: '/AllOnging/:type',
        name: 'AllOnging',
        builder: (context,state) {
          return  AllOnging(type: state.pathParameters["type"]!);
        },
      ),
      GoRoute(
        path: '/SingleOngoingTaxi/:type/:id',
        name: 'SingleOngoingTaxi',
        builder: (context,state) {
          return  SingleOngoingTaxi(type: state.pathParameters["type"]!,id: state.pathParameters["id"]!,);
        },
      ),
      GoRoute(
        path: '/UpdatePage',
        name: 'UpdatePage',
        builder: (context,state) {
          return const UpdatePage();
        },
      ),
      GoRoute(
        path: '/ImageView/:image',
        name: 'ImageView',
        builder: (context,state) {
          return ImageView(image: state.pathParameters["image"]!);
        },
      ),
    ],

  );
}

