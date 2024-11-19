import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:osat/screens/HistoryScreens/choose_type.dart';
import 'package:osat/screens/home.dart';
import 'package:osat/screens/profile.dart';
import 'package:permission_handler/permission_handler.dart';

class Navigation extends StatefulWidget {
  const Navigation({super.key});

  @override
  State<Navigation> createState() => _NavigationState();
}

class _NavigationState extends State<Navigation> {
  int _selectedIndex = 0;

  static const List<Widget> _widgetOptions = <Widget>[
    Home(),
    ChooseType(),
    Profile(),
  ];

  void _onItemTapped(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    permissions();


  }

  void permissions()async{
    PermissionStatus status = await Permission.location.request();

    if (status.isGranted) {
      return;
    }else{
      GoRouter.of(context).goNamed("LocationPermissionScreen");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(

      body: Center(
        child: _widgetOptions[_selectedIndex],
      ),
      bottomNavigationBar: BottomNavigationBar(
        backgroundColor: Colors.black,
        items: const <BottomNavigationBarItem>[
          BottomNavigationBarItem(
            icon: Icon(Icons.home),
            label: 'Home',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.list_alt),
            label: 'Bookings',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Profile',
          ),
        ],
        currentIndex: _selectedIndex,
        unselectedItemColor: Colors.white,
        selectedItemColor: Colors.white,
        onTap: _onItemTapped,
      ),
    );
  }
}
