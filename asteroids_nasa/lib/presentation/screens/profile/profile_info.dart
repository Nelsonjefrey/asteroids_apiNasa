// ignore_for_file: use_build_context_synchronously

import 'dart:io';

import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/widgets/go_back_button.dart';
import 'package:asteroids_nasa/presentation/widgets/header.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:provider/provider.dart';
import 'package:file_picker/file_picker.dart';

class ProfileInfo extends StatefulWidget {
  static const routeName = 'profile-info';
  const ProfileInfo({Key? key}) : super(key: key);

  @override
  _ProfileInfoState createState() => _ProfileInfoState();
}

class _ProfileInfoState extends State<ProfileInfo> {
  Utils utils = Utils();

  bool dataLoaded = false;
  bool enableSave = false;

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

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);

      namesController.text = firebaseProvider.user!.profileInfo['names'];
      lastNamesController.text =
          firebaseProvider.user!.profileInfo['last_names'];
      phoneController.text = firebaseProvider.user!.profileInfo['phone'];
      emgPhoneController.text = firebaseProvider.user!.profileInfo['emg_phone'];
      emailController.text = firebaseProvider.user!.profileInfo['email'];
    }
    super.didChangeDependencies();
  }

  // Verify available name
  String validateNames() {
    return '';
  }

  // Verify available last name
  String validateLastNames() {
    return '';
  }

  // Verify if there are any changes in textfields
  void validateFields() {
    if (namesController.text != firebaseProvider.user!.profileInfo['names'] ||
        lastNamesController.text !=
            firebaseProvider.user!.profileInfo['last_names'] ||
        emgPhoneController.text !=
            firebaseProvider.user!.profileInfo['emg_phone']) {
      if (!enableSave) {
        setState(() {
          enableSave = true;
        });
      }
    } else if (namesController.text ==
            firebaseProvider.user!.profileInfo['names'] &&
        lastNamesController.text ==
            firebaseProvider.user!.profileInfo['last_names'] &&
        emgPhoneController.text ==
            firebaseProvider.user!.profileInfo['emg_phone']) {
      if (enableSave) {
        setState(() {
          enableSave = false;
        });
      }
    }
  }

  // Update user profile photo
  Future<void> changeProfilePhoto() async {
    try {
      FilePickerResult? result = await FilePicker.platform.pickFiles(
          type: FileType.image, allowMultiple: false, allowCompression: true);
      if (result != null && result.files.isNotEmpty) {
        methodsProvider.showLoadingDialog(context);
        Uri fileUri = Uri.file(result.files[0].path!);
        File filePhoto = File.fromUri(fileUri);
        Directory dir = await getTemporaryDirectory();
        String targetPath = '${dir.absolute.path}/profile_photo.jpg';
        File? compressedFile =
            await utils.compressPhoto(filePhoto.path, targetPath);
        if (compressedFile != null) {
          await firebaseProvider.loadProfilePhoto(compressedFile);
          methodsProvider.hideLoadingDialog(context);
        } else {
          methodsProvider.hideLoadingDialog(context);
          utils.showFlushbar(
              context: context,
              title: 'Ocurrió un error',
              message: 'No se pudo comprimir la foto. Intenta nuevamente');
        }
      }
    } catch (e) {
      if (methodsProvider.loadingDialog) {
        methodsProvider.hideLoadingDialog(context);
      }
      debugPrint('ERROR changeProfilePhoto: $e');
    }
  }

  // Validate fields and update user info
  Future<void> updateUserInfo() async {
    try {
      if (namesFocus.hasFocus) {
        namesFocus.unfocus();
      } else if (lastNamesFocus.hasFocus) {
        lastNamesFocus.unfocus();
      } else if (emgPhoneFocus.hasFocus) {
        emgPhoneFocus.unfocus();
      }
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
      } else if ('+57' + emgPhoneController.text == phoneController.text) {
        utils.showFlushbar(
            context: context,
            title: 'Espera',
            message: 'El número de emergencia está repetido');
        emgPhoneFocus.requestFocus();
      } else {
        Map<String, dynamic> userData = {
          'names': namesController.text,
          'last_names': lastNamesController.text,
          'emg_phone': emgPhoneController.text
        };
        methodsProvider.showLoadingDialog(context);
        String resp = await firebaseProvider.updateUserProfileInfo(userData);
        methodsProvider.hideLoadingDialog(context);
        if (resp == 'success') {
          validateFields();
          utils.showFlushbar(
              context: context,
              title: 'Listo',
              message: 'Información actualizada con exito');
        } else {
          utils.showFlushbar(
              context: context,
              title: 'Ocurrió un error',
              message: 'No se pudo actualizar los datos. Intenta nuevamente');
        }
      }
    } catch (e) {
      debugPrint('ERROR updateUserInfo: $e');
    }
  }
