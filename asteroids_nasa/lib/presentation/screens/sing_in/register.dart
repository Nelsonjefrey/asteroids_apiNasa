// ignore_for_file: use_build_context_synchronously

import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/home/home.dart';
import 'package:asteroids_nasa/presentation/widgets/go_back_button.dart';
import 'package:asteroids_nasa/presentation/widgets/header.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

class Register extends StatefulWidget {
  static const routeName = 'register';
  const Register({Key? key}) : super(key: key);

  @override
  _RegisterState createState() => _RegisterState();
}

class _RegisterState extends State<Register> {
  bool dataLoaded = false;
  Utils utils = Utils();

  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;

  TextEditingController namesController = TextEditingController();
  TextEditingController lastNamesController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emgPhoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController password2Controller = TextEditingController();

  FocusNode namesFocus = FocusNode();
  FocusNode lastNamesFocus = FocusNode();
  FocusNode phoneFocus = FocusNode();
  FocusNode emgPhoneFocus = FocusNode();
  FocusNode emailFocus = FocusNode();
  FocusNode passwordFocus = FocusNode();
  FocusNode password2Focus = FocusNode();

  bool showPassword = false;
  bool showPassword2 = false;
  bool terms = false;

  String? emailResult;
  String? phoneResult;

  late Map<String, dynamic> arguments;

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
      arguments =
          ModalRoute.of(context)!.settings.arguments as Map<String, dynamic>;
      if (firebaseProvider.tempDriverInfo != null) {
        namesController.text = firebaseProvider.tempDriverInfo!['name'];
        lastNamesController.text =
            firebaseProvider.tempDriverInfo!['lastNames'];
        phoneController.text = firebaseProvider.tempDriverInfo!['phone'];
        emailController.text = firebaseProvider.tempDriverInfo!['email'];
        emgPhoneController.text = firebaseProvider.tempDriverInfo!['emgPhone'];
      }
      if (arguments['type'] != 'email') {
        if (arguments['type'] == 'phone') {
          phoneController.text = arguments['phone'];
        } else {
          if (arguments['name'] != null) {
            namesController.text = arguments['name'];
          }
          if (arguments['lastName'] != null) {
            lastNamesController.text = arguments['lastName'];
          }
          emailController.text = arguments['email'];
        }
      }
    }
    super.didChangeDependencies();
  }

  // Validate all register fields before create a new user
  void validateFields() async {
    try {
      if (namesController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar tu nombre');
        namesFocus.requestFocus();
      } else if (lastNamesController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar tu apellido');
        lastNamesFocus.requestFocus();
      } else if (phoneController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar tu número de celular');
        phoneFocus.requestFocus();
      } else if (phoneController.text.length < 10) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Número de celular invalido');
        phoneFocus.requestFocus();
        // } else if (emgPhoneController.text.isEmpty) {
        //   utils.showFlushbar(
        //       context: context,
        //       title: utils.localeTexts!['register_flushbar5_title'],
        //       message: utils.localeTexts!['register_flushbar5_text']);
        //   emgPhoneFocus.requestFocus();
      } else if (emgPhoneController.text.isNotEmpty &&
          emgPhoneController.text.length != 10) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar un número de emergencia válido');
        emgPhoneFocus.requestFocus();
      } else if (emgPhoneController.text.isNotEmpty &&
          (emgPhoneController.text == phoneController.text)) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'El número de emergencia está repetido');
        emgPhoneFocus.requestFocus();
      } else if (!RegExp(
              r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
          .hasMatch(emailController.text)) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar un correo válido');
        emailFocus.requestFocus();
      } else if (arguments['type'] != 'social' &&
          firebaseProvider.tempDriverInfo == null &&
          passwordController.text.isEmpty) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Debes ingresar una contraseña');
        passwordFocus.requestFocus();
      } else if (arguments['type'] != 'social' &&
          firebaseProvider.tempDriverInfo == null &&
          passwordController.text.length < 6) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'La contraseña debe tener mínimo 6 caracteres');
        passwordFocus.requestFocus();
      } else if (arguments['type'] != 'social' &&
          firebaseProvider.tempDriverInfo == null &&
          password2Controller.text != passwordController.text) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'Las contraseñas no coinciden');
        password2Focus.requestFocus();
      } else {
        methodsProvider.showLoadingDialog(context);
        if (arguments['type'] != 'social' &&
            firebaseProvider.tempDriverInfo == null &&
            await firebaseProvider.verifyRepeatedEmail(emailController.text)) {
          methodsProvider.hideLoadingDialog(context);
          utils.showFlushbar(
              context: context,
              title: 'Espera',
              message: 'El correo ya se encuentra registrado');

          emailFocus.requestFocus();
        } else if (arguments['type'] != 'phone' &&
            firebaseProvider.tempDriverInfo == null &&
            await firebaseProvider
                .verifyRepeatedPhone('+57 $phoneController.text')) {
          methodsProvider.hideLoadingDialog(context);
          utils.showFlushbar(
              context: context,
              title: 'Espera',
              message: 'El número de celular ya se encuentra registrado');
          emailFocus.requestFocus();
        } else {
          Map<String, dynamic> userData = {
            'notification_id': '',
            'creation_date': DateTime.now(),
            'profile_info': {
              'names': namesController.text,
              'last_names': lastNamesController.text,
              'phone': '+57 $phoneController.text',
              'emg_phone': emgPhoneController.text,
              'email': emailController.text,
              'photo_url': ''
            },
            'save_addresses': [],
            'agreement': {},
            'wallet': 0.0,
            'user_fmasivo': false,
            'enable': true
          };
          if (firebaseProvider.tempDriverInfo != null) {
            // String result =
            //     await firebaseProvider.registerUserWithoutAuth(userData);
            // if (result == 'success') {
            //   methodsProvider.hideLoadingDialog(context);
            //   if (await firebaseProvider.validateFirstTime()) {                
            //   } else {
            //     firebaseProvider.currentRoute = "home";
            //     Navigator.of(context).pushReplacementNamed(Home.routeName);
            //   }
            // } else {
            //   methodsProvider.hideLoadingDialog(context);
            //   utils.showFlushbar(
            //       context: context,
            //       title: utils.localeTexts!['register_flushbar15_title'],
            //       message: utils.localeTexts!['register_flushbar15_text']);
            // }
          } else if (arguments['type'] == 'email') {
            // String result = await firebaseProvider.emailRegister(
            //   context,
            //   emailController.text,
            //   passwordController.text,
            //   userData,
            // );
            // if (result == 'success') {
            //   methodsProvider.hideLoadingDialog(context);
            //   firebaseProvider.sendCodeVerification(
            //     context,
            //     methodsProvider,
            //     phoneController.text,
            //     'register',
            //   );
            // } else if (result == 'error') {
            //   methodsProvider.hideLoadingDialog(context);
            //   utils.showFlushbar(
            //       context: context,
            //       title: utils.localeTexts!['register_flushbar16_title'],
            //       message: utils.localeTexts!['register_flushbar16_text']);
            // }
          } else {
            if (arguments['type'] == 'phone') {
              // firebaseProvider.linkEmail(
              //     emailController.text, passwordController.text);
            }
            // String result = await firebaseProvider.updateUserData(userData);
            // if (result == 'success') {
            //   methodsProvider.hideLoadingDialog(context);
            //   firebaseProvider.currentRoute = "home";
            //   Navigator.of(context).pushReplacementNamed(Home.routeName);
            // } else {
            //   methodsProvider.hideLoadingDialog(context);
            //   utils.showFlushbar(
            //       context: context,
            //       title: utils.localeTexts!['register_flushbar17_title'],
            //       message: utils.localeTexts!['register_flushbar17_text']);
            // }
          }
        }
      }
    } catch (e) {
      debugPrint('ERROR validateFields: $e');
      if (methodsProvider.loadingDialog) {
        methodsProvider.hideLoadingDialog(context);
      }
      utils.showFlushbar(
          context: context,
          title: 'Error',
          message: 'No se pudo realizar el registro. Intenta nuevamente');
    }
  }

  // Verify available name
  String validateNames() {
    return '';
  }

  // Verify available last name
  String validateLastNames() {
    return '';
  }

  // Verify available phone
  Future<void> validatePhone() async {
    if (phoneController.text.isNotEmpty && phoneController.text.length != 10) {
      setState(() {
        phoneResult = 'Número inválido';
      });
    } else {
      setState(() {
        phoneResult = 'Verificando';
      });
      if (await firebaseProvider
          .verifyRepeatedPhone('+57 $phoneController.text')) {
        setState(() {
          phoneResult = 'Número ya se encuentra registrado';
        });
      } else {
        setState(() {
          phoneResult = '';
        });
      }
    }
  }

  // Verify available emg phone
  String validateEmgPhone() {
    if (emgPhoneController.text.isNotEmpty &&
        emgPhoneController.text.length != 10) {
      return 'Número inválido';
    } else if (emgPhoneController.text.isNotEmpty &&
        (emgPhoneController.text == phoneController.text)) {
      return 'Número ya se encuentra registrado';
    } else {
      return '';
    }
  }

  // Verify available email
  Future<void> validateEmail() async {
    if (emailController.text.isNotEmpty &&
        !RegExp(r"^[a-zA-Z0-9.a-zA-Z0-9.!#$%&'*+-/=?^_`{|}~]+@[a-zA-Z0-9]+\.[a-zA-Z]+")
            .hasMatch(emailController.text)) {
      setState(() {
        emailResult = 'Correo inválido';
      });
    } else {
      setState(() {
        emailResult = 'Verificando';
      });      
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: GestureDetector(
        onTap: () {
          namesFocus.unfocus();
          lastNamesFocus.unfocus();
          phoneFocus.unfocus();
          emgPhoneFocus.unfocus();
          emailFocus.unfocus();
          passwordFocus.unfocus();
          password2Focus.unfocus();
          if (showPassword || showPassword2) {
            setState(() {
              showPassword = false;
              showPassword2 = false;
            });
          }
        },
        child: Scaffold(
          body: Container(
            height: utils.absoluteHeight,
            color: Colors.white,
            alignment: Alignment.center,
            child: Stack(
              children: [
                Positioned(
                    left: -utils.screenWidth * 0.19,
                    top: utils.absoluteHeight * 0.05,
                    child: Hero(
                      tag: 'background',
                      child: SizedBox(
                        width: utils.screenWidth * 0.8,
                        height: utils.absoluteHeight * 0.4,
                        child: Image.asset('assets/logos/container.png',
                            fit: BoxFit.fill, color: utils.primaryColor),
                      ),
                    )),
                // Header
                const Positioned(
                  top: 0,
                  child: Hero(
                    tag: 'header',
                    child: Header(),
                  ),
                ),
                // Body
                Positioned(
                  top: utils.absoluteHeight * 0.13,
                  left: 10,
                  right: 10,
                  bottom: 0,
                  child: Container(
                    margin: EdgeInsets.only(
                      left: utils.screenWidth * 0.08,
                      right: utils.screenWidth * 0.08,
                    ),
                    child: SingleChildScrollView(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 5),
                        child: Column(
                          children: [
                            Container(
                              margin: EdgeInsets.only(
                                  top: utils.absoluteHeight * 0.02,
                                  bottom: utils.absoluteHeight * 0.043),
                              child: Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Hero(
                                    tag: 'goback',
                                    child: GoBackButton(
                                        type: 1,
                                        screenWidth: utils.screenWidth,
                                        onTap: () {
                                          Navigator.of(context).pop();
                                        }),
                                  ),
                                  Text(
                                    'Registra tus datos',
                                    style: TextStyle(
                                        fontSize: utils.screenWidth * 0.05,
                                        color: utils.secundaryColor,
                                        fontWeight: FontWeight.bold),
                                  ),
                                  const SizedBox(
                                    width: 20,
                                  )
                                ],
                              ),
                            ),
                            Container(
                              margin: EdgeInsets.only(
                                  right: utils.screenWidth * 0.015),
                              padding: EdgeInsets.symmetric(
                                  horizontal: utils.screenWidth * 0.03),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[300]!, blurRadius: 5)
                                  ]),
                              child: TextField(
                                  controller: namesController,
                                  focusNode: namesFocus,
                                  keyboardType: TextInputType.name,
                                  onEditingComplete: () {
                                    namesFocus.nextFocus();
                                    setState(() {});
                                  },
                                  onTap: () => setState(() {}),
                                  cursorColor: utils.secundaryColor,
                                  maxLength: 20,
                                  style: TextStyle(
                                      fontSize: utils.screenWidth * 0.04,
                                      color: utils.secundaryColor),
                                  decoration: InputDecoration(
                                      counterText: '',
                                      border: InputBorder.none,
                                      labelText: 'Nombre',
                                      labelStyle: TextStyle(
                                          fontWeight: FontWeight.w600,
                                          color: utils.secundaryColor
                                              .withOpacity(0.7)),
                                      suffixIcon: ((validateNames() != '')
                                          ? Tooltip(
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              message: validateNames(),
                                              preferBelow: false,
                                              child: const Icon(Icons.error,
                                                  color: Colors.red))
                                          : (namesController.text.isNotEmpty)
                                              ? Icon(Icons.check,
                                                  color: utils.secundaryColor)
                                              : const SizedBox()))),
                            ),
                            // Last Names field
                            Container(
                              margin: EdgeInsets.only(
                                  top: utils.absoluteHeight * 0.02),
                              padding: EdgeInsets.symmetric(
                                  horizontal: utils.screenWidth * 0.03),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[300]!, blurRadius: 5)
                                  ]),
                              child: TextField(
                                controller: lastNamesController,
                                focusNode: lastNamesFocus,
                                onEditingComplete: () {
                                  lastNamesFocus.nextFocus();
                                  setState(() {});
                                },
                                onTap: () => setState(() {}),
                                cursorColor: utils.secundaryColor,
                                maxLength: 20,
                                style: TextStyle(
                                    fontSize: utils.screenWidth * 0.04,
                                    color: utils.secundaryColor),
                                decoration: InputDecoration(
                                    counterText: '',
                                    border: InputBorder.none,
                                    labelText: 'Apellidos',
                                    labelStyle: TextStyle(
                                        fontWeight: FontWeight.w600,
                                        color: utils.secundaryColor
                                            .withOpacity(0.7)),
                                    suffixIcon: ((validateLastNames() != '')
                                        ? Tooltip(
                                            triggerMode: TooltipTriggerMode.tap,
                                            message: validateLastNames(),
                                            preferBelow: false,
                                            child: const Icon(Icons.error,
                                                color: Colors.red))
                                        : (lastNamesController.text.isNotEmpty)
                                            ? Icon(Icons.check,
                                                color: utils.secundaryColor)
                                            : const SizedBox())),
                              ),
                            ),
                            // Phone field
                            Container(
                              margin: EdgeInsets.only(
                                  top: utils.absoluteHeight * 0.02),
                              padding: EdgeInsets.symmetric(
                                  horizontal: utils.screenWidth * 0.03),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[300]!, blurRadius: 5)
                                  ]),
                              child: TextField(
                                controller: phoneController,
                                focusNode: phoneFocus,
                                maxLength: 10,
                                readOnly: (arguments['type'] == 'phone' ||
                                        firebaseProvider.tempDriverInfo != null)
                                    ? true
                                    : false,
                                onEditingComplete: () {
                                  phoneFocus.nextFocus();
                                  setState(() {});
                                },
                                onChanged: (val) {
                                  validatePhone();
                                },
                                onTap: () => setState(() {}),
                                keyboardType: TextInputType.number,
                                cursorColor: utils.secundaryColor,
                                style: TextStyle(
                                    fontSize: utils.screenWidth * 0.04,
                                    color: utils.secundaryColor),
                                decoration: InputDecoration(
                                  counterText: '',
                                  border: InputBorder.none,
                                  labelText: 'Celular',
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: utils.secundaryColor
                                          .withOpacity(0.7)),
                                  prefix: Container(
                                      margin: EdgeInsets.only(
                                          right: utils.screenWidth * 0.02),
                                      child: Text(
                                        '+57',
                                        style: TextStyle(
                                            fontSize: utils.screenWidth * 0.04),
                                      )),
                                  suffixIcon: (phoneResult != null &&
                                          phoneResult != '')
                                      ? (phoneResult != 'Verificando')
                                          ? Tooltip(
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              message: phoneResult!,
                                              preferBelow: false,
                                              child: const Icon(Icons.error,
                                                  color: Colors.red))
                                          : Container(
                                              width: utils.screenWidth * 0.02,
                                              height:
                                                  utils.absoluteHeight * 0.03,
                                              padding: const EdgeInsets.all(10),
                                              child: CircularProgressIndicator(
                                                color: utils.secundaryColor,
                                              ),
                                            )
                                      : (phoneController.text.isNotEmpty)
                                          ? Icon(Icons.check,
                                              color: utils.secundaryColor)
                                          : const SizedBox(),
                                ),
                              ),
                            ),                            
                            // Email field
                            Container(
                              margin: EdgeInsets.only(
                                  top: utils.absoluteHeight * 0.02),
                              padding: EdgeInsets.symmetric(
                                  horizontal: utils.screenWidth * 0.03),
                              decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(10),
                                  boxShadow: [
                                    BoxShadow(
                                        color: Colors.grey[300]!, blurRadius: 5)
                                  ]),
                              child: TextField(
                                controller: emailController,
                                focusNode: emailFocus,
                                readOnly: (arguments['type'] == 'social' ||
                                        firebaseProvider.tempDriverInfo != null)
                                    ? true
                                    : false,
                                onEditingComplete: () {
                                  emailFocus.nextFocus();
                                  setState(() {});
                                },
                                onChanged: (val) {
                                  validateEmail();
                                },
                                onTap: () => setState(() {}),
                                keyboardType: TextInputType.emailAddress,
                                cursorColor: utils.secundaryColor,
                                style: TextStyle(
                                    fontSize: utils.screenWidth * 0.04,
                                    color: utils.secundaryColor),
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  labelText: 'Correo electrónico',
                                  labelStyle: TextStyle(
                                      fontWeight: FontWeight.w600,
                                      color: utils.secundaryColor
                                          .withOpacity(0.7)),
                                  suffixIcon: (emailResult != null &&
                                          emailResult != '')
                                      ? (emailResult != 'Verificando')
                                          ? Tooltip(
                                              triggerMode:
                                                  TooltipTriggerMode.tap,
                                              message: emailResult!,
                                              preferBelow: false,
                                              child: const Icon(Icons.error,
                                                  color: Colors.red))
                                          : Container(
                                              width: utils.screenWidth * 0.02,
                                              height:
                                                  utils.absoluteHeight * 0.03,
                                              padding: const EdgeInsets.all(10),
                                              child: CircularProgressIndicator(
                                                color: utils.secundaryColor,
                                              ),
                                            )
                                      : (emailController.text.isNotEmpty)
                                          ? Icon(Icons.check,
                                              color: utils.secundaryColor)
                                          : const SizedBox(),
                                ),
                              ),
                            ),
                            (firebaseProvider.tempDriverInfo == null &&
                                    (arguments['type'] == 'email' ||
                                        arguments['type'] == 'phone'))
                                ?
                                // Password field
                                Container(
                                    margin: EdgeInsets.only(
                                        top: utils.absoluteHeight * 0.02),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: utils.screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey[300]!,
                                              blurRadius: 5)
                                        ]),
                                    child: TextField(
                                      controller: passwordController,
                                      focusNode: passwordFocus,
                                      onEditingComplete: () {
                                        passwordFocus.nextFocus();
                                        setState(() {});
                                      },
                                      onTap: () => setState(() {}),
                                      obscureText:
                                          (showPassword) ? false : true,
                                      cursorColor: utils.secundaryColor,
                                      maxLength: 20,
                                      style: TextStyle(
                                          fontSize: utils.screenWidth * 0.04,
                                          color: utils.secundaryColor),
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        labelText: 'Contraseña',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: utils.secundaryColor
                                                .withOpacity(0.7)),
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
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            (firebaseProvider.tempDriverInfo == null &&
                                    (arguments['type'] == 'email' ||
                                        arguments['type'] == 'phone'))
                                ?
                                // Password verify field
                                Container(
                                    margin: EdgeInsets.only(
                                        top: utils.absoluteHeight * 0.02),
                                    padding: EdgeInsets.symmetric(
                                        horizontal: utils.screenWidth * 0.03),
                                    decoration: BoxDecoration(
                                        color: Colors.white,
                                        borderRadius: BorderRadius.circular(10),
                                        boxShadow: [
                                          BoxShadow(
                                              color: Colors.grey[300]!,
                                              blurRadius: 5)
                                        ]),
                                    child: TextField(
                                      controller: password2Controller,
                                      focusNode: password2Focus,
                                      onEditingComplete: () {
                                        password2Focus.unfocus();
                                        setState(() {});
                                      },
                                      onTap: () => setState(() {}),
                                      obscureText:
                                          (showPassword2) ? false : true,
                                      cursorColor: utils.secundaryColor,
                                      style: TextStyle(
                                          fontSize: utils.screenWidth * 0.04,
                                          color: utils.secundaryColor),
                                      maxLength: 20,
                                      decoration: InputDecoration(
                                        counterText: '',
                                        border: InputBorder.none,
                                        labelText: 'Confirmar contraseña',
                                        labelStyle: TextStyle(
                                            fontWeight: FontWeight.w600,
                                            color: utils.secundaryColor
                                                .withOpacity(0.7)),
                                        suffixIcon: GestureDetector(
                                          onTap: () {
                                            setState(() {
                                              showPassword2 = !showPassword2;
                                            });
                                          },
                                          child: (showPassword2)
                                              ? const Icon(
                                                  Icons.remove_red_eye,
                                                  color: Colors.grey,
                                                )
                                              : const Icon(
                                                  Icons.remove_red_eye_outlined,
                                                  color: Colors.grey,
                                                ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const SizedBox(),
                            GestureDetector(
                              onTap: () {
                                validateFields();
                              },
                              child: Container(
                                  margin: EdgeInsets.only(
                                      top: utils.absoluteHeight * 0.03,
                                      bottom: utils.absoluteHeight * 0.03),
                                  padding: EdgeInsets.symmetric(
                                      horizontal: utils.screenWidth * 0.1,
                                      vertical: utils.absoluteHeight * 0.015),
                                  decoration: BoxDecoration(
                                      color: utils.secundaryColor,
                                      borderRadius: BorderRadius.circular(10)),
                                  child: Text(
                                      'Continuar',
                                      style: TextStyle(
                                          color: Colors.white,
                                          fontSize: utils.screenWidth * 0.043,
                                          fontWeight: FontWeight.bold))),
                            )
                          ],
                        ),
                      ),
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
