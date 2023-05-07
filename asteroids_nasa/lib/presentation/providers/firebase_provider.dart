// ignore_for_file: use_build_context_synchronously

import 'package:asteroids_nasa/models/user.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/home/home.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/otp_verification.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/register.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/welcome.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class FirebaseProvider extends ChangeNotifier {
  Utils utils = Utils();
  late FirebaseApp app;
  late FirebaseAuth auth;
  late FirebaseFirestore db;
  late SharedPreferences shared;
  late AppUser? user;

  bool codeSent = false;
  String? verificationId;
  String currentRoute = "";
  String? auxUid;
  int contador = 0;

  Map<String, dynamic>? tempDriverInfo;

  Future<void> initializeFiebaseApp() async {
    try {
      app = await Firebase.initializeApp();
      auth = FirebaseAuth.instance;
      db = FirebaseFirestore.instance;
      shared = await SharedPreferences.getInstance();
    } catch (e) {
      debugPrint('ERROR initializeFirebaseAoo: $e');
    }
  }

  Future<void> sendCodeVerification(
    BuildContext context,
    MethodsProvider methods,
    String phoneNumber,
    String from,
  ) async {
    
    try {
      print(phoneNumber);
      print(from);
      methods.showLoadingDialog(context);
      await auth.verifyPhoneNumber(
        timeout: const Duration(seconds: 60),
        phoneNumber: '+57 $phoneNumber',
        verificationCompleted: (PhoneAuthCredential credential) async {
          debugPrint('VERIFICATION COMPLETE');
          codeSent = false;
          verificationId = null;
          notifyListeners();
          if (!utils.loadingDialog) {
            methods.showLoadingDialog(context);
          }
          String result;
          if (from != 'register') {
            result = await phoneSignIn(context, credential);
          } else {
            result = await linkPhoneNumber(credential);
          }
          if (result == 'userData') {
            methods.hideLoadingDialog(context);
            currentRoute = "home";
            validatedEstadoUsuario(context);
            Navigator.of(context).pushReplacementNamed(Home.routeName);
          } else if (result == 'driverData' || result == 'noData') {
            methods.hideLoadingDialog(context);
            currentRoute = "register";
            Navigator.of(context).pushReplacementNamed(
              Register.routeName,
              arguments: {
                'type': 'phone',
                'phone': phoneNumber,
              },
            );
          } else if (result == 'linked') {
            methods.hideLoadingDialog(context);
            currentRoute = "home";
            Navigator.of(context).pushReplacementNamed(Home.routeName);
          } else if (result == 'linkedError') {
            methods.hideLoadingDialog(context);
            currentRoute = "home";
            Navigator.of(context).pushReplacementNamed(Home.routeName);
          } else if (result == 'error') {
            methods.hideLoadingDialog(context);
            utils.showFlushbar(
                context: context,
                title: 'Ocurrió un error',
                message: 'Intenta nuevamente');
          }
        },
        verificationFailed: (FirebaseAuthException e) {
          codeSent = false;
          verificationId = null;
          notifyListeners();
          if (methods.loadingDialog) {
            methods.hideLoadingDialog(context);
          }
          debugPrint('VERIFICATION FAILED');
          // print(e);
          utils.showFlushbar(
            context: context,
            title: 'Ocurrió un error',
            message: 'Intenta nuevamente',
          );
        },
        codeSent: (String verificationId, int? forceResend) {
          if (methods.loadingDialog) {
            methods.hideLoadingDialog(context);
          }
          codeSent = true;
          this.verificationId = verificationId;
          // result = 'codeSent';
          notifyListeners();
          currentRoute = "otp-verification";
          Navigator.of(context).pushNamed(
            OtpVerification.routeName,
            arguments: {
              'phone': phoneNumber,
              'from': from,
            },
          );
        },
        codeAutoRetrievalTimeout: (String retrival) {
          if (codeSent) {
            if (methods.loadingDialog) {
              methods.hideLoadingDialog(context);
            }
            codeSent = false;
            verificationId = null;
            notifyListeners();
            debugPrint('VERIFICATION TIMEOUT');
            if (currentRoute == "otp-verification") {
              Navigator.of(context).pop();
            }
          }
        },
      );
    } catch (e) {
      codeSent = false;
      verificationId = null;
      notifyListeners();
      debugPrint('ERROR sendCodeVerification: $e');
      if (methods.loadingDialog) {
        methods.hideLoadingDialog(context);
      }
      utils.showFlushbar(
          context: context,
          title: 'Ocurrió un error',
          message: 'Intenta nuevamente');
    }
  }

  // Future<String> phoneSignIn(
  //     BuildContext context, PhoneAuthCredential credential) async {
  //   try {
  //     UserCredential userCred = await auth.signInWithCredential(credential);
  //     DocumentSnapshot documentSnapshot =
  //         await db.collection('users').doc(userCred.user!.uid).get();
  //     Map<String, dynamic>? userData =
  //         documentSnapshot.data() as Map<String, dynamic>?;
  //     codeSent = false;
  //     verificationId = null;
  //     auxUid = userCred.user!.uid;
  //     notifyListeners();
  //     if (userData != null) {
  //       user = AppUser(
  //           uid: userCred.user!.uid,
  //           notificationId: userData['notification_id'],
  //           profileInfo: userData['profile_info'],
  //           saveAddresses: userData['save_addresses'],
  //           agreement: userData['agreement'],
  //           wallet: userData['wallet'].toDouble(),
  //           user_fmasivo: userData['user_fmasivo'],
  //           enable: userData['enable']);
  //       // if (user!.notificationId == '') {
  //       //   updateUserNotificationId(false);
  //       // }
  //       return 'userData';
  //     } else {
  //       DocumentSnapshot driverSnapshot =
  //           await db.collection('drivers').doc(userCred.user!.uid).get();
  //       Map<String, dynamic>? driverData =
  //           driverSnapshot.data() as Map<String, dynamic>?;
  //       if (driverData != null) {
  //         tempDriverInfo = {
  //           'uid': userCred.user!.uid,
  //           'name': driverData['profile_info']['names'],
  //           'lastNames': driverData['profile_info']['last_names'],
  //           'email': driverData['profile_info']['email'],
  //           'phone': driverData['profile_info']['phone'],
  //           'emgPhone': driverData['profile_info']['emg_phone1'],
  //         };
  //         return 'driverData';
  //       } else {
  //         if (auth.currentUser!.email != null) {
  //           tempDriverInfo = {
  //             'uid': userCred.user!.uid,
  //             'name': '',
  //             'lastNames': '',
  //             'email': auth.currentUser!.email,
  //             'phone': auth.currentUser!.phoneNumber,
  //             'emgPhone': '',
  //           };
  //           return 'driverData';
  //         } else {
  //           return 'noData';
  //         }
  //       }
  //     }
  //   } catch (e) {
  //     debugPrint('ERROR phoneSignin: $e');
  //     return 'error';
  //   }
  // }

  Future<String> linkPhoneNumber(PhoneAuthCredential credential) async {
    try {
      await auth.currentUser!.reload();
      await auth.currentUser!.linkWithCredential(credential);
      return 'linked';
    } catch (e) {
      debugPrint('ERROR linkPhoneNumber: $e');
      return 'linkedError';
    }
  }

  Future<bool> verifyRepeatedEmail(String email) async {
    try {
      List<String> methods = await auth.fetchSignInMethodsForEmail(email);
      if (methods.contains('password')) {
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint('ERROR verifyRepeatedEmail');
      return false;
    }
  }

  Future<bool> verifyRepeatedPhone(String phone) async {
    try {
      Uri url = Uri.parse(
          'https://us-central1-econtainers2019.cloudfunctions.net/ls_verify_phone');
      http.Response resp = await http.post(url, body: phone);
      if (resp.statusCode == 200 && resp.body == 'true') {
        return false;
      } else {
        return true;
      }
    } catch (e) {
      debugPrint('ERROR verifyRepeatedEmail');
      return false;
    }
  }

  // Verify if sent code is correct
  Future<String> verifySentCode(BuildContext context, String verificationId,
      String code, String phoneNumber, String type) async {
    try {
      PhoneAuthCredential credential = PhoneAuthProvider.credential(
          verificationId: verificationId, smsCode: code);
      String result;
      if (type == 'auth') {
        result = await phoneSignIn(context, credential);
      } else {
        result = await linkPhoneNumber(credential);
      }
      return result;
    } catch (e) {
      debugPrint('ERROR verifySentCode: $e');
      return 'error';
    }
  }

  Future<String> emailRegister(BuildContext context, String email,
      String password, Map<String, dynamic> userData) async {
    try {
      UserCredential userCred = await auth.createUserWithEmailAndPassword(
          email: email, password: password);
      await auth.signInWithEmailAndPassword(email: email, password: password);
      if (userCred.user != null) {
        await db.collection('users').doc(userCred.user!.uid).set(userData);
        user = AppUser(
          uid: userCred.user!.uid,
          profileInfo: userData['profile_info'],
          enable: userData['enable'],
        );
        return 'success';
      } else {
        return 'error';
      }
    } catch (e) {
      debugPrint('ERROR emailAuthentication: $e');
      return 'error';
    }
  }

  Future<bool> validateFirstTime() async {
    try {
      bool? firsTime = shared.getBool("first_time");
      if (firsTime == null) {
        shared.setBool('first_time', false);
        return true;
      } else {
        return false;
      }
    } catch (e) {
      debugPrint("FirebaseProvider, validateFirstTime error: $e");
      return true;
    }
  }

  // Update user data from db
  Future<String> updateUserData(Map<String, dynamic> userData) async {
    try {
      await db.collection('users').doc(auxUid).set(userData);
      user = AppUser(
          uid: auxUid!,
          profileInfo: userData['profile_info'],
          enable: userData['enable']);
      auxUid = null;
      return 'success';
    } catch (e) {
      debugPrint('ERROR updateUserData: $e');
      return 'error';
    }
  }

  Future<String> linkEmail(String email, String password) async {
    try {
      AuthCredential emailAuthCredential =
          EmailAuthProvider.credential(email: email, password: password);
      await auth.currentUser!.reload();
      await auth.currentUser!.linkWithCredential(emailAuthCredential);
      return 'linked';
    } catch (e) {
      debugPrint('ERROR linkEmail: $e');
      return 'linkedError';
    }
  }

  Future<String> registerUserWithoutAuth(Map<String, dynamic> userData) async {
    try {
      await db.collection('users').doc(tempDriverInfo!['uid']).set(userData);
      user = AppUser(
        uid: tempDriverInfo!['uid'],
        profileInfo: userData['profile_info'],
        enable: userData['enable'],
      );
      return 'success';
    } catch (e) {
      debugPrint('ERROR registerUserWithoutAuth: $e');
      return 'error';
    }
  }

  Future<String> emailAuthentication(String email, String password) async {
    try {
      UserCredential userCredential = await auth.signInWithEmailAndPassword(
          email: email, password: password);
      if (userCredential.user != null) {
        shared.setString('email', email);
        DocumentSnapshot documentSnapshot =
            await db.collection('users').doc(userCredential.user!.uid).get();
        Map<String, dynamic>? userData =
            documentSnapshot.data() as Map<String, dynamic>?;
        if (userData != null) {
          // user = AppUser(
          //     uid: userCredential.user!.uid,
          //     notificationId: userData['notification_id'],
          //     profileInfo: userData['profile_info'],
          //     saveAddresses: userData['save_addresses'],
          //     agreement: userData['agreement'],
          //     wallet: userData['wallet'].toDouble(),
          //     user_fmasivo: userData['user_fmasivo'],
          //     enable: userData['enable']);
          // if (user!.notificationId == '') {
          //   updateUserNotificationId(false);
          // }
          return 'userData';
        } else {
          DocumentSnapshot driverSnapshot = await db
              .collection('drivers')
              .doc(userCredential.user!.uid)
              .get();
          Map<String, dynamic>? driverData =
              driverSnapshot.data() as Map<String, dynamic>?;
          if (driverData != null) {
            tempDriverInfo = {
              'uid': userCredential.user!.uid,
              'name': driverData['profile_info']['names'],
              'lastNames': driverData['profile_info']['last_names'],
              'email': driverData['profile_info']['email'],
              'phone': driverData['profile_info']['phone'].split('+57')[1],
              'emgPhone': driverData['profile_info']['emg_phone1'],
            };
            return 'driverData';
          } else {
            return 'error';
          }
        }
      } else {
        if (auth.currentUser != null) {
          auth.signOut();
        }
        return 'error';
      }
    } catch (e) {
      debugPrint('ERROR emailAuthentication: $e');
      if (auth.currentUser != null) {
        auth.signOut();
      }
      return 'error';
    }
  }

  Future<Map<String, dynamic>> googleSignIn() async {
    Map<String, dynamic> result = {};
    try {
      GoogleSignIn googleSignIn = GoogleSignIn();
      GoogleSignInAccount? googleSignInAccount = await googleSignIn.signIn();
      if (googleSignInAccount != null) {
        if (!await verifyRepeatedEmail(googleSignInAccount.email)) {
          GoogleSignInAuthentication googleSignInAuthentication =
              await googleSignInAccount.authentication;
          AuthCredential authCredential = GoogleAuthProvider.credential(
            accessToken: googleSignInAuthentication.accessToken,
            idToken: googleSignInAuthentication.idToken,
          );
          UserCredential userCred =
              await auth.signInWithCredential(authCredential);
          if (userCred.user != null && userCred.user!.email != null) {
            if (!await verifyRepeatedEmail(userCred.user!.email!)) {
              DocumentSnapshot documentSnapshot =
                  await db.collection('users').doc(userCred.user!.uid).get();
              Map<String, dynamic>? userData =
                  documentSnapshot.data() as Map<String, dynamic>?;
              if (userData != null) {
                return {'error': '', 'data': true};
              } else {
                auxUid = userCred.user!.uid;
                result = {
                  'error': '',
                  'data': false,
                  'type': 'social',
                  'name': userCred.user!.displayName,
                  'email': userCred.user!.email
                };
                return result;
              }
            } else {
              await auth.signOut();
              result = {'error': 'repeated'};
              return result;
            }
          } else {
            result = {'error': 'user'};
            return result;
          }
        } else {
          result = {'error': 'repeated'};
          return result;
        }
      } else {
        result = {'error': 'user'};
        return result;
      }
    } catch (e) {
      debugPrint('ERROR googleSignIn: $e');
      result = {'error': 'error'};
      return result;
    }
  }

  phoneSignIn(BuildContext context, PhoneAuthCredential credential) async {
    try {
      UserCredential userCred = await auth.signInWithCredential(credential);
      DocumentSnapshot documentSnapshot =
          await db.collection('users').doc(userCred.user!.uid).get();
      Map<String, dynamic>? userData =
          documentSnapshot.data() as Map<String, dynamic>?;
      codeSent = false;
      verificationId = null;
      auxUid = userCred.user!.uid;
      notifyListeners();
      if (userData != null) {
        user = AppUser(
            uid: userCred.user!.uid,            
            profileInfo: userData['profile_info'],
            enable: userData['enable']);        
        return 'userData';
      } else {
        DocumentSnapshot driverSnapshot =
            await db.collection('drivers').doc(userCred.user!.uid).get();
        Map<String, dynamic>? driverData =
            driverSnapshot.data() as Map<String, dynamic>?;
        if (driverData != null) {
          tempDriverInfo = {
            'uid': userCred.user!.uid,
            'name': driverData['profile_info']['names'],
            'lastNames': driverData['profile_info']['last_names'],
            'email': driverData['profile_info']['email'],
            'phone': driverData['profile_info']['phone'],
            'emgPhone': driverData['profile_info']['emg_phone1'],
          };
          return 'driverData';
        } else {
          if (auth.currentUser!.email != null) {
            tempDriverInfo = {
              'uid': userCred.user!.uid,
              'name': '',
              'lastNames': '',
              'email': auth.currentUser!.email,
              'phone': auth.currentUser!.phoneNumber,
              'emgPhone': '',
            };
            return 'driverData';
          } else {
            return 'noData';
          }
        }
      }
    } catch (e) {
      debugPrint('ERROR phoneSignin: $e');
      return 'error';
    }
  }

  // validar estado usuario al realizar autenticacion-logueo
  Future<void> validatedEstadoUsuario(BuildContext context) async {
    try {
      DocumentSnapshot documentSnapshot =
          await db.collection('users').doc('').get();
      Map<String, dynamic>? userData =
          documentSnapshot.data() as Map<String, dynamic>?;
      if (userData?['enable'] == false) {
        _showMyDialog(context);
      }
    } catch (e) {
      debugPrint('ERROR getGeneralInfo: $e');
    }
  }

  // Send an email to recover the password
  Future<String> sendRecoverPasswordEmail(String email) async {
    try {
      if (await verifyRepeatedEmail(email)) {
        await auth.sendPasswordResetEmail(email: email);
        return 'success';
      } else {
        return 'not found';
      }
    } catch (e) {
      debugPrint('ERROR sendRecoverPasswordEmail: $e');
      return 'error';
    }
  }

  //Dialog verificacion de cuenta inactiva
  Future<void> _showMyDialog(BuildContext context) async {
    return showDialog(
      context: context,
      barrierDismissible: false, // user must tap button!
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(
            '¿Desea activar su cuenta?',
            style: TextStyle(
                fontWeight: FontWeight.bold, color: utils.primaryColor),
          ),
          content: SingleChildScrollView(
            child: ListBody(
              children: const <Widget>[
                Text('Se restablecerán sus datos de usuario.'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              style: TextButton.styleFrom(
                  primary: utils.primaryColor, backgroundColor: Colors.white),
              child: const Text('Aceptar'),
              onPressed: () {
                updateEstadoUsuario(true);
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              style: TextButton.styleFrom(
                  primary: utils.backButton, backgroundColor: Colors.white),
              child: const Text('Cancelar'),
              onPressed: () {
                Navigator.of(context).pushReplacementNamed(
                  Welcome.routeName,
                );
              },
            ),
          ],
        );
      },
    );
  }

  // actualizar estado de usuario cuando se elimine cuenta
  Future<bool> updateEstadoUsuario(bool estado) async {
    bool estadoRetornado = false;
    try {
      contador = 0;
      await db.collection('users').doc('').update({'enable': estado});
      notifyListeners();
    } catch (e) {
      debugPrint('ERROR al cambiar estado usuario: $e');
    }
    return estadoRetornado;
  }

  // Log out user session
  Future<String> logOut() async {
    try {      
      await auth.signOut();      
      return 'success';
    } catch (e) {
      debugPrint('ERROR logOut: $e');
      return 'error';
    }
  }
}
