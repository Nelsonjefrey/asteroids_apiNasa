// ignore_for_file: sort_child_properties_last

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
          const Text('ASTEROIDS', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 20)),
          SizedBox(width: utils.screenWidth *0.02,),
          Image.network('https://api.nasa.gov/assets/img/favicons/favicon-192.png'),
        ],
      ),
      decoration: const BoxDecoration(color: Colors.black),
    );
  }
}