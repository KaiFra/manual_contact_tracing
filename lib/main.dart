import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:manual_contact_tracing/entry.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:manual_contact_tracing/theme.dart';
import 'package:timezone/data/latest.dart' as tz;
import 'package:timezone/timezone.dart' as tz;
import 'notification.dart';
import 'functions.dart';


void main() {
  runApp(MCT());
}

class MCT extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    SystemChrome.setPreferredOrientations([
      DeviceOrientation.portraitUp,
    ]);
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Contact Diary',
      theme: CustomTheme.darkTheme,
      home: MyHomePage(title: 'Contact Diary'),
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
  final helper = HelperFunctions();
  final Notifications _notifications = Notifications();

  double borderRadius = 12.0;
  SharedPreferences sharedPreferences;

  List<Entry> entries = new List<Entry>(); //List for all contacts

  final formatter = DateFormat('dd.MM.yyy');



  List<int> pickedTimeSP = [0, 0]; //Workaround to save notification time in sharedPrefs
  String timeString = "";
  
  DateTime timeAgo = DateTime.now().subtract(Duration(days: 17));

  @override
  void initState() {
    this._notifications.initNotifications();
    tz.initializeTimeZones();
    initSharedPreferences();
    super.initState();
    this._notifications.initNotifications();
    tz.initializeTimeZones();
  }

  initSharedPreferences() async{
    sharedPreferences = await SharedPreferences.getInstance();
    loadData();
  }

  final textfield = TextEditingController();

  @override
  Widget build(BuildContext context) {

    return Scaffold(
      resizeToAvoidBottomInset: true,
      appBar: AppBar(
        title: Text(widget.title),
        centerTitle: true,
      ),
      bottomNavigationBar: BottomAppBar(
        color: Colors.black,
        child: new Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: <Widget>[
              IconButton(icon: Icon(Icons.menu), onPressed: showMenu, tooltip: "Show menu",),
              IconButton(icon: Icon(Icons.copy), onPressed: () => helper.copy(entries), tooltip: "Copy to clipboard",),
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
                      padding: const EdgeInsets.all(10),
                      shrinkWrap: true,
                      itemBuilder: (context, i) {
                        return Center(
                            child: Card(
                            child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: <Widget>[
                            Ink(
                            decoration: BoxDecoration(
                              color: Colors.grey[900],
                              borderRadius: BorderRadius.all(Radius.circular(borderRadius)),
                            ),
                              child: ListTile(
                                shape: RoundedRectangleBorder(borderRadius: BorderRadius.all(Radius.circular(borderRadius))),
                                title: Text(entries[i].time, style: TextStyle(fontSize: 22),),
                                subtitle: (entries[i].enteredContacts != '')
                                ? Text(entries[i].enteredContacts, style: TextStyle(color: Colors.white, fontSize: 16))
                                : null,
                                onTap: () => showTextInputDialog(context,i, entries[i].time),
                              ),
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
        onPressed: () => showTextInputDialog(context, 0, formatter.format(new DateTime.now())),
        tooltip: 'Add new contacts',
        child: Icon(Icons.add),
      ),
    );
  }

  //Display alert dialog to enter contacts
  Future<void> showTextInputDialog(BuildContext context, int index, String time) async {
    return showDialog(
        context: context,
        builder: (context) {
          return AlertDialog(
            title: Text('Enter your contacts'),
            content: TextFormField(
              textCapitalization: TextCapitalization.sentences,
              style: TextStyle(color: Colors.white),
              autofocus: true,
              minLines: 1,
              maxLines: 100,
              controller: textfield..text = helper.getInitialTextFieldValue(entries, index, time),
            ),
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.all(Radius.circular(borderRadius))
            ),
            actions: <Widget>[
                TextButton(
                  child: Text('CANCEL'),
                  onPressed: () {setState(() {Navigator.pop(context);});},
              ),
                TextButton(
                  child: Text('OK'),
                  onPressed: () {
                    createEntry(textfield.text.trim(), time, false);
                    setState(() {Navigator.pop(context);});},
              ),
            ],
          );
        });
  }

  /*
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
*/
  createEntry(String text, String time, bool emptyEntry) {
      bool added = false;
      for (int i = 0; i < entries.length; i++){
          if(entries[i].time == time) {
            if(!emptyEntry) {
              setState(() {
                entries[i].enteredContacts = text;
              });
            }
          added = true;
          break;
        }
      }

      if (!added) {
        setState(() {
          entries.add(new Entry(text, time));
        });
      }
      if(!emptyEntry) {
        textfield.clear();
      }
      saveData();
  }

  void saveData() async {
    await sharedPreferences.remove('list');
    removeOld();
    List<String> spList = entries.map((item) => json.encode(item.toMap())).toList();
    sharedPreferences.setStringList('list', spList);
  }

  void saveNotificationTime() async {
    await sharedPreferences.remove('pickedHour');
    await sharedPreferences.remove('pickedMin');
    sharedPreferences.setInt('pickedHour', pickedTimeSP[0]);
    sharedPreferences.setInt('pickedMin', pickedTimeSP[1]);
  }

  void loadData() async {
    List<String> spList = sharedPreferences.getStringList('list');
    if (spList != null) {
      entries = spList.map((item) => Entry.fromMap(json.decode(item))).toList();
      setState(() {});
    }
    //Create empty entries for every day
    //DateTime now = new DateTime.now();
    for (int i = 0; i < 17; i++) {
      createEntry('', formatter.format(new DateTime.now().subtract(Duration(days: i))), true);
    }

    removeOld();

    pickedTimeSP[0] = sharedPreferences.getInt('pickedHour');
    if (pickedTimeSP[0] == null){
      pickedTimeSP[0] = 22;
    }
    pickedTimeSP[1] = sharedPreferences.getInt('pickedMin');
    if (pickedTimeSP[1] == null){
      pickedTimeSP[1] = 0;
    }

    TimeOfDay pickedTime = TimeOfDay(hour: pickedTimeSP[0], minute: pickedTimeSP[1]);

    await this._notifications.flutterLocalNotificationsPlugin.cancelAll();
    this._notifications.scheduleDailyNotification(pickedTime);
    timeString = helper.timeToString(pickedTimeSP);
  }

  //Removes old dates
  void removeOld(){
    //Find indeces with old date
    List<int> indeces = [];
    for (int i = 0; i < entries.length; i++) {
      DateTime entryTime = formatter.parse(entries[i].time);
      if (entryTime.isBefore(timeAgo)) {
        indeces.add(i);
      }
      entries[i].enteredContacts.trim();
    }
    //Remove corresponding indices
    int removedCount = 0;
    for (int i = 0; i < indeces.length; i++) {
      setState(() {
        entries.removeAt(indeces[i - removedCount]);
      });
      removedCount++;
    }
    //Sort list
    setState(() {entries.sort((a,b) => formatter.parse(b.time).compareTo(formatter.parse(a.time)));});
  }


  //Dialog for deleting data
  void deleteDataDialog(){
    showDialog(context: context, child:
    new AlertDialog(
      elevation: 24,
      title: Text("Delete data?"),
      content: new Text("Proceeding with this action will delete your data."),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(borderRadius))
      ),
      actions: [
        TextButton(
          child: Text('CANCEL'),
            onPressed: () => Navigator.pop(context),
        ),
        TextButton(
          child: Text('OK'),
          onPressed: deleteData,
        ),
      ],
    ));
  }

  void deleteData() async{
    setState(() {entries.clear();});
    saveData();
    await sharedPreferences.remove('pickedHour');
    await sharedPreferences.remove('pickedMin');
    Navigator.pop(context);
  }

  // Clean up the controller when the widget is disposed.
  @override
  void dispose() {
    textfield.dispose();
    super.dispose();
  }

  showMenu() {
    showModalBottomSheet(
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
                          color: Colors.grey[900],
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
                                      "Add daily notification\n$timeString"),
                                    leading: Icon(
                                      Icons.notifications,
                                      color: Colors.white,
                                    ),
                                    onTap: () => dailyNotification(),
                                  ),
                                  ListTile(
                                    title: Text("Delete data"),
                                    leading: Icon(
                                      Icons.delete,
                                      color: Colors.white,
                                    ),
                                    onTap: deleteDataDialog,
                                  ),
                                  ListTile(
                                    title: Text(
                                      "Info"),
                                    leading: Icon(
                                      Icons.info,
                                      color: Colors.white,
                                    ),
                                    onTap: () {
                                      showDialog(context: context, child:
                                      new AlertDialog(
                                        shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(Radius.circular(borderRadius))
                                        ),
                                        title: Text("Contact Diary", style: TextStyle(fontFamily: 'Product Sans'),),
                                        content: Text("This app helps you to manually track your contacts. You can add a daily notification.\nYou can add contacts for every day and edit them.\n"
                                            "Copying to the clipboard is supported.\nContacts are automatically deleted after 16 days.\n\n2021 \u00a9 Franz Lukas Kaiser", style: TextStyle(fontFamily: 'Product Sans'),),
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


  void dailyNotification() async {
    TimeOfDay pickedTime = await showTimePicker(
      initialTime: TimeOfDay.fromDateTime(DateTime.now().add(Duration(minutes: 1))),
      context: context,

      builder: (context, child) {
        return Theme(
          data: ThemeData.light().copyWith(
            colorScheme: ColorScheme.dark(
              primary: Colors.white,
            ),
          ),
          child: MediaQuery(
            data: MediaQuery.of(context).copyWith(alwaysUse24HourFormat: true),
            child: child,
          ),
        );
      },
    );

    if(pickedTime == null){
      pickedTimeSP[0] = 99;
      pickedTimeSP[1] = 99;
      await this._notifications.flutterLocalNotificationsPlugin.cancelAll();
      saveNotificationTime();
    }
    else{
      pickedTimeSP[0] = pickedTime.hour;
      pickedTimeSP[1] = pickedTime.minute;
      await this._notifications.flutterLocalNotificationsPlugin.cancelAll();
      this._notifications.scheduleDailyNotification(pickedTime);
      saveNotificationTime();
    }

    timeString = helper.timeToString(pickedTimeSP);
    Navigator.pop(context);
    toast(timeString);
  }

}