//

  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
            // Body
            Positioned(
              top: utils.absoluteHeight * 0.11,
              left: 10,
              right: 10,
              child: Container(
                margin: EdgeInsets.only(
                  left: utils.screenWidth * 0.08,
                  right: utils.screenWidth * 0.08,
                ),
                child: Column(
                  children: [
                    Container(
                      margin: EdgeInsets.only(
                          top: utils.absoluteHeight * 0.02,
                          bottom: utils.absoluteHeight * 0.02),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
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
                            'Información personal',
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
                    Stack(
                      children: [
                        // User photo
                        Container(
                            margin: EdgeInsets.only(
                                bottom: utils.absoluteHeight * 0.03),
                            width: utils.screenWidth * 0.35,
                            height: utils.absoluteHeight * 0.18,
                            decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(15),
                                boxShadow: [
                                  BoxShadow(
                                      color: Colors.grey[300]!, blurRadius: 5)
                                ]),
                            child: ((firebaseProvider
                                        .user!.profileInfo['photo_url'] !=
                                    '')
                                ? GestureDetector(
                                    onTap: () {
                                      utils.showImageDialog(
                                          context,
                                          firebaseProvider
                                              .user!.profileInfo['photo_url']);
                                    },
                                    child: ClipRRect(
                                      borderRadius: BorderRadius.circular(15),
                                      child: Image.network(
                                        firebaseProvider
                                            .user!.profileInfo['photo_url'],
                                        fit: BoxFit.fill,
                                      ),
                                    ),
                                  )
                                : Icon(
                                    Icons.person,
                                    size: utils.screenWidth * 0.1,
                                  ))),
                        // Change photo button
                        Positioned(
                          top: 0,
                          right: 0,
                          child: GestureDetector(
                            onTap: () {
                              changeProfilePhoto();
                            },
                            child: Container(
                              padding: const EdgeInsets.all(8),
                              decoration: BoxDecoration(
                                  color: utils.primaryColor,
                                  borderRadius: BorderRadius.circular(10)),
                              child: Icon(
                                Icons.edit,
                                color: Colors.white,
                                size: utils.screenWidth * 0.05,
                              ),
                            ),
                          ),
                        )
                      ],
                    ),
                    Row(
                      children: [
                        // Name field
                        Flexible(
                          child: Container(
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
                                },
                                onChanged: (val) {
                                  validateFields();
                                },
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
                                )),
                          ),
                        ),
                        // Last Names field
                        Flexible(
                          child: Container(
                            margin: EdgeInsets.only(
                                left: utils.screenWidth * 0.015),
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
                              },
                              onChanged: (val) {
                                validateFields();
                              },
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
                                    color:
                                        utils.secundaryColor.withOpacity(0.7)),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    // Phone field
                    Container(
                      margin: EdgeInsets.only(top: utils.absoluteHeight * 0.02),
                      padding: EdgeInsets.symmetric(
                          horizontal: utils.screenWidth * 0.03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                          ]),
                      child: TextField(
                        controller: phoneController,
                        maxLength: 10,
                        readOnly: true,
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
                              color: utils.secundaryColor.withOpacity(0.7)),
                        ),
                      ),
                    ),                                        
                    // Email field
                    Container(
                      margin: EdgeInsets.only(top: utils.absoluteHeight * 0.02),
                      padding: EdgeInsets.symmetric(
                          horizontal: utils.screenWidth * 0.03),
                      decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(10),
                          boxShadow: [
                            BoxShadow(color: Colors.grey[300]!, blurRadius: 5)
                          ]),
                      child: TextField(
                        controller: emailController,
                        readOnly: true,
                        cursorColor: utils.secundaryColor,
                        style: TextStyle(
                            fontSize: utils.screenWidth * 0.04,
                            color: utils.secundaryColor),
                        decoration: InputDecoration(
                          border: InputBorder.none,
                          labelText: 'Correo electrónico',
                          labelStyle: TextStyle(
                              fontWeight: FontWeight.w600,
                              color: utils.secundaryColor.withOpacity(0.7)),
                        ),
                      ),
                    ),
                    GestureDetector(
                      onTap: () async {
                        if (enableSave) {
                          updateUserInfo();
                        }
                      },
                      child: Container(
                          margin: EdgeInsets.only(
                              top: utils.absoluteHeight * 0.03,
                              bottom: utils.absoluteHeight * 0.03),
                          padding: EdgeInsets.symmetric(
                              horizontal: utils.screenWidth * 0.1,
                              vertical: utils.absoluteHeight * 0.015),
                          decoration: BoxDecoration(
                              color: (enableSave)
                                  ? utils.secundaryColor
                                  : Colors.grey,
                              borderRadius: BorderRadius.circular(10)),
                          child: Text(
                              'Guardar cambios',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontSize: utils.screenWidth * 0.043,
                                  fontWeight: FontWeight.bold))),
                    ),                    
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    )));
  }
}
