import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get darkTheme {
    return ThemeData(
        primaryColor: Colors.black,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Product Sans',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: Colors.green,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          splashColor: Colors.green,
          backgroundColor: Colors.green,
        ),
        cardTheme: CardTheme(
          elevation: 24,
          color: Colors.black,
          ),
        dialogTheme: DialogTheme(
          backgroundColor: Colors.grey[900],
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 24, fontFamily: 'Product Sans',),
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 16, fontFamily: 'Product Sans',),
        ),
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(primary: Colors.white),
      ),
      textSelectionHandleColor: Colors.green,
      cursorColor: Colors.green,
      textTheme: TextTheme( headline6: TextStyle(color: Colors.white,),
                            subtitle1: TextStyle(color: Colors.white,),
                            subtitle2: TextStyle(color: Colors.white),),
      iconTheme: IconThemeData(color: Colors.white,), //TODO Listview icon color
      bottomSheetTheme: BottomSheetThemeData(backgroundColor: Colors.black,),
    );
  }
}

