
import 'package:flutter/material.dart';
import 'package:osat/screens/HistoryScreens/AllHistory.dart';
import 'package:osat/screens/HistoryScreens/Canceled.dart';
import 'package:osat/screens/HistoryScreens/Completed.dart';
import 'package:osat/screens/HistoryScreens/Live.dart';

class History extends StatefulWidget {
  final String bookingType;
  final String type ;
  const History({super.key, required this.bookingType, required this.type});

  @override
  State<History> createState() => _HistoryState();
}

class _HistoryState extends State<History> {


  PageController pageController = PageController();



  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          centerTitle: true,
          title: const Text(
            "OSAT",
            style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold
            ),
          ),
          backgroundColor: const Color(0xffF6F6F6),
          bottom: PreferredSize(
            preferredSize: const Size.fromHeight(40),
            child: Container(
              width: MediaQuery.of(context).size.width,
              height: 40,
              color: const Color(0xffF6F6F6),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 8.0),
                child: TabBar(

                  dividerColor: Colors.transparent,
                  labelPadding: EdgeInsets.zero,
                  indicator: BoxDecoration(
                      borderRadius: BorderRadius.circular(5),
                      color: const Color(0xff101010)
                  ),
                  tabAlignment: TabAlignment.center,
                  labelColor: Colors.white ,
                  labelStyle: const TextStyle(
                      fontWeight: FontWeight.bold
                  ),
                  isScrollable: true,
                  tabs: const [
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                      child: Text("All",),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                      child: Text("Completed",),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                      child: Text("Canceled",),
                    ),
                    Padding(
                      padding:  EdgeInsets.symmetric(horizontal: 20.0,vertical: 4),
                      child: Text("Live",),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        body: TabBarView(
          children: [
            AllHistory(url: widget.bookingType,type: widget.type ,),
            Completed(url: "${widget.bookingType.substring(3)}ByStatus",type:widget.type  ,),
            Canceled(url: "${widget.bookingType.substring(3)}ByStatus",type: widget.type ,),
            Live(url: "${widget.bookingType.substring(3)}ByStatus",type: widget.type ,),
          ],
        ),
      ),
    );
  }
}
