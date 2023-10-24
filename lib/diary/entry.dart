import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import 'main_diary.dart';

class EntryPage extends StatefulWidget{
  const EntryPage({super.key, required this.title, required this.date});

  final date;
  final String title;

  @override
  _EntryPageState createState() => _EntryPageState();
}

class _EntryPageState extends State<EntryPage> {

  TextEditingController _titleController = TextEditingController();
  TextEditingController _notesController = TextEditingController();


  @override
  Widget build(BuildContext context){
    return Scaffold(
          appBar: AppBar(
            // Here we take the value from the MyHomePage object that was created by
            // the App.build method, and use it to set our appbar title.
            title: Text(widget.title),
          ),

          body: FutureBuilder(
            builder: (ctx, snapshot){
              if (snapshot.connectionState == ConnectionState.done){
                if (snapshot.hasError){
                  return Center(
                    child: Text(
                      '${snapshot.error} occurred',
                      style: const TextStyle(fontSize: 18),
                    ),
                  );
                } else if (snapshot.hasData){
                  final data = snapshot.data as Map<String,dynamic>;

                  if (data.isNotEmpty) {
                    _titleController.text = data["Title"];
                    _notesController.text = data["Notes"];
                  }


                  return ListView(
                          children: [
                            Padding(
                            padding: const EdgeInsets.symmetric(vertical: 20),
                            child: TextFormField(
                              controller: _titleController,
                              decoration: const InputDecoration(
                                  hintText: 'Title'
                              ),
                            ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 20),
                              child: TextField(
                              controller: _notesController,
                              decoration: const InputDecoration(
                                hintText: "Notes",

                              ),
                                maxLines: null,
                            ),

                            ),
                            ElevatedButton(
                                child: const Text("Submit"),
                                onPressed: () async{
                                  // Send info to database
                                  var db = FirebaseFirestore.instance.collection("farm-diary");

                                  final newEntry = {
                                    "Date": widget.date,
                                    "Title": _titleController.text,
                                    "Notes": _notesController.text,
                                  };

                                  db.doc("${widget.date}-${_titleController.text}").set(newEntry);

                                  //Navigating back to diary select page
                                  Navigator.push(context, MaterialPageRoute(builder: (context) => const MyPage(title: 'Farm Diary',)));
                                }
                            ),
                          ]
                  );
                }
              }

              return const Center(
                child: CircularProgressIndicator(),
              );
            },
            future: loadSingleEntry(widget.date),
          ),
    );


  }
}

Future<Map<String,dynamic>> loadSingleEntry(date) async{
  var db = await FirebaseFirestore.instance.collection("farm-diary").get();
  Map<String,dynamic> entry = {
    "Date": "",
    "Title": "",
    "Notes": "",
  };

  if (db.docs.isNotEmpty) {
    for (var doc in db.docs) {
      if (doc.id.contains(date)) {
        entry = doc.data();
      }
    }


  }

  return entry;
}