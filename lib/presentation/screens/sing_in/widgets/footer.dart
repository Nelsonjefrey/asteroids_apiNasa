import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

class Footer extends StatefulWidget {
  const Footer({Key? key}) : super(key: key);

  @override
  _FooterState createState() => _FooterState();
}

class _FooterState extends State<Footer> {
  Utils utils = Utils();
  bool dataLoaded = false;

  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;

  @override
  void didChangeDependencies() {
    if (!dataLoaded) {
      dataLoaded = true;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      height: utils.absoluteHeight * 0.06,
      width: utils.screenWidth,
      color: utils.primaryColor,
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          //linkedin
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://www.linkedin.com/in/nelsonjgarcia/'));
            },
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.02),
              child: Image.network(
                'https://freeiconshop.com/wp-content/uploads/edd/linkedin-flat.png',
                width: utils.screenWidth * 0.06,
              ),
            ),
          ),
          //facebook
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://www.facebook.com/NelSoNJeFrE/'));
            },
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.02),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/5/51/Facebook_f_logo_%282019%29.svg/2048px-Facebook_f_logo_%282019%29.svg.png',
                width: utils.screenWidth * 0.06,
              ),
            ),
          ),
          //twitter
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://twitter.com/nelsonjefreii'));
            },
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.02),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/6/6f/Logo_of_Twitter.svg/2491px-Logo_of_Twitter.svg.png',
                width: utils.screenWidth * 0.06,
              ),
            ),
          ),
          //instagram
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://www.instagram.com/njgarcia0024/'));
            },
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.02),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/thumb/e/e7/Instagram_logo_2016.svg/2048px-Instagram_logo_2016.svg.png',
                width: utils.screenWidth * 0.06,
              ),
            ),
          ),
          //youtube
          GestureDetector(
            onTap: () {
              launchUrl(Uri.parse('https://www.youtube.com/watch?v=VQ2EyU75p2o&pp=ygUSZWxlY3Ryb25pY2EgZnVlZ28g'));
            },
            child: Container(
              margin:
                  EdgeInsets.symmetric(horizontal: utils.screenWidth * 0.02),
              child: Image.network(
                'https://upload.wikimedia.org/wikipedia/commons/e/ef/Youtube_logo.png',
                width: utils.screenWidth * 0.06,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
