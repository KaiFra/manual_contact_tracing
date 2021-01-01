import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manual_contact_tracing/entry.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:manual_contact_tracing/theme.dart';


void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Manual contact tracing',
      theme: CustomTheme.darkTheme,
      home: MyHomePage(title: 'Manual contact tracing'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  final String title;

  MyHomePage({Key key, this.title}) : super(key: key);

  @override
  MyHomePageState createState() => MyHomePageState();
}

class MyHomePageState extends State<MyHomePage> {

  SharedPreferences sharedPreferences;

  List<Entry> entries = new List<Entry>();
  int numEntries = 0;

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async{
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();

    //For testing purposes
    /*
    setState(() {
      entries.add(new Entry("Muddi", "24.12.2020"));
    });

    numEntries++;
    setState(() {
      entries.add(new Entry("Huhu", "18.11.2020"));
    });

    numEntries++;
    setState(() {
      entries.add(new Entry("Heinz", "18.07.2020"));
    });
    numEntries++;
     */
  }

  final textfield = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      drawer: new Drawer(),
      appBar: AppBar(
        title: Text(widget.title),
        leading: new IconButton(
          icon: new Icon(Icons.menu),
          onPressed: null,
        ),
        actions: [
          IconButton(icon: const Icon(Icons.info),
          onPressed:(){
            showDialog(context: context, child:
            new AlertDialog(
              title: new Text("Manual Contact Tracing"),
              content: new Text("This app helps you to manually track your contacts.\nYou can add contacts for every day, but can't delete them right now.\n"
                  "Copying to the clipboard is supported.\n\n2020 \u00a9 Franz Lukas Kaiser"),
            ));},)],
      ),
      body:
          // mainAxisAlignment: MainAxisAlignment.center,
            Column(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 500),
                    child: ListView.builder(
                      // Let the ListView know how many items it needs to build.
                      itemCount: numEntries,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      //scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
                        //final item = MyHomePage.theUser.entries[MyHomePage.theUser.numEntries];
                        return Center(
                            child: Card(
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            ListTile(
                              //leading: Icon(Icons.album),
                              title: Text(entries[index].time, style: TextStyle(color: Colors.white, fontSize: 22)),
                              subtitle: Text(entries[index].enteredContacts, style: TextStyle(color: Colors.white, fontSize: 16)),
                            ),
                            ],
                            ),
                            ),
                        );
                      },
                    ),
                  ),
                ),
                Container(
                  child: TextFormField(
                    textCapitalization: TextCapitalization.sentences,
                    style: TextStyle(color: Colors.white),
                    decoration: InputDecoration(
                      fillColor: Colors.white,
                      border: const UnderlineInputBorder(),
                      labelText: 'Enter your contacts for today',
                    ),
                    autofocus: true,
                    maxLines: 3,
                    controller: textfield,
                  ),
                ),
              ],
            ),


      floatingActionButton: Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            onPressed: copy,
            tooltip: 'Copy to clipboard',
            child: Icon(Icons.copy),
          ),
          SizedBox(width: 10),
          FloatingActionButton(
            onPressed: createEntry,
            tooltip: 'Add new contacts',
            child: Icon(Icons.add),
          ),
        ],
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  createEntry(){
    if(textfield.text != '') {
      String timeNow = DateFormat('dd.MM.yyy').format(new DateTime.now()) ;
      bool added = false;
      for (int i = 0; i < numEntries; i++) {
        if (entries[i].time == timeNow) {
          setState(() {
            entries[i].enteredContacts += "\n" + textfield.text;
          });
          added = true;
          break;
          //print("Updated entry");
        }
      }
      if (!added) {
        setState(() {
          entries.add(new Entry(textfield.text, timeNow));
        });
        numEntries++;
        //print("Added new entry");
      }
      textfield.clear();
      saveData();
    }
    /*
    numEntries++;
    setState(() {entries.add(new Entry(textfield.text, time));});
    */
  }

  void copy(){
    String clipboard = "";
    for(var i = 0; i < numEntries; i++){
      clipboard += entries[i].time + "\n" + entries[i].enteredContacts + "\n";
    }
    Clipboard.setData(new ClipboardData(text: clipboard));
  }

  void saveData(){
    removeOld();
    List<String> spList = entries.map((item) => json.encode(item.toMap())).toList();
    //print(spList);
    sharedPreferences.setStringList('list', spList);
    setState(() {});
    sharedPreferences.setInt('numEntries', numEntries);
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('list');
    if (spList != null) {
      entries = spList.map((item) => Entry.fromMap(json.decode(item))).toList();
      setState(() {});
      //print("Data loaded");
    }
    numEntries = sharedPreferences.getInt('numEntries');
    if(numEntries == null){
      numEntries = 0;
    }
    removeOld();
  }

  void removeOld(){
    //String timeAgo = DateFormat('dd.MM.yyy').format(DateTime.now().subtract(Duration(days: 16)));
    DateTime timeAgo = DateTime.now().subtract(Duration(days: 16));
    //print("Date 16 days ago: $timeAgo");
    //Find indeces with old date
    List<int> indeces = [];
    for (int i = 0; i < numEntries; i++) {
      //print("i = $i");
      final formatter = DateFormat('dd.MM.yyy');
      DateTime entryTime = formatter.parse(entries[i].time);
      if (entryTime.isBefore(timeAgo)) {
        indeces.add(i);
      }
    }
    //Remove indeces with old date
    //print(indeces);
    int removedCount = 0;
    for (int i = 0; i < indeces.length; i++) {
      setState(() {
        entries.removeAt(indeces[i - removedCount]);
      });
      removedCount++;
      //String deleted = entries[i - removedCount].time;
      //print("Deleted entry with date: $deleted");
      numEntries--;
    }
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textfield.dispose();
    super.dispose();
  }
}