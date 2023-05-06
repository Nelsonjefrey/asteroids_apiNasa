// ignore_for_file: use_build_context_synchronously

import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/home/home.dart';
import 'package:asteroids_nasa/presentation/widgets/go_back_button.dart';
import 'package:asteroids_nasa/presentation/widgets/header.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'register.dart';

// ignore: must_be_immutable
class EmailSignIn extends StatefulWidget {
  static const routeName = 'email-sign-in';
  const EmailSignIn({
    Key? key,
  }) : super(key: key);

  @override
  _EmailSignInState createState() => _EmailSignInState();
}

class _EmailSignInState extends State<EmailSignIn> {
  bool dataLoaded = false;
  Utils utils = Utils();
  bool showPassword = false;

  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;

  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController emailToRecoverController = TextEditingController();

  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();

  FocusNode emailToRecoverFocus = FocusNode();

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
      // if (firebaseProvider.shared.getString('email') != null) {
      //   emailController.text = firebaseProvider.shared.getString('email')!;
      // }
    }
    super.didChangeDependencies();
  }

  void validateFields() async {
    try {
      if (emailController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar un correo');
      } else if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text)) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar un correo válido');
      } else if (passwordController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar una contraseña');
      } else if (!await firebaseProvider
          .verifyRepeatedEmail(emailController.text)) {
        // ignore: use_build_context_synchronously
        utils.showFlushbar(
            context: context,
            title: 'Error',
            message: 'El correo no se encuentra registrado');
      } else {
        methodsProvider.showLoadingDialog(context);
        String result = await firebaseProvider.emailAuthentication(
            emailController.text, passwordController.text);
        if (result == 'userData') {
          // ignore: use_build_context_synchronously
          methodsProvider.hideLoadingDialog(context);
          firebaseProvider.currentRoute = "home";
          firebaseProvider.validatedEstadoUsuario(context);
          Navigator.of(context).pushReplacementNamed(Home.routeName);
        } else if (result == 'driverData') {
          methodsProvider.hideLoadingDialog(context);
          Navigator.of(context)
              .pushNamed(Register.routeName, arguments: {'type': 'email'});
        } else if (result == 'error') {
          methodsProvider.hideLoadingDialog(context);
          utils.showFlushbar(
              context: context,
              title: 'Espera',
              message: 'No pudimos obtener tu información. Intenta nuevamente');
        }
      }
    } catch (e) {
      debugPrint('ERROR auth validateFields: $e');
      if (methodsProvider.loadingDialog) {
        methodsProvider.hideLoadingDialog(context);
      }
    }
  }

  // Show a bottom modal for for recover password
  void showRecoverPasswordModal() {
    try {
      emailToRecoverController.text = emailController.text;

      Future<void> validateEmailToRecover(BuildContext modalContext) async {
        try {
          if (emailToRecoverController.text.isEmpty) {
            utils.showFlushbar(
                context: context,
                title: 'Espera',
                message: 'Ingresa un correo');
          } else if (!RegExp(
                  r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
              .hasMatch(emailToRecoverController.text)) {
            utils.showFlushbar(
                context: context,
                title: 'Espera',
                message: 'Debes ingresar un correo válido');
          } else {
            methodsProvider.showLoadingDialog(context);
            String result = await firebaseProvider
                .sendRecoverPasswordEmail(emailToRecoverController.text);
            if (result == 'success') {
              methodsProvider.hideLoadingDialog(context);
              Navigator.of(modalContext).pop();
              utils.showFlushbar(
                  context: context,
                  title: 'Listo',
                  message: 'Se te ha envíado un correo para recuperar tu contraseña');
            } else if (result == 'not found') {
              methodsProvider.hideLoadingDialog(context);
              utils.showFlushbar(
                  context: context,
                  title: 'Espera',
                  message: 'El correo no se encuentra registrado');
            } else {
              methodsProvider.hideLoadingDialog(context);
              utils.showFlushbar(
                  context: context,
                  title: 'Espera',
                  message: 'No se pudo enviar el correo. Intenta nuevamente');
            }
          }
        } catch (e) {
          debugPrint('ERROR validateEmailToRecover: $e');
          if (methodsProvider.loadingDialog) {
            methodsProvider.hideLoadingDialog(context);
          }
        }
      }

      // Modal to send and email to rever password
      showModalBottomSheet(
          context: context,
          backgroundColor: Colors.transparent,
          barrierColor: Colors.black.withOpacity(0.4),
          isScrollControlled: true,
          builder: (modalContext) {
            return StatefulBuilder(
                builder: (BuildContext context, StateSetter set) {
              return Container(
                height: utils.absoluteHeight * 0.35,
                padding:
                    EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.1),
                margin: EdgeInsets.only(
                    bottom: MediaQuery.of(context).viewInsets.bottom),
                decoration: const BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.only(
                        topLeft: Radius.circular(15),
                        topRight: Radius.circular(15))),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Container(
                      margin: EdgeInsets.only(top: utils.absoluteHeight * 0.04),
                      child: Text(
                        'Restablecer contraseña',
                        style: TextStyle(
                            color: utils.secundaryColor,
                            fontWeight: FontWeight.bold,
                            fontSize: utils.screenWidth * 0.045),
                      ),
                    ),
                    Container(
                      margin: EdgeInsets.only(top: utils.absoluteHeight * 0.02),
                      child: Text(
                        'Te enviaremos un correo para que puedas restablecer tu contraseña.',
                        style: TextStyle(
                            color: Colors.grey,
                            fontWeight: FontWeight.w400,
                            fontSize: utils.screenWidth * 0.038),
                      ),
                    ),
                    // Email fields
                    Container(
                      margin: EdgeInsets.only(
                        top: utils.absoluteHeight * 0.02,
                      ),
                      padding: EdgeInsets.symmetric(
                          horizontal: utils.screenWidth * 0.03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          boxShadow: [
                            BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                          ],
                          borderRadius: BorderRadius.circular(10)),
                      child: TextField(
                        controller: emailToRecoverController,
                        focusNode: emailToRecoverFocus,
                        style: TextStyle(
                            fontSize: utils.screenWidth * 0.04,
                            color: utils.secundaryColor),
                        cursorColor: utils.secundaryColor,
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: utils.secundaryColor),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () {
                        validateEmailToRecover(modalContext);
                      },
                      child: Container(
                        margin: EdgeInsets.only(
                          top: utils.absoluteHeight * 0.03,
                        ),
                        padding: EdgeInsets.symmetric(
                            horizontal: utils.screenWidth * 0.06,
                            vertical: utils.absoluteHeight * 0.012),
                        decoration: BoxDecoration(
                            color: utils.secundaryColor,
                            borderRadius: BorderRadius.circular(10)),
                        child: Text(
                          'Envíar correo',
                          style: TextStyle(
                              fontSize: utils.screenWidth * 0.042,
                              fontWeight: FontWeight.bold,
                              color: Colors.white),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            });
          });
    } catch (e) {
      debugPrint('ERROR showRecoverPasswordModal: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          emailFocus.unfocus();
          passwordFocus.unfocus();
          if (showPassword) {
            setState(() {
              showPassword = false;
            });
          }
        },
        child: Scaffold(
          body: Container(
            color: Colors.white,
            alignment: Alignment.center,
            child: Stack(
            children: [                
                // Header
                const Positioned(
                  top: 0,
                  child: Hero(tag: 'header', child: Header()),
                ),
                // Go back button
                Positioned(
                  top: utils.absoluteHeight * 0.15,
                  left: utils.screenWidth * 0.06,
                  child: Hero(
                    tag: 'goback',
                    child: GoBackButton(
                      type: 1,
                      screenWidth: utils.screenWidth,
                      onTap: () {
                        Navigator.of(context).pop();
                      },
                    ),
                  ),
                ),
                // Body
                Positioned(
                  top: utils.absoluteHeight * 0.2,
                  left: utils.screenWidth * 0.1,
                  right: utils.screenWidth * 0.1,
                  child: SizedBox(
                    child: Column(
                      // mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Hero(
                          tag: 'icon',
                          child: Container(
                            width: utils.screenWidth * 0.25,
                            // height: utils.absoluteHeight * 0.13,
                            decoration: BoxDecoration(
                                color: utils.primaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Icon(
                              Icons.email,
                              color: Colors.white,
                              size: utils.screenWidth * 0.17,
                            ),
                          ),
                        ),
                        Container(
                          margin: EdgeInsets.only(
                            top: utils.absoluteHeight * 0.06,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: utils.screenWidth * 0.03),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[300]!, blurRadius: 5)
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                            controller: emailController,
                            focusNode: emailFocus,
                            keyboardType: TextInputType.emailAddress,
                            style: TextStyle(
                                fontSize: utils.screenWidth * 0.04,
                                color: utils.secundaryColor),
                            cursorColor: utils.secundaryColor,
                            decoration: InputDecoration(
                              counterText: '',
                              border: InputBorder.none,
                              labelText: 'Correo electrónico',
                              labelStyle: TextStyle(
                                  fontWeight: FontWeight.w600,
                                  color: utils.secundaryColor),
                            ),
                          ),
                        ),
                        // Password field
                        Container(
                          margin: EdgeInsets.only(
                            top: utils.absoluteHeight * 0.03,
                          ),
                          padding: EdgeInsets.symmetric(
                              horizontal: utils.screenWidth * 0.03),
                          decoration: BoxDecoration(
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: Colors.grey[300]!, blurRadius: 5)
                              ],
                              borderRadius: BorderRadius.circular(10)),
                          child: TextField(
                              controller: passwordController,
                              focusNode: passwordFocus,
                              obscureText: (!showPassword) ? true : false,
                              style: TextStyle(
                                  fontSize: utils.screenWidth * 0.04,
                                  color: utils.secundaryColor),
                              cursorColor: utils.secundaryColor,
                              decoration: InputDecoration(
                                border: InputBorder.none,
                                labelText: 'Contraseña',
                                labelStyle: TextStyle(
                                    fontWeight: FontWeight.w600,
                                    color: utils.secundaryColor),
                                suffixIcon: GestureDetector(
                                  onTap: () {
                                    setState(() {
                                      showPassword = !showPassword;
                                    });
                                  },
                                  child: (showPassword)
                                      ? const Icon(
                                          Icons.remove_red_eye,
                                          color: Colors.grey,
                                        )
                                      : const Icon(
                                          Icons.remove_red_eye_outlined,
                                          color: Colors.grey,
                                        ),
                                ),
                              )),
                        ),
                        GestureDetector(
                          onTap: () {
                            validateFields();
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                top: utils.absoluteHeight * 0.05,
                                bottom: utils.absoluteHeight * 0.05),
                            padding: EdgeInsets.symmetric(
                                vertical: utils.absoluteHeight * 0.017,
                                horizontal: utils.screenWidth * 0.1),
                            decoration: BoxDecoration(
                                color: utils.secundaryColor,
                                borderRadius: BorderRadius.circular(10)),
                            child: Text(
                              'Iniciar sesión',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold,
                                  fontSize: utils.screenWidth * 0.045),
                            ),
                          ),
                        ),
                        Text(
                          'No recuerdas tu contraseña?',
                          style: TextStyle(
                              fontWeight: FontWeight.w300,
                              color: utils.secundaryColor,
                              fontSize: utils.screenWidth * 0.04),
                        ),
                        GestureDetector(
                          onTap: () {
                            showRecoverPasswordModal();
                          },
                          child: Container(
                            margin: EdgeInsets.only(
                                top: utils.absoluteHeight * 0.005),
                            child: Text(
                              'Restablecer',
                              style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  color: utils.secundaryColor,
                                  fontSize: utils.screenWidth * 0.042),
                            ),
                          ),
                        ),
                        Container(
                          margin:
                              EdgeInsets.only(top: utils.absoluteHeight * 0.1),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text(
                                  'No has creado una cuenta?',
                                  style: TextStyle(
                                      fontWeight: FontWeight.w300,
                                      color: utils.secundaryColor,
                                      fontSize: utils.screenWidth * 0.04)),
                              GestureDetector(
                                onTap: () {
                                  firebaseProvider.currentRoute = "register";
                                  Navigator.of(context).pushNamed(
                                    Register.routeName,
                                    arguments: {'type': 'email'},
                                  );
                                },
                                child: Container(
                                  margin: EdgeInsets.only(
                                      left: utils.screenWidth * 0.03),
                                  child: Text(
                                      'Registrarme',
                                      style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          color: utils.secundaryColor,
                                          fontSize: utils.screenWidth * 0.042)),
                                ),
                              )
                            ],
                          ),
                        )
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
