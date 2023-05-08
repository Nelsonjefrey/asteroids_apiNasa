import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';

class GoBackButton extends StatelessWidget {
  final double screenWidth;
  final Function onTap;
  final int type;
  const GoBackButton(
      {Key? key,
      required this.screenWidth,
      required this.onTap,
      required this.type})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    Utils utils = Utils();
    return Align(
      alignment: Alignment.centerLeft,
      child: GestureDetector(
        onTap: () {
          onTap();
        },
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: (type == 1)
              ? BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.white,
                  boxShadow: [
                      BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                    ])
              : BoxDecoration(
                  color: utils.secundaryColor,
                  borderRadius: BorderRadius.circular(7),
                  boxShadow: const [
                      BoxShadow(color: Colors.black54, blurRadius: 5)
                    ]),
          child: Icon(Icons.arrow_back_ios_new,
              size: screenWidth * 0.045,
              color: (type == 1) ? Colors.black : Colors.white),
        ),
      ),
    );
  }
}