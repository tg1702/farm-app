import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'create.dart';
import 'expense_info.dart';
import '../firebase_options.dart';
import 'edit.dart';
import 'list_view.dart';
import '../main.dart';

class InfoHomePage extends StatefulWidget {

  final id;
  const InfoHomePage({super.key, required this.title, required this.id});

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
    return _InfoHomePageState(id);
  }

}

class _InfoHomePageState extends State<InfoHomePage> {
  _InfoHomePageState(id);
  bool show = false;


  @override
  Widget build(BuildContext context) {
    var db = FirebaseFirestore.instance.collection("active-batches").doc(widget.id).collection("Expenses");
    return WillPopScope(
      onWillPop: () async {Navigator.pushAndRemoveUntil(context, MaterialPageRoute(builder: (context) => MainPage()), (route) => false); return Future.value(false);},
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
                  final allData = snapshot.data as List;
                  Map data = allData[0];
                  allData.removeAt(0);
                  List <Widget> expensesWidgets = [];



                  if(allData.isNotEmpty) {
                    expensesWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("Most Recent Expense", style: TextStyle(
                            fontWeight: FontWeight.bold,
                            backgroundColor: Colors.green)),
                      ),

                    );

                    expensesWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                            "     Name of Expense: ${allData[allData.length-1]["Name"]}"),
                      ),
                    );
                    expensesWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                            "     Date of Expense: ${allData[allData.length-1]["Date"]}"),
                      ),
                    );

                    expensesWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("     Quantity: ${allData[allData.length-1]["Quantity"]}"),
                      ),
                    );

                    expensesWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                            "     Cost per unit: \$ ${allData[allData.length-1]["Cost per Unit"]}"),
                      ),
                    );

                    expensesWidgets.add(
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: Text(
                            "     Description: ${allData[allData.length-1]["Description"]}"),
                      ),
                    );
                  }

                  return ListView(

                    children: [

                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: Text("Info for ${widget.id}",
                            style: const TextStyle(
                                color: Colors.green, fontSize: 32)),

                      ),

                      DataTable(
                        rows: [
                          DataRow( cells: [
                          DataCell(Text("Date ")),
                          DataCell(Text("${data["Date"]}"))
                          ],
                          ),
                          DataRow( cells: [
                            DataCell(Text("Vendor ")),
                            DataCell(Text("${data["Vendor"]}"))
                            ],
                          ),
                          DataRow( cells: [
                            DataCell(Text("Original Quantity ")),
                            DataCell(Text("${data["Original Quantity"]}"))
                          ],
                          ),
                        DataRow( cells: [
                        DataCell(Text("Current Quantity ")),
                        DataCell(Text("${data["Current Quantity"]}"))
                        ],
                        ),

                          DataRow( cells: [
                            DataCell(Text("Mortality Rate ")),
                            DataCell(Text("${double.parse((((data["Original Quantity"]-data["Current Quantity"])/data["Original Quantity"])*100).toStringAsFixed(2))}%"))
                          ],
                          ),
                        DataRow( cells: [
                        DataCell(Text("Total Income ")),
                        DataCell(Text("\$ ${data["Total Income"].toStringAsFixed(2)}"))
                        ],
                        ),
                        DataRow( cells: [
                        DataCell(Text("Total Expenses ")),
                          DataCell(Text("\$ ${data["Total Expenses"].toStringAsFixed(2)}"))
                        ],
                        ),
                        if (data["Status"] == "Archived")
                        DataRow( cells: [
                        DataCell(Text("Batch Balance ")),
                        DataCell(Text("\$ ${(data["Total Income"] - data["Total Expenses"]).toStringAsFixed(2)}")),
                        ],
                        ),
                        DataRow(
                          cells:
                          [
                            DataCell(Text("Estimated Completion")),
                            DataCell(Text("${data["Estimated Date"]}")),
                          ]  ,
                        ),
                                  ],

                        columns: [
                          DataColumn(  label: Text("Field"),),
                          DataColumn( label: Text("Value")),
                        ],
                      ),


                      ...expensesWidgets,


                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: const Text("Show all Expenses"),
                          onPressed: () {

                            WidgetsBinding.instance.addPostFrameCallback((_) =>
                                Navigator.push(context, MaterialPageRoute(builder: (context) {
                                  return ExpInfoPage(
                                      title: 'Show all Expenses',
                                      id: widget.id,
                                      path: db,
                                  );
                                })));
                          },
                        ),
                      ),


                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: const Text("Add an Expense"),
                          onPressed: () {


                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPage(
                                    title: 'Add an Expense',
                                    id: widget.id,
                                    show: 1),
                              ),

                            );
                          },
                        ),
                      ),

                      if (data["Status"] == "Active")
                      Padding(
                        padding: EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: Text("Add Death"),
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => EditPage(
                                    title: 'Add Death',
                                    id: widget.id,
                                    show: 3),
                              ),

                            );
                          },
                        ),
                      ),

                      if (data["Status"] == "Active")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: const Text("Show all Deaths"),
                          onPressed: () {
                            Navigator.of(context).push(MaterialPageRoute(builder: (_)=>ListViewPage(
                                title: 'Show all Deaths',
                                path: FirebaseFirestore.instance.collection("active-batches").doc(widget.id).collection("Death Records"),
                                fields: const ["Number of Deaths", "Week", "Date"],
                                batchId: widget.id
                            ),),)
                                .then((val)=>{returnFields(widget.id)});

                          },
                        ),
                      ),


                      if (data["Status"] == "Active")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: const Text("Archive Batch"),
                          onPressed: () async {
                            FirebaseFirestore.instance.collection("active-batches").doc(widget.id).update({"Status": "Archived", "Date Archived": fixDate(generateDate())});


                            final snackBar = SnackBar(
                              content: Text("${widget.id} moved from Active"),
                              action: SnackBarAction(
                                  label: "Return Home",
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => const MainPage(),
                                      ),

                                    );
                                  }
                              ),
                            );
                            ScaffoldMessenger.of(context).showSnackBar(snackBar);


                          },

                        ),
                      ),

                      if (data["Status"] == "Archived")
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 16.0),
                        child: ElevatedButton(
                          child: const Text("Add Income"),
                          onPressed: () async{
                            Navigator.push(
                              context,

                              MaterialPageRoute(
                                  builder: (context) => EditPage(title: 'Add Income', id: widget.id, show: 2)
                              ),

                            );

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
                  future:returnFields(widget.id),
                ),

    ),

        // This trailing comma makes auto-formatting nicer for build methods.
      drawer: makeDrawer(context),
      ),
    );

  }
}

Future<List> returnFields(String id) async{
  final docRef = FirebaseFirestore.instance.collection("active-batches").doc(id);
  final docRef2 = await FirebaseFirestore.instance.collection("active-batches").doc(id).collection("Expenses").get();
  List allInfo = [];
  Map data = {};


  await docRef.get().then(
        (DocumentSnapshot doc) {
        data = doc.data() as Map<String, dynamic>;
    },
    onError: (e) => print("Error getting document: $e"),
  );

  allInfo.add(data);

  final List<DocumentSnapshot> documents = docRef2.docs;
  documents.forEach((doc) {
    final d = doc.data() as Map <String, dynamic>;
    allInfo.add(d);

  });

  return allInfo;
}