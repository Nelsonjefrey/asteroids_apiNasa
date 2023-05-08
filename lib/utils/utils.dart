import 'dart:io';
import 'package:flutter_image_compress/flutter_image_compress.dart';
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

  BoxDecoration boxDecoration(
      {Color? color, bool shadow = false, BoxShadow? boxShadow}) {
    return BoxDecoration(
        borderRadius: BorderRadius.circular(10),
        color: color,
        boxShadow: [
          boxShadow ??
              BoxShadow(
                  color: (shadow && color != null)
                      ? color.withOpacity(0.5)
                      : Colors.grey[300]!,
                  blurRadius: 5)
        ]);
  }

  Future<File?> compressPhoto(String imagePath, String targetPath) async {
    try {
      File? compressed = await FlutterImageCompress.compressAndGetFile(
          imagePath, targetPath,
          minWidth: 1024, minHeight: 1024, quality: 80);
      return compressed;
    } catch (e) {
      debugPrint('ERROR compressFile: $e');
    }
    return null;
  }

  void showImageDialog(BuildContext context, String image) {
    showDialog(
        context: context,
        builder: (context) {
          return Dialog(
            backgroundColor: Colors.transparent,
            child: Stack(
              children: [
                Container(
                  padding: const EdgeInsets.all(5),
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: primaryColor,
                  ),
                  // height: absoluteHeight * 0.4,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Image.network(
                      image,
                    ),
                  ),
                ),
                Positioned(
                    top: absoluteHeight * 0.01,
                    right: screenWidth * 0.02,
                    child: GestureDetector(
                      onTap: () => Navigator.pop(context),
                      child: Container(
                        padding: const EdgeInsets.all(2),
                        decoration: const BoxDecoration(
                            color: Colors.white, shape: BoxShape.circle),
                        child: Icon(
                          Icons.close,
                          color: secundaryColor,
                          size: screenWidth * 0.06,
                        ),
                      ),
                    ))
              ],
            ),
          );
        });
  }

  
}
