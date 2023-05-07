import 'package:asteroids_nasa/presentation/widgets/home_drawer.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';

class Home extends StatefulWidget {
  static const routeName = "home";
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Utils utils = Utils();

  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();
  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
            onWillPop: () async {
              return false;
            },
            child: Scaffold(
              key: _drawerKey,
              // Drawer
              drawer: HomeDrawer(
                homeContext: context,
              ),
              // HOME;
              body: Stack(
                children: [
                  Positioned(
                    left: utils.screenWidth * 0.07,
                    top: utils.absoluteHeight * 0.035,
                    child: GestureDetector(
                      onTap: () {
                        _drawerKey.currentState!.openDrawer();
                      },
                      child: Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                              color: utils.primaryColor,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[300]!, blurRadius: 5)
                              ]),
                          child: Icon(Icons.menu,
                              size: utils.screenWidth * 0.06,
                              color: Colors.white)),
                    ),
                  ),
                ],
              ),
            )));
  }
}
