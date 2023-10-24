import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:calendar_view/calendar_view.dart';

import '../batch/create.dart';
import '../main.dart';
import 'entry.dart';

DateTime now = DateTime.now();

class MyPage extends StatefulWidget {
  const MyPage({super.key, required this.title});


  final String title;

  @override
  _MyPageState createState() => _MyPageState(title: 'Farm Diary');
}

class _MyPageState extends State<MyPage> {
  _MyPageState({required String title});

  EventController controller = EventController();


  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {

    return WillPopScope(
        onWillPop: () async {Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => const MainPage()), (route) => false); return Future.value(false);},

        child: Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),

          body: FutureBuilder(
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done){
                if (snapshot.hasError){
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );

                } else if (snapshot.hasData){
                  final list = snapshot.data as List;


                  for (var d in list) {
                    final data = d.data() as Map<String,dynamic>;

                //Converting back to CalendarEventData data type
                final entry = CalendarEventData(
                  date: stringToDateTime(data["Date"]),
                  title: data["Title"],
                  description: data["Notes"],
                );

                controller.add(entry);
              }


              return CalendarControllerProvider(
                controller: controller,
                child: Scaffold(
                  body: MonthView(
                    controller: controller,
                    // to provide custom UI for month cells.
                    cellBuilder: (date, events, isToday, isInMonth) {
                      //
                      // Return your widget to display as month cell.

                      if (isInMonth) {
                        if (events.isEmpty) {
                          return Text("${date.day}");
                        } else {
                          return ListView(
                            children: [
                              Text("${date.day}"),

                              for (var event in events) Text(event.title, style: const TextStyle(backgroundColor: Colors.greenAccent)),

                            ],

                          );
                        }
                      }
                      else{
                        return Container(
                          decoration: const BoxDecoration(
                            shape: BoxShape.circle,
                          ),
                        );
                      }
                    },
                    minMonth: DateTime(1990),
                    maxMonth: DateTime(2100),
                    initialMonth: DateTime(now.year, now.month),
                    cellAspectRatio: 1,
                    onPageChange: (date, pageIndex) => print("$date, $pageIndex"),
                    onCellTap: (events, date) {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => EntryPage(title: 'Entry for ${fixDate("$date")}', date: "${DateTime(date.year, date.month, date.day)}",)));
                    },
                    startDay: WeekDays.sunday, // To change the first day of the week.
                    // This callback will only work if cellBuilder is null.
                    onEventTap: (event, date) => print(event),
                    onDateLongPress: (date) => print(date),

                  ),
                ),
              );


            }
          }
          return const Center(
            child: CircularProgressIndicator(),
          );
        },
        future: loadEntries(),
      ),
    ),
    );

  }
}

Future<List> loadEntries() async{
  var db = await FirebaseFirestore.instance.collection("farm-diary").get();
  final List<DocumentSnapshot> documents = db.docs;

  return documents;
}

DateTime stringToDateTime(dateString){
  int year = int.parse("${dateString[0]}${dateString[1]}${dateString[2]}${dateString[3]}");
  int month =  int.parse("${dateString[5]}${dateString[6]}");
  int day =  int.parse("${dateString[8]}${dateString[9]}");
  return DateTime(year, month, day);
}