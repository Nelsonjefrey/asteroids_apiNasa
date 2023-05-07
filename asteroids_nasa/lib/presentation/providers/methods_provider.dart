import 'package:flutter/material.dart';

class MethodsProvider extends ChangeNotifier {
  bool loadingDialog = false;
  String appVersion = '1.0.0';

  void showLoadingDialog(BuildContext context) async {
    loadingDialog = true;
    double screendWidth = MediaQuery.of(context).size.width;
    double absolueHeight = MediaQuery.of(context).size.height -
        MediaQuery.of(context).viewPadding.top;
    await showDialog(
        context: context,
        barrierColor: Colors.black.withOpacity(0.4),
        builder: (BuildContext dialogContext) {
          return Dialog(
            backgroundColor: Colors.transparent,
            elevation: 0,
            child: Container(
              width: screendWidth * 0.5,
              height: absolueHeight * 0.2,
              alignment: Alignment.center,
              decoration: const BoxDecoration(
                  color: Colors.white, shape: BoxShape.circle),
              child: const CircularProgressIndicator(
                color: Colors.red,
              ),
            ),
          );
        });
  }

  void hideLoadingDialog(BuildContext context) {
    loadingDialog = false;
    Navigator.of(context).pop();
  }
}