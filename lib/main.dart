import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import 'batch/create.dart';
import 'batch/delete.dart';
import 'batch/info.dart';
import 'package:firebase_core/firebase_core.dart';
import 'batch/view_archived.dart';
import 'diary/main_diary.dart';
import 'firebase_options.dart';
import 'batch/list_view.dart';

void main() async{
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  runApp(const MainPage());
}



class MainPage extends StatelessWidget {
  const MainPage({super.key});
  // This widget is the root of your application.
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Inventory Management',
      theme: ThemeData(
        // This is the theme of your application.
        //
        // Try running your application with "flutter run". You'll see the
        // application has a blue toolbar. Then, without quitting the app, try
        // changing the primarySwatch below to Colors.green and then invoke
        // "hot reload" (press "r" in the console where you ran "flutter run",
        // or simply save your changes to "hot reload" in a Flutter IDE).
        // Notice that the counter didn't reset back to zero; the application
        // is not restarted.
        primarySwatch: Colors.green,
      ),
      home: const MyHomePage(title: 'Management App'),
        debugShowCheckedModeBanner: false,
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;
  const MyHomePage({super.key, required this.title});

  // This widget is the home page of your application. It is stateful, meaning
  // that it has a State object (defined below) that contains fields that affect
  // how it looks.

  // This class is the configuration for the state. It holds the values (in this
  // case the title) provided by the parent (in this case the App widget) and
  // used by the build method of the State. Fields in a Widget subclass are
  // always marked "final".



  @override
  _MyHomePageState createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {



  @override
  Widget build(BuildContext context) {


    // This method is rerun every time setState is called, for instance as done
    // by the _incrementCounter method above.
    //
    // The Flutter framework has been optimized to make rerunning build methods
    // fast, so that you can just rebuild anything that needs updating rather
    // than having to individually change instances of widgets.
    return WillPopScope(
      onWillPop: () {
        SystemNavigator.pop();
        return Future.value(false);
      },
      child: Scaffold(
        appBar: AppBar(
          // Here we take the value from the MyHomePage object that was created by
          // the App.build method, and use it to set our appbar title.
          title: Text(widget.title),
        ),
        body: Center(
          // Center is a layout widget. It takes a single child and positions it
          // in the middle of the parent.
          child: FutureBuilder(
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
            future: loadDocNames(),
            builder: (ctx, snapshot) {
              if (snapshot.connectionState == ConnectionState.done) {
                if (snapshot.hasError) {
                  return const Center(
                      child: Text("Error fetching data has occurred")
                  );
                }
                else if (snapshot.hasData) {
                  final docNames = snapshot.data as List;
                  List<Widget> sidebarList = [];

                  sidebarList.add(
                    Divider(
                      color: Colors.black,
                    ),
                  );

                  docNames.forEach((DOC)
                  {
                    final d = DOC.data() as Map<String,dynamic>;

                    if (d["Status"] == "Active") {
                      sidebarList.add(ListTile(
                        title: Text("     ${DOC.id}"),
                        onTap: () =>
                        {Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                InfoHomePage(id: DOC.id, title: DOC.id,),
                          ),

                        )},
                      ),
                      );
                      sidebarList.add(
                        Divider(
                          color: Colors.black,
                        ),
                      );
                    }
                  });
                  return Center(
                    child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text("Active Batches", style: TextStyle(color: Colors.green, fontSize: 32)),
                        ...sidebarList,

                      ]
                    )
                  );
                }

              }
              return const Center(
                child: CircularProgressIndicator(),
              );
            }

              ),

          ),


        drawer: makeDrawer(context),
      ),
    );

  }
}

Future<List> loadDocNames() async {
  final QuerySnapshot result =
      await FirebaseFirestore.instance.collection('active-batches').get();
  final List<DocumentSnapshot> documents = result.docs;

  return documents;
}


Widget makeDrawer(context){
  var db = FirebaseFirestore.instance.collection("active-batches");

  return Drawer(
    child: FutureBuilder(
      builder: (ctx, snapshot) {
    // Checking if future is resolved or not
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
        final data = snapshot.data as List;
        List<Widget> activeList = [];


        data.forEach((DOC)
        {
          final d = DOC.data() as Map<String, dynamic>;
          if (d["Status"] == "Active"){
          activeList.add( ListTile(
            title: Text("     ${DOC.id}"),
            onTap: () => {Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => InfoHomePage(id: DOC.id, title: DOC.id,),
              ),

            )},
          ),
          );

        }
        });

        return ListView(
          children: [
            const DrawerHeader(
              decoration: BoxDecoration(color: Colors.green,),
              child: Text("Management App", style: TextStyle(color: Colors.white, fontSize: 32)),
            ),
            ListTile(
              title: const Text("Home"),
              onTap: () => {Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const MainPage(),

                ),

              )},
            ),
            ListTile(
              title: const Text("Active Batches"),
              onTap: (){

              },
            ),
            ...activeList,

            ListTile(
              title: const Text("Create a new batch"),
              onTap: () => {Navigator.push(context,
                  MaterialPageRoute(builder: (context) => const CreatePage(title: 'Create a new Batch'))

              )},
            ),

            ListTile(
              title: const Text("Farm Diary"),
              onTap: () => {Navigator.push(context,
                  MaterialPageRoute(builder: (context) => MyPage(title: 'Farm Diary'))

              )},
            ),


            ListTile(
              title: const Text("View Archived Batches"),
              onTap: () => {Navigator.push(context,
                  MaterialPageRoute(builder: (context) => ArchiveViewPage(title: 'View Archived Batches', batchId: null, fields: const ["Batch Name", "Total Expenses", "Total Income", "Original Quantity", "Current Quantity", "Date Archived"], path: db,))

              )},
            ),
          ],
        );
      }
    }

    // Displaying LoadingSpinner to indicate waiting state
    return const Center(
      child: CircularProgressIndicator(),
    );
  },

  future: loadDocNames(),
    )
  );
}


