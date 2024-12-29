import 'package:flutter/material.dart';

class SnackBarUtil {
  static void showSnackBar(BuildContext context, String message,
      {Color backgroundColor = Colors.green, Duration duration = const Duration(seconds: 3)}) {
    final snackBar = SnackBar(
      content: Text(message,style: TextStyle(color: Colors.white),),
      duration: duration,
    );
    ScaffoldMessenger.of(context).showSnackBar(snackBar);
  }
}
