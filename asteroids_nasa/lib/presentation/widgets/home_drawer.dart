// ignore_for_file: use_build_context_synchronously

import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/profile/profile_info.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/welcome.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class HomeDrawer extends StatefulWidget {
  final BuildContext homeContext;
  const HomeDrawer({Key? key, required this.homeContext}) : super(key: key);

  @override
  _HomeDrawerState createState() => _HomeDrawerState();
}

class _HomeDrawerState extends State<HomeDrawer> {
  Utils utils = Utils();

  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;

  bool dataLoaded = false;

  // Map
  @override
  void didChangeDependencies() async {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
      super.didChangeDependencies();
    }
  }

  // Log out user session
  Future<void> logOut() async {    
    methodsProvider.showLoadingDialog(context);
    String result = await firebaseProvider.logOut();
    if (result == 'success') {
      Navigator.of(context).pop();
      firebaseProvider.currentRoute = "welcome";
      Navigator.of(context).pushReplacementNamed(Welcome.routeName);
      firebaseProvider.user = null;
    } else if (result == 'error') {
      methodsProvider.hideLoadingDialog(context);
      utils.showFlushbar(
          context: context,
          title: 'Ocurrió un error',
          message: 'No se pudo cerrar sesión. Intenta nuevamente');
    }
  }
    

  Future<void> _showMyDialog() async {
    return showDialog<void>(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Desea eliminar su cuenta ?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: utils.primaryColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text(
                    'Lo vamos a extrañar'),                
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Aceptar'),
              onPressed: () {
                Future<bool> respuesta =
                    firebaseProvider.updateEstadoUsuario(false);

                respuesta.then((value) => {
                      if (value == true)
                        {logOut()}
                      else
                        {
                          Navigator.of(context).pop(),                          
                        }
                    });
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  primary: utils.backButton, backgroundColor: Colors.white),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  // Future<void> getExcel() async {
  //   try {
  //     FilePickerResult? result = await FilePicker.platform.pickFiles(
  //         allowMultiple: false,
  //         type: FileType.custom,
  //         allowedExtensions: ['XLSX', 'xlsx']);
  //     if (result != null) {
  //       String? path = result.files.first.path;
  //       if (path != null) {
  //         Uint8List bytes = File(path).readAsBytesSync();
  //         Excel excel = Excel.decodeBytes(bytes);
  //         bool resp = methodsProvider.proccessExcel(excel);
  //         if (resp) {
  //           bool result = methodsProvider.checkExcelLabels();
  //           if (result) {
  //             Navigator.pushNamed(context, DecodedExcel.routeName,
  //                 arguments: widget.homeContext);
  //           } else {
  //             utils.showFlushbar(
  //                 context: context,
  //                 title: utils.localeTexts!['drawertext1'],
  //                 message: utils.localeTexts!['drawertext2'],
  //                 duration: 5);
  //           }
  //         } else {
  //           utils.showFlushbar(
  //               context: context,
  //               title: utils.localeTexts!['drawertext3'],
  //               message: utils.localeTexts!['drawertext4'],
  //               duration: 5);
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('ERROR getExcel: $e');
  //   }
  // }

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: Container(
        padding: EdgeInsets.only(bottom: utils.absoluteHeight * 0.03),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(
              children: [
                // Profile info
                GestureDetector(
                  onTap: () {
                    Navigator.pushNamed(context, ProfileInfo.routeName);
                  },
                  child: Container(
                    width: double.infinity,
                    padding: EdgeInsets.symmetric(
                        vertical: utils.absoluteHeight * 0.03),
                    decoration: BoxDecoration(
                        color: utils.primaryColor,
                        borderRadius: const BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25))),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Container(
                            width: utils.screenWidth * 0.2,
                            height: utils.absoluteHeight * 0.1,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(10)),
                            child: ((firebaseProvider
                                        .user!.profileInfo['photo_url'] !=
                                    '')
                                ? ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.network(
                                      firebaseProvider
                                          .user!.profileInfo['photo_url'],
                                      fit: BoxFit.fill,
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: utils.screenWidth * 0.1,
                                  ))),
                        Container(
                          margin:
                              EdgeInsets.only(top: utils.absoluteHeight * 0.01),
                          child: Text(
                              firebaseProvider.user!.profileInfo['names'] +
                                  ' ' +
                                  firebaseProvider
                                      .user!.profileInfo['last_names'],
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: utils.screenWidth * 0.05,
                                  fontWeight: FontWeight.bold)),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                              bottom: utils.absoluteHeight * 0.008,
                              top: utils.absoluteHeight * 0.02),
                          child: Text('Editar mi perfil',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: utils.screenWidth * 0.04,
                                  fontWeight: FontWeight.normal)),
                        ),
                      ],
                    ),
                  ),
                ),                                                                
              ],
            ),
            Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                // Sign out
                GestureDetector(
                  onTap: () {
                    logOut();
                  },
                  child: Container(
                    padding: EdgeInsets.symmetric(
                        horizontal: utils.screenWidth * 0.05),
                    child: Row(
                      children: [
                        Icon(
                          Icons.logout,
                          size: utils.screenWidth * 0.06,
                          color: utils.primaryColor,
                        ),
                        Container(
                          padding: EdgeInsets.symmetric(
                            horizontal: utils.screenWidth * 0.03,
                          ),
                          child: Text(
                            'Cerrar sesión',
                            style: TextStyle(
                                fontSize: utils.screenWidth * 0.043,
                                fontFamily: 'Quicksand',
                                fontWeight: FontWeight.w500),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height: utils.absoluteHeight * 0.03,
                ),
                Align(child: Text(methodsProvider.appVersion))
              ],
            )
          ],
        ),
      ),
    );
  }
}
