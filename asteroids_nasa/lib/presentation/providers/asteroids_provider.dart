import 'package:asteroids_nasa/models/asteroids.dart';
import 'package:asteroids_nasa/models/user.dart';
import 'package:asteroids_nasa/utils/utils.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

class AsteroidsProvider extends ChangeNotifier {
  Utils utils = Utils();

  late FirebaseFirestore db;
  late AppUser? user;
  List misAsteroids = [];

  
}
