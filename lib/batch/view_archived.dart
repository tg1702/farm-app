import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'edit.dart';
import '../main.dart';
import 'info.dart';
import 'list_view.dart';

class ArchiveViewPage extends StatefulWidget {


  const ArchiveViewPage({super.key, required this.title,  required this.fields, required this.batchId, required this.path});

  final path;
  final batchId;
  final fields;

  final String title;

  @override
  State<StatefulWidget> createState() {
    return _ArchiveViewPageState(path, fields, batchId);
  }

}

class _ArchiveViewPageState extends State<ArchiveViewPage> {
  _ArchiveViewPageState(path, fields, batchId);

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
                    print(widget.batchId);
                    rows.add(DataRow(cells: [
                      DataCell(Text('${data[i][widget.fields[0]]}')),
                      DataCell(Text('${data[i][widget.fields[1]]}')),
                      if (widget.fields.length > 2)
                        DataCell(ElevatedButton(child: const Text("Full record", style: TextStyle(fontSize: 10)), onPressed: () {Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InfoHomePage(title: '(Archived) ${subIds[i]}' , id: subIds[i]),
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
            future: loadExpDocNames()
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
      final d = docSnapshot.data() as Map<String, dynamic>;
      if (d["Status"] == "Archived") {
        rec.add(d);
      }

    }

  },

  );

  return rec;
}


Future<List> loadExpDocNames() async {
  final QuerySnapshot result =
  await FirebaseFirestore.instance.collection("active-batches").get();
  List<DocumentSnapshot> documents = [];

  (result.docs).forEach((DocumentSnapshot doc){
    final d = doc.data() as Map<String, dynamic>;

    if (d["Status"] == "Archived"){
      documents.add(doc);
    }
  });
  return documents;
}