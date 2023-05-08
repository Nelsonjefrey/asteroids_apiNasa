import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/home/home.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/register.dart';
import 'package:asteroids_nasa/presentation/widgets/go_back_button.dart';
import 'package:asteroids_nasa/presentation/widgets/header.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class OtpVerification extends StatefulWidget {
  static const routeName = 'otp-verification';
  const OtpVerification({Key? key}) : super(key: key);

  @override
  _OtpVerificationState createState() => _OtpVerificationState();
}

class _OtpVerificationState extends State<OtpVerification> {
  bool dataLoaded = false;
  Utils utils = Utils();

  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;

  late String phoneNumber;
  TextEditingController code1Controller = TextEditingController();
  TextEditingController code2Controller = TextEditingController();
  TextEditingController code3Controller = TextEditingController();
  TextEditingController code4Controller = TextEditingController();
  TextEditingController code5Controller = TextEditingController();
  TextEditingController code6Controller = TextEditingController();

  List<FocusNode> codesFocus = [
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode(),
    FocusNode()
  ];

  String completeCode = '';

  late Map<String, dynamic> arguments;

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
      arguments = ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      phoneNumber = arguments['phone'];      
    }
    super.didChangeDependencies();
  }

  // Verify if sent code is correct to login and register
  Future<void> validateCode() async {
    completeCode = code1Controller.text +
        code2Controller.text +
        code3Controller.text +
        code4Controller.text +
        code5Controller.text +
        code6Controller.text;
    if (completeCode.isEmpty) {
      utils.showFlushbar(
          context: context,
          title: 'Espera',
          message: 'Debes ingresar el código');
    } else if (completeCode.length < 6) {
      utils.showFlushbar(
          context: context,
          title: 'Espera',
          message: 'Debes ingresar el código completo');
    } else {
      methodsProvider.showLoadingDialog(context);
      String result = await firebaseProvider.verifySentCode(
          context,
          firebaseProvider.verificationId!,
          completeCode,
          '+57$phoneNumber',
          arguments['from']);
      methodsProvider.hideLoadingDialog(context);
      if (result == 'userData') {
        completeCode = '';
        code1Controller.text = '';
        code2Controller.text = '';
        code3Controller.text = '';
        code4Controller.text = '';
        code5Controller.text = '';
        code6Controller.text = '';
        firebaseProvider.currentRoute = "home";
        Navigator.of(context).pushReplacementNamed(Home.routeName);
      } else if (result == 'driverData' || result == 'noData') {
        firebaseProvider.shared.setString('phone', phoneNumber);
        completeCode = '';
        code1Controller.text = '';
        code2Controller.text = '';
        code3Controller.text = '';
        code4Controller.text = '';
        code5Controller.text = '';
        code6Controller.text = '';
        firebaseProvider.currentRoute = "register";
        Navigator.of(context).pushReplacementNamed(
          Register.routeName,
          arguments: {
            'type': 'phone',
            'phone': phoneNumber,
          },
        );
      } else if (result == 'linked') {
        firebaseProvider.shared.setString('phone', phoneNumber);
        completeCode = '';
        code1Controller.text = '';
        code2Controller.text = '';
        code3Controller.text = '';
        code4Controller.text = '';
        code5Controller.text = '';
        code6Controller.text = '';
        firebaseProvider.currentRoute = "home";
        Navigator.of(context).pushReplacementNamed(Home.routeName);
      } else if (result == 'linkedError') {
        firebaseProvider.currentRoute = "home";
        Navigator.of(context).pushReplacementNamed(Home.routeName);
      } else if (result == 'error') {
        utils.showFlushbar(
          context: context,
          title: 'Error',
          message: 'Ha ocurrido un error. Intenta nuevamente',
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: SafeArea(
        child: GestureDetector(
          onTap: () {
            for (var focus in codesFocus) {
              focus.unfocus();
            }
          },
          child: Scaffold(
            body: SingleChildScrollView(
              child: Container(
                height: utils.absoluteHeight,
                color: Colors.white,
                alignment: Alignment.center,
                child: Stack(
                  children: [                    
                    // Header
                     const Positioned(
                      top: 0,
                      child: Hero(
                        tag: 'header',
                        child: Header(),
                      ),
                    ),
                    // Go back button
                    Positioned(
                      top: utils.absoluteHeight * 0.15,
                      left: utils.screenWidth * 0.06,
                      child: (arguments['from'] == 'auth')
                          ? Hero(
                              tag: 'goback',
                              child: GoBackButton(
                                type: 1,
                                screenWidth: utils.screenWidth,
                                onTap: () {
                                  Navigator.of(context).pop();
                                },
                              ),
                            )
                          : const SizedBox(),
                    ),
                    // Body
                    Positioned(
                      top: utils.absoluteHeight * 0.28,
                      left: utils.screenWidth * 0.1,
                      right: utils.screenWidth * 0.1,
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Hero(
                            tag: 'icon',
                            child: Container(
                              width: utils.screenWidth * 0.25,
                              height: utils.absoluteHeight * 0.13,
                              decoration: BoxDecoration(
                                  color: utils.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
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
                              'Verificación de tu número de celular',
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  color: utils.secundaryColor,
                                  fontSize: utils.screenWidth * 0.052,
                                  fontWeight: FontWeight.bold),
                            ),
                          ),
                          Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            crossAxisAlignment: CrossAxisAlignment.center,
                            children: [
                              Align(
                                alignment: Alignment.centerLeft,
                                child: Container(
                                  margin: EdgeInsets.symmetric(
                                      vertical: utils.absoluteHeight * 0.03),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      Text(
                                        'Código enviado al: ',
                                        style: TextStyle(
                                            fontSize: utils.screenWidth * 0.038,
                                            color: utils.secundaryColor,
                                            fontFamily: 'Quicksand'),
                                      ),
                                      Text('+57 $phoneNumber',
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.038,
                                              fontWeight: FontWeight.bold,
                                              fontFamily: 'Quicksand',
                                              color: utils.secundaryColor)),
                                    ],
                                  ),
                                ),
                              ),
                              Container(
                                margin: EdgeInsets.only(
                                  top: utils.absoluteHeight * 0.02,
                                ),
                                // Codes fields
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: utils.screenWidth * 0.1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.01),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300]!,
                                                blurRadius: 5)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                          controller: code1Controller,
                                          focusNode: codesFocus[0],
                                          cursorColor: utils.secundaryColor,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 1,
                                          onChanged: (val) {
                                            if (val.length == 1) {
                                              codesFocus[0].nextFocus();
                                            }
                                          },
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.04),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          )),
                                    ),
                                    Container(
                                      width: utils.screenWidth * 0.1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.01),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300]!,
                                                blurRadius: 5)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                          controller: code2Controller,
                                          focusNode: codesFocus[1],
                                          cursorColor: utils.secundaryColor,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 1,
                                          onChanged: (val) {
                                            if (val.length == 1) {
                                              codesFocus[1].nextFocus();
                                            }
                                          },
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.04),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          )),
                                    ),
                                    Container(
                                      width: utils.screenWidth * 0.1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.01),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300]!,
                                                blurRadius: 5)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                          controller: code3Controller,
                                          focusNode: codesFocus[2],
                                          cursorColor: utils.secundaryColor,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 1,
                                          onChanged: (val) {
                                            if (val.length == 1) {
                                              codesFocus[2].nextFocus();
                                            }
                                          },
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.04),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          )),
                                    ),
                                    Container(
                                      width: utils.screenWidth * 0.1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.01),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300]!,
                                                blurRadius: 5)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                          controller: code4Controller,
                                          focusNode: codesFocus[3],
                                          cursorColor: utils.secundaryColor,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 1,
                                          onChanged: (val) {
                                            if (val.length == 1) {
                                              codesFocus[3].nextFocus();
                                            }
                                          },
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.04),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          )),
                                    ),
                                    Container(
                                      width: utils.screenWidth * 0.1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.01),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300]!,
                                                blurRadius: 5)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                          controller: code5Controller,
                                          focusNode: codesFocus[4],
                                          cursorColor: utils.secundaryColor,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 1,
                                          onChanged: (val) {
                                            if (val.length == 1) {
                                              codesFocus[4].nextFocus();
                                            }
                                          },
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.04),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          )),
                                    ),
                                    Container(
                                      width: utils.screenWidth * 0.1,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.01),
                                      padding: EdgeInsets.symmetric(
                                          horizontal: utils.screenWidth * 0.03),
                                      decoration: BoxDecoration(
                                          color: Colors.white,
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.grey[300]!,
                                                blurRadius: 5)
                                          ],
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: TextField(
                                          controller: code6Controller,
                                          focusNode: codesFocus[5],
                                          cursorColor: utils.secundaryColor,
                                          keyboardType: TextInputType.phone,
                                          maxLength: 1,
                                          onChanged: (val) {
                                            if (val.length == 1) {
                                              codesFocus[5].unfocus();
                                            }
                                          },
                                          style: TextStyle(
                                              fontSize:
                                                  utils.screenWidth * 0.04),
                                          decoration: const InputDecoration(
                                            counterText: '',
                                            border: InputBorder.none,
                                          )),
                                    ),
                                  ],
                                ),
                              ),
                              GestureDetector(
                                onTap: () {
                                  validateCode();
                                },
                                child: Hero(
                                  tag: 'continueButton',
                                  child: Container(
                                    margin: EdgeInsets.only(
                                        top: utils.absoluteHeight * 0.03),
                                    padding: EdgeInsets.symmetric(
                                        vertical: utils.absoluteHeight * 0.017,
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
                                          fontSize: utils.screenWidth * 0.045),
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          )
                        ],
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
