import 'package:asteroids_nasa/presentation/providers/firebase_provider.dart';
import 'package:asteroids_nasa/presentation/providers/methods_provider.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/authentication.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/widgets/carousel_item.dart';
import 'package:asteroids_nasa/presentation/screens/sing_in/widgets/footer.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:animate_do/animate_do.dart';

class Welcome extends StatefulWidget {
  static const routeName = 'welcome';
  const Welcome({Key? key}) : super(key: key);

  @override
  _WelcomeState createState() => _WelcomeState();
}

class _WelcomeState extends State<Welcome> {
  Utils utils = Utils();
  bool dataLoaded = false;

  late FirebaseProvider firebaseProvider;
  late MethodsProvider methodsProvider;

  late int currentPage = 0;

  CarouselController carouselController = CarouselController();

  // String _authStatus = 'Unknown';

  @override
  void didChangeDependencies() async {
    if (!dataLoaded) {
      dataLoaded = true;
      utils.screenWidth = MediaQuery.of(context).size.width;
      utils.absoluteHeight = MediaQuery.of(context).size.height -
          MediaQuery.of(context).viewPadding.top;
      firebaseProvider = Provider.of<FirebaseProvider>(context);
      methodsProvider = Provider.of<MethodsProvider>(context);
      firebaseProvider.initializeFiebaseApp();
    }
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    return SafeArea(
        child: WillPopScope(
      onWillPop: () async {
        return false;
      },
      child: Scaffold(
        body: SizedBox(
          height: utils.absoluteHeight,
          width: utils.screenWidth,
          child: Stack(
            children: [
              Positioned(
                top: 0,
                left: 0,
                right: 0,
                child: (currentPage == 0)
                    ? FadeIn(
                        child: Image.network(
                          'https://www.ngenespanol.com/wp-content/uploads/2023/02/cinturon-de-asteroides-sistema-solar.jpg',
                          height: utils.absoluteHeight * 0.85,
                          width: utils.screenWidth,
                          fit: BoxFit.fill,
                        ),
                      )
                    : (currentPage == 1)
                        ? FadeIn(
                            child: Image.network(
                              'https://cdn.milenio.com/uploads/media/2019/10/02/nasa-prepara-plan-defender-tierra_0_46_1000_623.jpg',
                              height: utils.absoluteHeight * 0.75,
                              width: utils.screenWidth,
                              fit: BoxFit.fill,
                            ),
                          )
                        : FadeIn(
                            child: Image.network(
                              'https://plustatic.com/3447/conversions/diferencias-asteroide-meteorito-meteoroide-social.jpg',
                              height: utils.absoluteHeight * 0.85,
                              width: utils.screenWidth,
                              fit: BoxFit.fill,
                            ),
                          ),
              ),
              Positioned(
                bottom: 0,
                left: 0,
                right: 0,
                child: Container(
                  height: utils.absoluteHeight * 0.43,
                  decoration: BoxDecoration(
                      color: utils.primaryColor,
                      borderRadius: const BorderRadius.only(
                          topLeft: Radius.circular(50),
                          topRight: Radius.circular(50))),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        margin:
                            EdgeInsets.only(top: utils.absoluteHeight * 0.005),
                        height: utils.absoluteHeight * 0.2,
                        width: utils.screenWidth,
                        child: CarouselSlider(
                          carouselController: carouselController,
                          options: CarouselOptions(
                            onPageChanged: (page, ints) {
                              setState(() {
                                currentPage = page;
                              });
                              // carouselController.animateToPage(page);
                            },
                            viewportFraction: 1,
                            autoPlay: true,
                            initialPage: currentPage,
                            autoPlayAnimationDuration:
                                const Duration(seconds: 2),
                          ),
                          items: const [
                            CarouselItem(
                              title: 'Cinturón de Asteroides',
                              text:
                                  'Es una región del espacio que se encuentra entre las órbitas de Marte y Júpiter, donde hay una concentración de numerosos asteroides.',
                            ),
                            CarouselItem(
                                title: 'Cometa',
                                text:
                                    'Es un objeto celeste compuesto principalmente por hielo, polvo y rocas que orbita alrededor del Sol.'),
                            CarouselItem(
                                title: 'Meteorito',
                                text:
                                    'Los meteoritos son restos de asteroides, cometas u otros objetos del espacio que se desprenden de su órbita original y caen sobre la Tierra.'),
                          ],
                        ),
                      ),
                      // Bottom indicators
                      SizedBox(
                        width: utils.screenWidth,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            GestureDetector(
                              onTap: () {
                                carouselController.animateToPage(0);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: utils.screenWidth * 0.017),
                                height: utils.absoluteHeight * 0.02,
                                width: utils.screenWidth * 0.03,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 10, color: utils.secundaryColor),
                                    shape: BoxShape.circle,
                                    color: (currentPage == 0)
                                        ? utils.secundaryColor
                                        : Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                carouselController.animateToPage(1);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: utils.screenWidth * 0.017),
                                height: utils.absoluteHeight * 0.02,
                                width: utils.screenWidth * 0.03,
                                decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                        width: 10, color: utils.secundaryColor),
                                    color: (currentPage == 1)
                                        ? utils.secundaryColor
                                        : Colors.white),
                              ),
                            ),
                            GestureDetector(
                              onTap: () {
                                carouselController.animateToPage(2);
                              },
                              child: Container(
                                margin: EdgeInsets.symmetric(
                                    horizontal: utils.screenWidth * 0.017),
                                height: utils.absoluteHeight * 0.02,
                                width: utils.screenWidth * 0.03,
                                decoration: BoxDecoration(
                                    border: Border.all(
                                        width: 10, color: utils.secundaryColor),
                                    shape: BoxShape.circle,
                                    color: (currentPage == 2)
                                        ? utils.secundaryColor
                                        : Colors.white),
                              ),
                            ),
                          ],
                        ),
                      ),
                      // WelcomePageBase button
                      GestureDetector(
                        onTap: () {
                          firebaseProvider.currentRoute = "authentication";
                          Navigator.of(context)
                              .pushNamed(Authentication.routeName);
                        },
                        child: Container(
                          margin: EdgeInsets.only(
                              top: utils.absoluteHeight * 0.03,
                              bottom: utils.absoluteHeight * 0.02),
                          width: utils.screenWidth * 0.6,
                          height: utils.absoluteHeight * 0.07,
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                              color: utils.confirmButton,
                              borderRadius: BorderRadius.circular(10),
                              boxShadow: [
                                BoxShadow(
                                    color:
                                        utils.secundaryColor.withOpacity(0.5),
                                    offset: const Offset(0, 3),
                                    blurRadius: 5)
                              ]),
                          child: Text(
                            'INICIAR SESIÓN',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: utils.screenWidth * 0.044,
                                fontFamily: 'TTSupermolotNeue',
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                      ),

                      const Footer()
                    ],
                  ),
                ),
              ),
              Positioned(
                  top: utils.absoluteHeight * 0.03,
                  right: 0,
                  left: 0,
                  child:
                      Align(alignment: Alignment.center, child: Container())),
            ],
          ),
        ),
      ),
    ));
  }
}
