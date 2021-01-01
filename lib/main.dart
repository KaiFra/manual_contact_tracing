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

  final formatter = DateFormat('dd.MM.yyy');

  @override
  void initState() {
    initSharedPreferences();
    super.initState();
  }

  initSharedPreferences() async{
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
    sortList();
    /*
    //For testing purposes
    setState(() {
      entries.add(new Entry("Heino", "30.12.2020"));
    });

    setState(() {
      entries.add(new Entry("Muddi", "24.12.2020"));
    });

    setState(() {
      entries.add(new Entry("Huhu", "18.11.2020"));
    });

    setState(() {
      entries.add(new Entry("Heinz", "18.07.2020"));
    });

    */
  }

  final textfield = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.title),
      ),
      bottomNavigationBar: BottomAppBar(

        color: Colors.black,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              //IconButton(icon: Icon(Icons.menu), onPressed: () => _scaffoldKey.currentState.openDrawer(), color: Colors.white,),
              IconButton(icon: Icon(Icons.menu), onPressed: showMenu, color: Colors.white,),
              IconButton(icon: Icon(Icons.copy), onPressed: copy, color: Colors.white,),
        ],
      ),),
      body:
          // mainAxisAlignment: MainAxisAlignment.center,
            Column(
              children: [
                Expanded(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(maxHeight: 500),
                    child: ListView.builder(
                      // Let the ListView know how many items it needs to build.
                      itemCount: entries.length,
                      // Provide a builder function. This is where the magic happens.
                      // Convert each item into a widget based on the type of item it is.
                      //scrollDirection: Axis.vertical,
                      shrinkWrap: true,
                      itemBuilder: (context, index) {
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
                      //border: const UnderlineInputBorder(),
                      labelText: 'Enter your contacts for today',
                    ),
                    autofocus: false,
                    maxLines: 3,
                    controller: textfield,
                  ),
                ),
              ],
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: createEntry,
        tooltip: 'Add new contacts',
        child: Icon(Icons.add),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  createEntry(){
    if(textfield.text != '') {
      String timeNow = DateFormat('dd.MM.yyy').format(new DateTime.now()) ;
      bool added = false;
      for (int i = 0; i < entries.length; i++) {
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
        //print("Added new entry");
      }
      textfield.clear();
      saveData();
    }
    /*
    setState(() {entries.add(new Entry(textfield.text, time));});
    */
  }

  void copy(){
    String clipboard = "";
    for(var i = 0; i < entries.length; i++){
      clipboard += entries[i].time + "\n" + entries[i].enteredContacts + "\n";
    }
    Clipboard.setData(new ClipboardData(text: clipboard));
  }

  void saveData(){
    removeOld();
    sortList();
    List<String> spList = entries.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
    setState(() {});
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('list');
    if (spList != null) {
      entries = spList.map((item) => Entry.fromMap(json.decode(item))).toList();
      setState(() {});
    }
    removeOld();
  }

  void removeOld(){
    DateTime timeAgo = DateTime.now().subtract(Duration(days: 16));
    //Find indeces with old date
    List<int> indeces = [];
    for (int i = 0; i < entries.length; i++) {
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
    }
  }

  void deleteDataDialog(){
    showDialog(context: context, child:
    new AlertDialog(
      elevation: 24,
      title: new Text("Delete data?"),
      content: new Text("Proceeding with this action will delete your data."),
      actions: [
        TextButton(onPressed: deleteData, child: Text('Delete data',)),
        TextButton(onPressed: () => Navigator.pop(context), child: Text('Dismiss')),
      ],
    ));
  }

  void deleteData(){
    setState(() {
      entries.clear();
    });
    Navigator.pop(context);
  }
  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textfield.dispose();
    super.dispose();
  }

  void sortList(){
    setState(() {
      entries.sort((a,b) => formatter.parse(b.time).compareTo(formatter.parse(a.time)));
    });
  }

  showMenu() {
    showModalBottomSheet(
        backgroundColor: Colors.black,
        useRootNavigator: true,
        context: context,
        builder: (BuildContext context) {
          return Container(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.end,
              children: <Widget>[
                SizedBox(
                    height: (56 * 3).toDouble(),
                    child: Container(
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.only(
                            topLeft: Radius.circular(16.0),
                            topRight: Radius.circular(16.0),
                          ),
                          color: CustomColors.myGrey,
                        ),
                        child: Stack(
                          alignment: Alignment(0, 0),
                          overflow: Overflow.visible,
                          children: <Widget>[

                            Positioned(
                              child: ListView(
                                physics: NeverScrollableScrollPhysics(),
                                children: <Widget>[
                                  ListTile(
                                    title: Text(
                                      "Sort",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    onTap: sortList,
                                  ),
                                  ListTile(
                                    title: Text(
                                      "Delete data",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onTap: deleteDataDialog,
                                  ),
                                  ListTile(
                                    title: Text(
                                      "Info",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      showDialog(context: context, child:
                                      new AlertDialog(
                                        title: new Text("Manual Contact Tracing"),
                                        content: new Text("This app helps you to manually track your contacts.\nYou can add contacts for every day, but can't delete them right now.\n"
                                            "Copying to the clipboard is supported.\n\n2020 \u00a9 Franz Lukas Kaiser"),
                                      ));},
                                  ),
                                ],
                              ),
                            )
                          ],
                        ))),
              ],
            ),
          );
        });
  }

}