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
      /*
      localizationsDelegates: [
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
      ],
      supportedLocales: [
        Locale('de', 'DE'),
      ],
      locale: Locale('de'),

       */
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

  List<Entry> entries = new List<Entry>(); //List for all contacts

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
              IconButton(icon: Icon(Icons.menu), onPressed: showMenu, color: Colors.white,),
              IconButton(icon: Icon(Icons.copy), onPressed: copy, color: Colors.white,),
        ],
      ),),
      body:
          // mainAxisAlignment: MainAxisAlignment.center,
            Column(
              children: [
                Expanded(
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
              ],
            ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
      floatingActionButton: FloatingActionButton(
        onPressed: () => showInputDialog(0, DateFormat('dd.MM.yyy').format(new DateTime.now())),
        tooltip: 'Add new contacts',
        child: Icon(Icons.add),
      ),
      //floatingActionButtonLocation: FloatingActionButtonLocation.miniCenterDocked,// This trailing comma makes auto-formatting nicer for build methods.
    );
  }

  //Workaround to show text input field to add contact
  void showInputDialog(int index,String time){
    displayTextInputDialog(context,index, time);
  }

  //Display alert dialog to enter contacts
  Future<void> displayTextInputDialog(BuildContext context, int index, String time) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter your contacts'),
            content:TextFormField(
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: Colors.white),
              decoration: InputDecoration(
                fillColor: Colors.white,
              ),
              autofocus: true,
              maxLines: 3,
              controller: textfield..text = getInitialTextFieldValue(index, time),
            ),
            actions: <Widget>[
                FlatButton(
                color: Colors.red,
                textColor: Colors.white,
                child: Text('Cancel'),
                onPressed: () {
                  setState(() {
                    Navigator.pop(context);
                  });
                },
              ),
                FlatButton(
                color: CustomColors.myGreen,
                textColor: Colors.white,
                child: Text('OK'),
                onPressed: () => createEntry(time),
              ),
            ],
          );
        });
  }

  String getInitialTextFieldValue(int i, String time){
    if(entries.length == 0) {
      return '';
    }

    if (entries[i].time == time) {
        String ret = entries[i].enteredContacts + "\n";
        return ret;
      }
    else {
        return '';
      }
  }

  createEntry(String time) {
      //String today = DateFormat('dd.MM.yyy').format(new DateTime.now());
      bool added = false;
      for (int i = 0; i < entries.length; i++) {
        if (entries[i].time == time) {
          setState(() {
            entries[i].enteredContacts = textfield.text.trim();
          });
          added = true;
          break;
        }
      }
      if (!added && textfield.text != '') {
        setState(() {
          entries.add(new Entry(textfield.text.trim(), time));
        });
      }
      textfield.clear();
      saveData();
      setState(() {
        Navigator.pop(context);
      });
  }

  void copy(){
    String clipboard = "";
    for(var i = 0; i < entries.length; i++){
      clipboard += entries[i].time + "\n" + entries[i].enteredContacts + "\n";
    }
    Clipboard.setData(new ClipboardData(text: clipboard));
  }

  void saveData(){
    removeJunk();
    sortList();
    List<String> spList = entries.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
  }

  void loadData() {
    List<String> spList = sharedPreferences.getStringList('list');
    if (spList != null) {
      entries = spList.map((item) => Entry.fromMap(json.decode(item))).toList();
      setState(() {});
    }
    removeJunk();
  }

  void removeJunk(){
    DateTime timeAgo = DateTime.now().subtract(Duration(days: 16));
    //Find indeces with old date or empty
    List<int> indeces = [];
    for (int i = 0; i < entries.length; i++) {
      DateTime entryTime = formatter.parse(entries[i].time);
      if (entryTime.isBefore(timeAgo) || entries[i].enteredContacts == "" || entries[i].enteredContacts == "\n") {
        indeces.add(i);
      }
      //entries[i].enteredContacts.replaceAll(new RegExp(r'(?:[\t ]*(?:\r?\n|\r))+'), ''); //TODO remove empty lines seems solved
      String trim = entries[i].enteredContacts.trim();
      entries[i].enteredContacts = trim;

    }
    //Remove indeces with old date
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
        FlatButton(
          color: Colors.red,
          textColor: Colors.white,
          child: Text('Cancel'),
            onPressed: () => Navigator.pop(context),
        ),
        FlatButton(
          color: CustomColors.myGreen,
          textColor: Colors.white,
          child: Text('Delete data'),
          onPressed: deleteData,
        ),
      ],
    ));
  }

  void deleteData(){
    setState(() {entries.clear();});
    saveData();
    Navigator.pop(context);
  }

  @override
  void dispose() {
    // Clean up the controller when the widget is disposed.
    textfield.dispose();
    super.dispose();
  }

  void sortList(){
    setState(() {entries.sort((a,b) => formatter.parse(b.time).compareTo(formatter.parse(a.time)));});
  }

  void searchDate() async{

    DateTime now = DateTime.now();
    final DateTime pickedDate = await showDatePicker( //TODO Styling
      context: context,
      initialDate: now,
      firstDate: now.subtract(Duration(days: 16)),
      lastDate: now,
      initialDatePickerMode: DatePickerMode.day,
    );

    String picked = DateFormat('dd.MM.yyy').format(pickedDate);
    bool found = false;
    for (int i = 0; i < entries.length; i++) {
      if (entries[i].time == picked) {
        showInputDialog(i, picked);
        found = true;
        break;
      }
    }
    if(!found){
      setState(() {entries.add(new Entry("", picked));});
      showInputDialog(entries.length - 1, picked);
    }
    //
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
                                      "Search and edit",
                                      style: TextStyle(color: Colors.white),
                                    ),
                                    leading: Icon(
                                      Icons.search,
                                      color: Colors.white,
                                    ),
                                    onTap: searchDate,
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
                                            "Copying to the clipboard is supported.\n\n2021 \u00a9 Franz Lukas Kaiser"),
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