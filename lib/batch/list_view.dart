import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit.dart';
import '../main.dart';

class ListViewPage extends StatefulWidget {


  const ListViewPage({super.key, required this.title, required this.path, required this.fields, required this.batchId});


  final batchId;
  final path;
  final fields;

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ListViewPageState(path, fields, batchId);
  }

}

class _ListViewPageState extends State<ListViewPage> {
  _ListViewPageState(path, fields, batchId);

  bool show = false;


  @override
  Widget build(BuildContext context) {

    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(

          child: FutureBuilder(
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

                    final docs = snapshot.data as List;
                    var data = [];
                    List subIds = [];

                    docs.forEach((d) {
                      data.add(d.data() as Map<String, dynamic>);
                      subIds.add(d.id);
                    });

                    bool showIncome = (widget.fields.contains("Income")) ? true:false;

                    List <DataRow> rows = [];

                    for (int i = data.length-1; i >= 0; i--) {
                      rows.add(DataRow(cells: [
                        DataCell(Text('${data[i][widget.fields[0]]}')),
                        DataCell(Text('${data[i][widget.fields[1]]}')),
                        if (widget.fields.length > 2)
                        DataCell(ElevatedButton(child: const Text("Full record", style: TextStyle(fontSize: 10)), onPressed: () {Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                ListInfo(title: 'Full Record Info', fields: widget.fields, path: widget.path.doc(subIds[i]), batchId: subIds[i], showIncome: showIncome),
                          ),

                        );} ))
                      ],

                      ));
                    }
                    return Center(
                      child: Column(
                          children: [
                            Flexible(
                              child: DataTable(
                                rows: [...rows],
                                columns: [DataColumn(label: Text(widget.fields[0])),
                                DataColumn(label: Text(widget.fields[1])),

                                  if (widget.fields.length > 2)
                                    const DataColumn(label: Text('More')),


                                ],
                            ),

                            ),


                          ]
                      ),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              future: loadExpDocNames(widget.path)
          ),
        ),
        drawer: makeDrawer(context),
    );
  }
}

Future<Map<String, dynamic>> getDocumentInfo(db) async
{
  Map<String, dynamic> records = {};

  await db.get().then( (DocumentSnapshot doc){
    records = doc.data() as Map<String, dynamic>;

  },
  );

  return records;
}

Future<List> getCollectionInfo(db)async
{
  List<Map> rec = [];

  await db.get().then( (QuerySnapshot querySnapshot){
    for (var docSnapshot in querySnapshot.docs) {
      rec.add(docSnapshot.data() as Map<String, dynamic>);

    }

  },

  );

  return rec;
}


class ListInfo extends StatefulWidget {

  final fields;
  final path;
  final batchId;
  final showIncome;
  const ListInfo({super.key, required this.title, required this.fields, required this.path, required this.batchId, required this.showIncome});

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ListInfoState(fields, path, batchId);
  }

}

class _ListInfoState extends State<ListInfo> {
  _ListInfoState(fields, path, batchId);



  @override
  Widget build(BuildContext context) {

    List<DataRow> widgets = [];


    return Scaffold(
        appBar: AppBar(

          title: Text(widget.title),
        ),
        body: Center(

          child: FutureBuilder(
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
                    final data = snapshot.data as Map<String, dynamic>;

                    for(int i=0; i<widget.fields.length; i++){
                      widgets.add(DataRow( cells: [
                        DataCell(Text("${widget.fields[i]} ")),
                        DataCell(Text("${data[widget.fields[i]]} ")),
                        ],
                      ),
                      );
                    }

                    return Center(
                      child: Column(
                          children: [
                            DataTable(
                              rows: [
                                ...widgets,
                              ],
                              columns: const [
                                DataColumn(label: Text("Field")),
                                DataColumn(label: Text("Value")),
                              ],
                            ),




                            if (widget.showIncome == true)
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                child: const Text("Add Income"),
                                onPressed: () async{
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                        builder: (context) => EditPage(title: 'Add Income', id: widget.batchId, show: 2)
                                    ),

                                  );

                                },
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(vertical: 16.0),
                              child: ElevatedButton(
                                child: const Text("Add Expenses"),
                                onPressed: () async{
                                  Navigator.push(
                                    context,

                                    MaterialPageRoute(
                                        builder: (context) => EditPage(title: 'Add Expenses', id: widget.batchId, show: 1)
                                    ),

                                  );

                                },
                              ),
                            ),
                          ]

                      ),
                    );
                  }
                }
                return const Center(
                  child: CircularProgressIndicator(),
                );
              },
              future: getDocumentInfo(widget.path)
          ),
        ),
      drawer: makeDrawer(context),
    );
  }
}


Future<List> loadExpDocNames(db) async {
  final QuerySnapshot result =
  await db.get();
  final List<DocumentSnapshot> documents = result.docs;
  return documents;
}