import 'package:flutter/material.dart';
import 'package:another_flushbar/flushbar.dart';

class Utils {
  Utils._privateConstructor();
  bool loadingDialog = false;
  double screenWidth = 0;
  double absoluteHeight = 0;

  final Color primaryColor  = const Color.fromRGBO(2, 73, 219, 1);
  final Color secundaryColor =const Color.fromRGBO(0, 20, 188, 1);
  final Color confirmButton = const Color.fromRGBO(47, 210, 47, 1);
  final Color backButton = Color.fromRGBO(218, 64, 62, 1);  
  static final Utils _instance = Utils._privateConstructor();

  factory Utils() {
    return _instance;
  }

  void showFlushbar(
      {required BuildContext context,
      required String title,
      required String message,
      int duration = 3,
      IconData icon = Icons.info}) async {
    await Flushbar(
      title: title,
      message: message,
      margin: const EdgeInsets.only(left: 10, right: 10, bottom: 10),
      borderRadius: BorderRadius.circular(10),
      duration: Duration(seconds: duration),
      backgroundColor: Colors.red,
      icon: Icon(
        icon,
        color: Colors.white,
      ),
    ).show(context);
  }

  
}
