import 'dart:ffi';

import 'package:date_time_picker/date_time_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../firebase_options.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'info.dart';
import '../main.dart';



class CreatePage extends StatefulWidget {
  const CreatePage({super.key, required this.title});


  final String title;

  @override
  _CreatePageState createState() => _CreatePageState();
}

class _CreatePageState extends State<CreatePage> {

  final batchController = TextEditingController();
  final vendorController = TextEditingController();
  var dateController = TextEditingController();
  final originalQuantityController = TextEditingController();

  //Field data to be entered into database
  String batchName = "";
  String date = "";
  int originalQuantity = 0;
  String vendor = "";


  String generateBatchName(date){

    String fixedDate = date;

    var batchName = "Batch ${fixedDate.replaceAll('-', '')}";
    return batchName;

  }


// Used to allow verified users to access database
  Future<bool> verify() async{
    var email = 'sample@email.com';
    var password = 'password';

    try {
      //Verified
      await FirebaseAuth.instance
          .signInWithEmailAndPassword(email: email, password: password);

      return true;


    }
    catch (e) {
      print(e);
      return false;
    }
  }


  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    batchController.dispose();
    vendorController.dispose();
    dateController.dispose();
    originalQuantityController.dispose();
    super.dispose();
  }

  @override
  void initState(){
    super.initState();
    dateController.text = fixDate(generateDate());
  }

  @override
  Widget build(BuildContext context) {
    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body:
        SingleChildScrollView(
        child: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: Column(
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


            mainAxisAlignment: MainAxisAlignment.center,

            children: <Widget>[

              TextFormField(
                controller: batchController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: "Batch Name (Default BatchDDMMYY)",
                  hintStyle: TextStyle(color: Colors.black),
                ),
              ),


              DateTimePicker(
                type: DateTimePickerType.date,
                initialValue: date,
                firstDate: DateTime(2000),
                lastDate: DateTime(2100),
                icon: Icon(Icons.event),
                dateLabelText: 'Date',
                  validator: (value) {
                    return null;
                  },
                onChanged: (val) => {if (val.isNotEmpty) {
                  setState(() {
                    date = val;
                    batchController.text = generateBatchName(date);
                  }

                  )


                }},
                onSaved: (val) => setState(() => date = val ?? ''),

              ),


              TextFormField(
                controller: vendorController,
                decoration: const InputDecoration(
                  border: UnderlineInputBorder(),
                  labelText: 'Vendor',
                ),
              ),
              TextField(
                controller: originalQuantityController,
                decoration: const InputDecoration(labelText: "Original Quantity"),
                keyboardType: TextInputType.number,
                inputFormatters: <TextInputFormatter>[
                  FilteringTextInputFormatter.digitsOnly
                ], // Only numbers can be entered
              ),

              Padding(
                padding: const EdgeInsets.symmetric(vertical: 30.0),
                child: ElevatedButton(
                child: Text("Submit"),
                  onPressed: () async {
                    bool verified = true;
                    if (verified){
                      final batches = FirebaseFirestore.instance.collection("active-batches");

                      var newDate = DateTime(int.parse("${date[0]}${date[1]}${date[2]}${date[3]}"),
                      int.parse("${date[5]}${date[6]}"), int.parse("${date[8]}${date[9]}"));

                      var estimatedDate = DateTime(newDate.year, newDate.month, newDate.day + 43);

                      var estimatedDateString = estimatedDate.toString();


                      //Field data to be entered into database
                      String batchName = generateBatchName(date);
                      int originalQuantity = 0;
                      String vendor = "";

                      //checking to make sure fields are not empty
                      if (batchController.text != "") {
                        batchName = batchController.text;
                      }


                      if (originalQuantityController.text != "") {
                        originalQuantity = int.parse(originalQuantityController.text);
                      }

                      if (vendorController.text != "") {
                        vendor = vendorController.text;
                      }

                      final newEntry = <String, dynamic>{
                        "Batch Name": batchName,
                        "Date": fixDate(date),
                        "Original Quantity": originalQuantity,
                        "Vendor": vendor,
                        "Current Quantity": originalQuantity,
                        "Total Income": 0.00,
                        "Total Expenses": 0.00,
                        "Batch Balance": 0.00,
                        "Estimated Date": fixDate(estimatedDateString),
                        "Status": "Active"
                      };



                      batches.doc(batchName).set(newEntry);





                      final snackBar = SnackBar(
                        content: Text("$batchName sent to database!"),
                        action: SnackBarAction(
                          label: "OK",
                          onPressed: () {

                          }
                        ),
                      );
                      ScaffoldMessenger.of(context).showSnackBar(snackBar);

                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => InfoHomePage(title: 'Info for ${batchName}', id: batchName),

                        ),

                      );

                    }

                  },
              ),
              ),

            ],
          ),
        ),
        ),

        // This trailing comma makes auto-formatting nicer for build methods.
      drawer: makeDrawer(context),
    );

  }

}

String generateDate(){
  DateTime date = DateTime.now();


  String day = "${date.day}";
  String month = "${date.month}";

  if (date.day < 10) {
    day = "0${date.day}";
  }

  if (date.month < 10) {
    month = "0${date.month}";
  }

  return "${date.year}-$month-$day";
}


//2023-11-17
String fixDate(date){
  return "${date[8]}${date[9]}-${date[5]}${date[6]}-${date[0]}${date[1]}${date[2]}${date[3]}";
}