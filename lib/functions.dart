import 'package:fluttertoast/fluttertoast.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'entry.dart';
import 'package:intl/intl.dart';

final formatter = DateFormat('dd.MM.yyy');

void toast(String toastmessage){
  Fluttertoast.showToast(
      msg: toastmessage,
      toastLength: Toast.LENGTH_SHORT,
      gravity: ToastGravity.BOTTOM,
      timeInSecForIosWeb: 3,
      backgroundColor: Colors.grey[800],
      textColor: Colors.white,
      fontSize: 16.0
  );
}

class HelperFunctions {
  void copy(List<Entry> entries){
    String clipboard = "";
    for(var i = 0; i < entries.length; i++){
      if(entries[i].enteredContacts != ''){
        clipboard += entries[i].time + "\n" + entries[i].enteredContacts + "\n";
      }
    }
    //print(clipboard);
    Clipboard.setData(new ClipboardData(text: clipboard));
    toast("Copied to clipboard");
  }

  String timeToString(List<int> pickedTimeSP){
    String timeString = '';
    if(pickedTimeSP[0] == 99 && pickedTimeSP[1] == 99){
      timeString = "No notification set";
    }
    else {
      if (pickedTimeSP[0] < 9) {
        timeString = "Notification set for 0" + pickedTimeSP[0].toString() + ":";
      }
      else {
        timeString = "Notification set for " + pickedTimeSP[0].toString() + ":";
      }

      if (pickedTimeSP[1] < 9) {
        timeString += "0" + pickedTimeSP[1].toString();
      }
      else {
        timeString += pickedTimeSP[1].toString();
      }
    }
    return timeString;
  }

  String getInitialTextFieldValue(List<Entry> entries, int i, String time){
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
}