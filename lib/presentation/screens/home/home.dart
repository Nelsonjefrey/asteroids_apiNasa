import 'dart:io';

import 'package:asteroids_nasa/presentation/providers/asteroids_provider.dart';
import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/widgets/header.dart';
import 'package:asteroids_nasa/presentation/widgets/home_drawer.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';

class Home extends StatefulWidget {
  static const routeName = "home";
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  Utils utils = Utils();
  late FirebaseProvider firebaseProvider;
  bool dataLoaded = false;
  final GlobalKey<ScaffoldState> _drawerKey = GlobalKey();

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      firebaseProvider.initAsteroisd();
      if (firebaseProvider.misAsteroids.isEmpty) {
        // firebaseProvider.getUserCoupons();
      }
      super.didChangeDependencies();
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: WillPopScope(
        onWillPop: () async {
          return false;
        },
        child: Scaffold(
          backgroundColor: Colors.black,
          key: _drawerKey,
          drawer: HomeDrawer(
            homeContext: context,
          ),
          body: Stack(
            children: [
              // Header
              const Positioned(top: 0, right: 0, left: 0, child: Header()),
              // Floation button
              Positioned(
                left: utils.screenWidth * 0.045,
                top: utils.absoluteHeight * 0.021,
                child: GestureDetector(
                  onTap: () {
                    _drawerKey.currentState!.openDrawer();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                          ]),
                      child: Icon(Icons.menu,
                          size: utils.screenWidth * 0.06,
                          color: utils.primaryColor)),
                ),
              ),
              Positioned(
                right: utils.screenWidth * 0.045,
                top: utils.absoluteHeight * 0.021,
                child: GestureDetector(
                  onTap: () {
                    downloadData();
                  },
                  child: Container(
                      padding: const EdgeInsets.all(10),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                          ]),
                      child: Icon(Icons.download_outlined,
                          size: utils.screenWidth * 0.058,
                          color: utils.confirmButton)),
                ),
              ),
              // BODY
              Positioned(
                top: utils.absoluteHeight * 0.13,
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  width: utils.screenWidth * 0.9,
                  height: utils.absoluteHeight * 0.9,
                  margin: EdgeInsets.symmetric(
                      horizontal: utils.screenWidth * 0.01),
                  child: Scrollbar(
                    thickness: 10,
                    child: ListView.builder(
                        // scrollDirection: Axis.horizontal,
                        physics: const BouncingScrollPhysics(),
                        itemCount: firebaseProvider.keys.length,
                        itemBuilder: (context, index) {
                          int cantAsteroidDay = firebaseProvider
                              .misAsteroids[firebaseProvider.keys[index]]
                              .length;
                          return Container(
                              width: utils.screenWidth * 0.6,
                              margin: EdgeInsets.only(
                                  bottom: utils.absoluteHeight * 0.05,
                                  left: utils.absoluteHeight * 0.01),
                              padding: EdgeInsets.symmetric(
                                  vertical: utils.absoluteHeight * 0.02,
                                  horizontal: utils.screenWidth * 0.02),
                              alignment: Alignment.center,
                              decoration: BoxDecoration(
                                  color: Colors.grey[100],
                                  borderRadius: BorderRadius.circular(15),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[100]!, blurRadius: 5)
                                  ]),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    'Fecha: ${firebaseProvider.keys[index]}',
                                    style: TextStyle(
                                      color: utils.primaryColor,
                                      fontWeight: FontWeight.bold,
                                      fontSize: utils.screenWidth * 0.042,
                                    ),
                                  ),
                                  SizedBox(
                                    width: utils.screenWidth * 0.9,
                                    height: utils.absoluteHeight * 0.5,
                                    child: Scrollbar(
                                      child: ListView.builder(
                                        itemCount: cantAsteroidDay,
                                        itemBuilder: (context, i) {
                                          dynamic objData =
                                              firebaseProvider.misAsteroids[
                                                  firebaseProvider.keys[index]];
                                          return Container(
                                            margin: EdgeInsets.symmetric(
                                                vertical: utils.absoluteHeight *
                                                    0.02),
                                            padding: EdgeInsets.symmetric(
                                                vertical: utils.absoluteHeight *
                                                    0.02),
                                            width: utils.screenWidth * 0.5,
                                            decoration: BoxDecoration(
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(8),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey[100]!,
                                                      blurRadius: 5)
                                                ]),
                                            child: Padding(
                                              padding:
                                                  const EdgeInsets.all(8.0),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceEvenly,
                                                children: [
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Text(
                                                          'name: ${objData[i]['name']}'),
                                                      Text(
                                                          'id: ${objData[i]['id'].toString()}'),
                                                      Text(
                                                          'neo_reference_id: ${objData[i]['neo_reference_id'].toString()}'),
                                                      Text(
                                                          'absolute_magnitude_h: ${objData[i]['absolute_magnitude_h'].toString()}'),
                                                    ],
                                                  ),
                                                  Column(
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    children: [
                                                      GestureDetector(
                                                          onTap: () {
                                                            print(
                                                                'hola bebe ${objData[i].toString()}');
                                                            showAsteroids(
                                                                objData[i]);
                                                          },
                                                          child: Icon(
                                                            Icons
                                                                .remove_red_eye,
                                                            size: 30,
                                                            color: utils
                                                                .primaryColor,
                                                          ))
                                                    ],
                                                  )
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    ),
                                  ),
                                ],
                              ));
                        }),
                  ),
                ),
              )
            ],
          ),
        ),
      ),
    );
  }

  showAsteroids(dynamic objData) {
    return showDialog(
      context: context,
      builder: (context) {
        return Dialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          insetPadding:
              EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.03),
          child: Container(
            height: utils.absoluteHeight * 0.56,
            padding: EdgeInsets.symmetric(
                vertical: utils.absoluteHeight * 0.015,
                horizontal: utils.screenWidth * 0.05),
            child: SingleChildScrollView(
              child: Column(
                children: [
                  Text(
                    'Datelles de Asteroide:  ${objData['name']}',
                    style: TextStyle(
                        color: utils.primaryColor,
                        fontSize: utils.screenWidth * 0.045,
                        fontWeight: FontWeight.bold),
                  ),
                  SizedBox(
                    height: utils.absoluteHeight * 0.01,
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Text('Id: ', style: showStyle()),
                          Text(objData['id']),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Referencia: ', style: showStyle()),
                          Text(objData['neo_reference_id']),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Nombre: ', style: showStyle()),
                          Text(objData['name']),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Manitud: ', style: showStyle()),
                          Text(objData['absolute_magnitude_h'].toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Diametro Min Estimado: ', style: showStyle()),
                          Text(objData['estimated_diameter']['kilometers']
                                  ['estimated_diameter_min']
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Diametro Max Estimado: ', style: showStyle()),
                          Text(objData['estimated_diameter']['kilometers']
                                  ['estimated_diameter_max']
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('¿Potencialmente Peligroso?: ',
                              style: showStyle()),
                          Text(objData['is_potentially_hazardous_asteroid'] ==
                                  true
                              ? 'Si'
                              : 'No'),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Fecha de aproximacion: ', style: showStyle()),
                          Text(objData['close_approach_data']
                              .first['close_approach_date']
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Fecha de aprox Full: ', style: showStyle()),
                          Text(objData['close_approach_data']
                              .first['close_approach_date_full']
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Velocidad en (Km/h): ', style: showStyle()),
                          Text(objData['close_approach_data']
                              .first['relative_velocity']['kilometers_per_hour']
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Distancia a la luna: ', style: showStyle()),
                          Text(objData['close_approach_data']
                              .first['miss_distance']['lunar']
                              .toString()),
                        ],
                      ),
                      Row(
                        children: [
                          Text('Distancia Faltante: ', style: showStyle()),
                          Text(objData['close_approach_data']
                              .first['miss_distance']['kilometers']
                              .toString()),
                        ],
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Url:', style: showStyle()),
                          Text(
                            objData['nasa_jpl_url'].toString(),
                            style: const TextStyle(fontWeight: FontWeight.bold),
                          ),
                        ],
                      )
                    ],
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
  Future<void> downloadData() async {
    String fileName  = 'ApiNAsa.txt';    
    String content = mapToString(firebaseProvider.generalData); // Convierte el Map a una cadena de texto

    try {
      final directory = await getApplicationDocumentsDirectory();
      final filePath = '${directory.path}/$fileName';
      final file = File(filePath);
      await file.writeAsString(content); 

    debugPrint('Archivo creado exitosamente en: $filePath');
    } catch (e) {
      debugPrint('Error al guardar el archivo: $e');
    }
  }

  String mapToString(Map<String, dynamic> data) {
    String result = '';

    data.forEach((key, value) {
      result += '$key: $value\n';
    });

    return result;
  }

  TextStyle showStyle() => TextStyle(
      fontWeight: FontWeight.bold, color: utils.primaryColor, fontSize: 15);
}
