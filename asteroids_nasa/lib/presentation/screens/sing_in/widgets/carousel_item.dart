import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class CarouselItem extends StatefulWidget {
  final String title;
  final String text;

  const CarouselItem({Key? key, required this.title, required this.text})
      : super(key: key);

  @override
  _CarouselItemState createState() => _CarouselItemState();
}

class _CarouselItemState extends State<CarouselItem> {
  Utils utils = Utils();
  bool dataLoaded = false;

  late MethodsProvider methodsProvider;

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      methodsProvider = Provider.of<MethodsProvider>(context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: utils.screenWidth,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          // Title
          Container(
            margin: EdgeInsets.only(bottom: utils.absoluteHeight * 0.01),
            child: Text(
              widget.title,
              style: TextStyle(
                  color: Colors.amber[100],
                  fontWeight: FontWeight.bold,
                  fontSize: utils.screenWidth * 0.05),
            ),
          ),
          // Description
          Container(
            margin: EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.05),
            child: Text(
              widget.text,
              style: TextStyle(
                color: Colors.white,
                fontSize: utils.screenWidth * 0.04,
                fontFamily: 'Quicksand',
              ),
              textAlign: TextAlign.center,
            ),
          )
        ],
      ),
    );
  }
}
