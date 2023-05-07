class AppUser {
  late String uid;  
  late Map<String, dynamic> profileInfo;    
  late bool enable;

  AppUser(
      {required this.uid,      
      required this.profileInfo,    
      required this.enable});
}