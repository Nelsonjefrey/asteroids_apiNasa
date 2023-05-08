import 'package:asteroids_nasa/config/theme/app_theme.dart';
import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/home/home.dart';
import 'package:asteroids_nasa/presentation/screens/profile/profile_info.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/authentication.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/email_sign_in.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/otp_verification.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/register.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/welcome.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  runApp(MultiProvider(providers: [
    ChangeNotifierProvider(create: (_) => FirebaseProvider()),
    ChangeNotifierProvider(create: (_) => MethodsProvider())
  ], child: (const MyApp())));
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Asteroids',
      debugShowCheckedModeBanner: false,
      theme: AppTheme(selectedColor: 1).theme(),
      home: const Welcome(),
      routes: {
        Home.routeName: (BuildContext context) => const Home(),
        Authentication.routeName: (context) => const Authentication(),
        Welcome.routeName: (context) => const Welcome(),
        EmailSignIn.routeName: (BuildContext context) => const EmailSignIn(),
        Register.routeName: (BuildContext context) => const Register(),
        OtpVerification.routeName: (BuildContext context) => const OtpVerification(),
        ProfileInfo.routeName: (BuildContext context) => const ProfileInfo(),
      },
    );
  }
}
