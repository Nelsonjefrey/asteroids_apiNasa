// ignore_for_file: use_build_context_synchronously

import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/home/home.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/email_sign_in.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/otp_verification.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/register.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/widgets/footer.dart';
import 'package:asteroids_nasa/presentation/widgets/go_back_button.dart';
import 'package:asteroids_nasa/presentation/widgets/header.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Authentication extends StatefulWidget {
  static const routeName = 'authentication';
  const Authentication({super.key});

  @override
  State<Authentication> createState() => _AuthenticationState();
}

class _AuthenticationState extends State<Authentication> {
  Utils utils = Utils();
  bool dataLoaded = false;
  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;
  TextEditingController phoneController = TextEditingController();
  FocusNode phoneFocus = FocusNode();

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
      // if (firebaseProvider.shared.getString('phone') != null) {
      //   phoneController.text = firebaseProvider.shared.getString('phone')!;
      // }
    }
    super.didChangeDependencies();
  }

  void validatePhoneFields() {
    try {
      if (phoneController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar un número');
      } else if (phoneController.text.length < 10) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar el número completo');
      } else {
        firebaseProvider.sendCodeVerification(
            context, methodsProvider, phoneController.text, 'auth');
      }
    } catch (e) {
      debugPrint('ERROR auth validatePhoneFields: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          phoneFocus.unfocus();
        },
        child: Scaffold(
          body: SingleChildScrollView(
            child: Stack(children: [
              Container(
                height: utils.absoluteHeight,
                color: Colors.white,
                alignment: Alignment.center,
                child: Stack(
                  children: [
                    // Positioned(
                    //     left: -utils.screenWidth * 0.19,
                    //     top: utils.absoluteHeight * 0.05,
                    //     child: Hero(
                    //       tag: 'background',
                    //       child: SizedBox(
                    //         width: utils.screenWidth * 0.8,
                    //         height: utils.absoluteHeight * 0.4,
                    //         child: Image.asset('assets/logos/container.png',
                    //             fit: BoxFit.fill, color: utils.primaryColor),
                    //       ),
                    //     )),
                    // Header
                    const Positioned(
                      top: 0,
                      child: Hero(
                        tag: 'header',
                        child: Header(),
                      ),
                    ),
                    Positioned(
                      top: utils.absoluteHeight * 0.15,
                      left: utils.screenWidth * 0.06,
                      child: Hero(
                        tag: 'goback',
                        child: GoBackButton(
                          type: 1,
                          screenWidth: utils.screenWidth,
                          onTap: () {
                            firebaseProvider.currentRoute = "welcome";
                            Navigator.of(context).pop();
                          },
                        ),
                      ),
                    ),
                    Positioned(
                      top: utils.absoluteHeight * 0.2,
                      left: 0,
                      right: 0,
                      bottom: 0,
                      child: SizedBox(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Column(
                              children: [
                                Hero(
                                  tag: 'icon',
                                  child: Container(
                                    width: utils.screenWidth * 0.25,
                                    //height: utils.absoluteHeight * 0.13,
                                    decoration: BoxDecoration(
                                        color: utils.primaryColor,
                                        borderRadius:
                                            BorderRadius.circular(10)),
                                    child: Icon(
                                      Icons.phone,
                                      color: Colors.white,
                                      size: utils.screenWidth * 0.17,
                                    ),
                                  ),
                                ),
                                Container(
                                  margin: EdgeInsets.only(
                                    top: utils.absoluteHeight * 0.04,
                                  ),
                                  child: Text(
                                    'Inicia sesión',
                                    style: TextStyle(
                                        color: utils.secundaryColor,
                                        fontSize: utils.screenWidth * 0.052,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                                // Phone field
                                Container(
                                  margin: EdgeInsets.only(
                                    top: utils.absoluteHeight * 0.06,
                                  ),
                                  width: utils.screenWidth * 0.7,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: utils.screenWidth * 0.03),
                                  decoration: BoxDecoration(
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                            color: Colors.grey[300]!,
                                            blurRadius: 5)
                                      ],
                                      borderRadius: BorderRadius.circular(10)),
                                  child: TextField(
                                    controller: phoneController,
                                    focusNode: phoneFocus,
                                    keyboardType: TextInputType.phone,
                                    maxLength: 10,
                                    style: TextStyle(
                                        fontSize: utils.screenWidth * 0.04,
                                        color: utils.secundaryColor),
                                    cursorColor: utils.secundaryColor,
                                    decoration: InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        labelText: 'Teléfono celular',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: utils.secundaryColor),
                                        prefix: Container(
                                            margin: EdgeInsets.only(
                                                right:
                                                    utils.screenWidth * 0.02),
                                            child: Text(
                                              '+57',
                                              style: TextStyle(
                                                fontSize:
                                                    utils.screenWidth * 0.04,
                                                color: utils.secundaryColor,
                                              ),
                                            ))),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        top: utils.absoluteHeight * 0.02),
                                    child: Text(
                                      'Enviaremos un código de verificación al número',
                                      style: TextStyle(
                                        fontSize: utils.screenWidth * 0.038,
                                        color: Colors.black,
                                        fontFamily: 'Quicksand',
                                      ),
                                    )),
                                GestureDetector(
                                  onTap: () {
                                    validatePhoneFields();                                   
                                  },
                                  child: Hero(
                                    tag: 'continueButton',
                                    child: Container(
                                      margin: EdgeInsets.only(
                                          top: utils.absoluteHeight * 0.03),
                                      padding: EdgeInsets.symmetric(
                                          vertical:
                                              utils.absoluteHeight * 0.017,
                                          horizontal: utils.screenWidth * 0.1),
                                      decoration: BoxDecoration(
                                          color: utils.secundaryColor,
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: Text(
                                        'Continuar',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.bold,
                                            fontSize:
                                                utils.screenWidth * 0.045),
                                      ),
                                    ),
                                  ),
                                ),
                                Container(
                                    margin: EdgeInsets.only(
                                        bottom: utils.absoluteHeight * 0.025,
                                        top: utils.absoluteHeight * 0.02),
                                    child: Text(
                                      'Iniciar sesión con:',
                                      style: TextStyle(
                                        color: utils.secundaryColor,
                                        fontSize: utils.screenWidth * 0.038,
                                        fontFamily: 'Quicksand',
                                      ),
                                    )),
                                Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        GestureDetector(
                                          onTap: () {
                                            firebaseProvider.currentRoute =
                                                "email-sign-in";
                                            Navigator.of(context).pushNamed(
                                                EmailSignIn.routeName);
                                          },
                                          child: Hero(
                                            tag: 'emailIcon',
                                            child: Container(
                                              width: utils.screenWidth * 0.15,
                                              height:
                                                  utils.absoluteHeight * 0.074,
                                              margin: EdgeInsets.symmetric(
                                                  horizontal:
                                                      utils.screenWidth * 0.02),
                                              decoration: BoxDecoration(
                                                  border: Border.all(
                                                    color: Colors.black,
                                                  ),
                                                  color: Colors.white,
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color:
                                                            Colors.grey[400]!,
                                                        blurRadius: 5,
                                                        offset:
                                                            const Offset(0, 2))
                                                  ]),
                                              child: Icon(
                                                Icons.email_outlined,                              
                                                size: utils.screenWidth * 0.095,
                                              ),
                                            ),
                                          ),
                                        ),
                                        GestureDetector(
                                          onTap: () async {
                                            methodsProvider
                                                .showLoadingDialog(context);
                                            Map<String, dynamic>? result =
                                                await firebaseProvider
                                                    .googleSignIn();

                                            firebaseProvider
                                                .validatedEstadoUsuario(
                                                    context);
                                            methodsProvider.hideLoadingDialog(context);
                                            if (result['error'] == '') {
                                              if (result['data']) {
                                                firebaseProvider.currentRoute =
                                                    "home";
                                                Navigator.of(context)
                                                    .pushReplacementNamed(
                                                  Home.routeName,
                                                );
                                              } else {
                                                firebaseProvider.currentRoute =
                                                    "register";
                                                Navigator.of(context).pushNamed(
                                                    Register.routeName,
                                                    arguments: result);
                                              }
                                            } else if (result['error'] ==
                                                'repeated') {
                                              utils.showFlushbar(
                                                  context: context,
                                                  title: 'El correo de gmail ya se encuentra registrado',
                                                  message: 'Intenta ingresar con correo y contraseña',
                                                  duration: 5);
                                            } else if (result['error'] ==
                                                'user') {
                                              utils.showFlushbar(
                                                  context: context,
                                                  title: 'Ocurrió un error',
                                                  message: 'No se pudo iniciar sesión. Intenta nuevamente',
                                                  duration: 5);
                                            }
                                          },
                                          child: Container(
                                            margin: EdgeInsets.symmetric(
                                                horizontal:
                                                    utils.screenWidth * 0.02),
                                            width: utils.screenWidth * 0.15,
                                            height:
                                                utils.absoluteHeight * 0.074,
                                            padding: const EdgeInsets.all(10),
                                            decoration: BoxDecoration(
                                                border: Border.all(
                                                  color: Colors.black,
                                                ),
                                                color: Colors.white,
                                                borderRadius:
                                                    BorderRadius.circular(10),
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: Colors.grey[400]!,
                                                      blurRadius: 5,
                                                      offset:
                                                          const Offset(0, 2))
                                                ]),
                                            child: Image.network(
                                              'https://icones.pro/wp-content/uploads/2021/02/google-icone-symbole-logo-png.png',                                                                                            
                                              fit: BoxFit.cover,
                                              alignment: Alignment.center,
                                              repeat: ImageRepeat.noRepeat,
                                            ),
                                          ),
                                        ),                                                                                                                        
                                      ],
                                    ),
                                    Container(
                                      margin: EdgeInsets.only(
                                          top: utils.absoluteHeight * 0.03),
                                      child: Row(
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                              'No has creado una cuenta?',
                                              style: TextStyle(
                                                  fontWeight: FontWeight.w300,
                                                  color: utils.secundaryColor,
                                                  fontSize: utils.screenWidth *
                                                      0.04)),
                                          GestureDetector(
                                            onTap: () {
                                              firebaseProvider.currentRoute =
                                                  "register";
                                              Navigator.of(context).pushNamed(
                                                Register.routeName,
                                                arguments: {'type': 'email'},
                                              );
                                            },
                                            child: Container(
                                              margin: EdgeInsets.only(
                                                  left:
                                                      utils.screenWidth * 0.03),
                                              child: Text(
                                                  'Registrarme',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.bold,
                                                      color:
                                                          utils.secundaryColor,
                                                      fontSize:
                                                          utils.screenWidth *
                                                              0.042)),
                                            ),
                                          )
                                        ],
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                           
                          ],
                        ),
                      ),
                    ),                  
                    const Positioned(
                      bottom: 0,
                      child: Footer()),
                  ],
                ),
              ),
            ]),
          ),
        ),
      ),
    );
  }
}
