import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'create.dart';
import '../firebase_options.dart';
import 'edit.dart';
import 'info.dart';
import 'list_view.dart';
import '../main.dart';

class ExpInfoPage extends StatefulWidget {

  final id;
  final path;

  const ExpInfoPage({super.key, required this.title, required this.id, required this.path});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ExpInfoPageState(id);
  }

}

class _ExpInfoPageState extends State<ExpInfoPage> {
  _ExpInfoPageState(id);
  bool show = false;


  @override
  Widget build(BuildContext context) {

    return WillPopScope(
      onWillPop: () async {Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => InfoHomePage(title: 'Info for ${widget.id}', id: widget.id)), (route) => false); return Future.value(false);},
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),

        ),
        body: Padding(
          // Column is also a layout widget. It takes a list of children and
          // arranges them vertically. By default, it sizes itself to fit its
          // children horizontally, and tries to be as tall as its parent.
          //
          // Invoke "debug painting" (press "p" in the console, choose the
          // "Toggle Debug Paint" action from the Flutter Inspector in Android
          // Studio, or the "Toggle Debug Paint" command in Visual Studio Code)
          // to see the wireframe for each widget.
          //
          // Column has various properties to control how it sizes itself and
          // how it positions its children. Here we use mainAxisAlignment to
          // center the children vertically; the main axis here is the vertical
          // axis because Columns are vertical (the cross axis would be
          // horizontal).
          padding: const EdgeInsets.symmetric(horizontal: 20.0),
          child:
          FutureBuilder(
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                // If we got an error
                if (snapshot.hasError) {
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );

                  // if we got our data
                } else if (snapshot.hasData) {
                  // Extracting data from snapshot object
                  final allExpenseData = snapshot.data as List;

                  Map categories = {
                    "Feed": [],
                    "Medicine": [],
                    "Bedding": [],
                    "Chick": [],
                    "Transport": [],
                    "Processing": [],
                    "Other": [],
                  };


                  Map totals = {
                    "Feed" : {"Quantity": 0, "Total Cost": 0.0 },
                    "Medicine" : {"Quantity": 0, "Total Cost": 0.0 },
                    "Bedding" : {"Quantity": 0, "Total Cost": 0.0 },
                    "Chick" : {"Quantity": 0, "Total Cost": 0.0 },
                    "Transport" : {"Quantity": 0, "Total Cost": 0.0 },
                    "Processing" : {"Quantity": 0, "Total Cost": 0.0 },
                    "Other": {"Quantity": 0, "Total Cost": 0.0 },

                  };

                  int overallQuantity = 0;
                  double overallCost = 0.0;

                  List <DataRow> expenseCells = [];


                  for (var expense in allExpenseData) {

                    for (var index in categories.keys){


                      if (expense["Name"].toLowerCase().contains(index.toLowerCase())){


                        categories[index] = expense;
                        totals[index]["Quantity"] += expense["Quantity"];
                        totals[index]["Total Cost"] += expense["Total Cost"];

                        overallQuantity += expense["Quantity"] as int;
                        overallCost += expense["Total Cost"];



                      }

                    }


                  }


                  for (var total in totals.keys){
                    expenseCells.add( DataRow(
                      cells: [
                        DataCell(
                     Text("${total}")
                      ),
                        DataCell(Text("${totals[total]["Quantity"]}")),
                      DataCell(
                      Text(" \$  ${totals[total]["Total Cost"]}")),

                    ],
                    ),
                    );

                  }
                  expenseCells.add(
                    const DataRow(
                      cells: [
                        DataCell(
                            Text("----------", style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        DataCell(Text("")),
                        DataCell(
                            Text("----------", style: TextStyle(fontWeight: FontWeight.bold))),

                      ],
                    ),
                  );

                  expenseCells.add(
                    DataRow(
                      cells: [
                        const DataCell(
                            Text("OVERALL", style: TextStyle(fontWeight: FontWeight.bold))
                        ),
                        const DataCell(Text("")),
                        DataCell(
                            Text(" \$ $overallCost", style: const TextStyle(fontWeight: FontWeight.bold))),

                      ],
                    ),
                  );


                  return ListView(

                    children: [

                      DataTable(

                        dividerThickness: double.minPositive,
                        rows: [
                          ...expenseCells,
                            ],
                        columns: const [
                          DataColumn(label: Text("EXPENSE")),
                          DataColumn(label: Text("UNITS")),
                          DataColumn(label: Text("COST")),
                        ],
                      ),


                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: const Text("Back"),
                          onPressed: () {
                              Navigator.push(context, MaterialPageRoute(builder: (context) => InfoHomePage(title: 'Info for ${widget.id}', id: widget.id)));
                          },
                        ),
                      ),







                    ],
                  );
                }

              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future:loadExpDocNames(widget.path),
          ),

        ),

        // This trailing comma makes auto-formatting nicer for build methods.
        drawer: makeDrawer(context),
      ),
    );

  }
}