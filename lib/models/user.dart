class AppUser {
  late String uid;  
  late bool enable;
  late Map<String, dynamic> profileInfo;    
  late Map<String, dynamic>? asteroids;

  AppUser(
      {required this.uid,      
      required this.profileInfo,    
      required this.enable,
      this.asteroids
      });
}