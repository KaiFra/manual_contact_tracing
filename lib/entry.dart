class Entry {
  String enteredContacts;
  String time;
  //DateTime time;
  Entry(enteredContacts, time){
    this.enteredContacts = enteredContacts;
    this.time = time;
  }

  Entry.fromMap(Map map) :
      this.enteredContacts = map['enteredContacts'],
      this.time = map['time'];

  Map toMap(){
    return{
      'enteredContacts': this.enteredContacts,
      'time': this.time,
    };
  }
}
