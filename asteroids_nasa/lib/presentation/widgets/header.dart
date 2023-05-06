import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Header extends StatefulWidget {
  const Header({Key? key}) : super(key: key);

  @override
  _HeaderState createState() => _HeaderState();
}

class _HeaderState extends State<Header> {
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
    return Container(
      width: utils.screenWidth,
      height: utils.absoluteHeight * 0.1,
      padding: EdgeInsets.symmetric(
          vertical: utils.absoluteHeight * 0.022,
          horizontal: utils.screenWidth * 0.03),
      child:  Row(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Image.network(
            'https://w1.pngwing.com/pngs/954/432/png-transparent-pdf-logo-nasa-insignia-outer-space-nasa-tv-television-blue-line-circle.png',
            color: Colors.white,
          ),
          SizedBox(
            width: utils.screenWidth * 0.03,
          ),
          Image.network(
            'https://e7.pngegg.com/pngimages/830/737/png-clipart-logo-space-race-nasa-insignia-united-states-nasa-miscellaneous-logo.png',
            color: Colors.white,
            width: utils.screenWidth * 0.35,
          ),
        ],
      ),
      decoration: BoxDecoration(color: utils.primaryColor),
    );
  }
}