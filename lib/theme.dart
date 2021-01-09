import 'package:flutter/material.dart';

class CustomTheme {
  static ThemeData get darkTheme {
    return ThemeData(
        primaryColor: CustomColors.myGreen,
        scaffoldBackgroundColor: Colors.black,
        fontFamily: 'Montserrat',
        visualDensity: VisualDensity.adaptivePlatformDensity,
        accentColor: CustomColors.myGreen,
        floatingActionButtonTheme: FloatingActionButtonThemeData(
          splashColor: CustomColors.myGreen,
          backgroundColor: CustomColors.myGreen,
          //foregroundColor: Colors.black,
        ),
        cardTheme: CardTheme(
          elevation: 24,
          color: CustomColors.myGrey,
          ),
        dialogTheme: DialogTheme(
          backgroundColor: CustomColors.myGrey,
          titleTextStyle: TextStyle(color: Colors.white, fontSize: 24),
          contentTextStyle: TextStyle(color: Colors.white, fontSize: 16),
        ),
    );
  }
}

class CustomColors {
 //static const Color myGreen = Color.fromRGBO(92, 184, 92, 1);
  static const Color myGreen = Colors.green;
  static const Color myGrey = Color(0xFF222222);
  static const Color myLightGrey = Color(0xFF424242);
}