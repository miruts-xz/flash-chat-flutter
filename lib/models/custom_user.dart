class CustomUser {
  final String uid;
  final String displayName;
  final String photoUrl;
  final String email;
  CustomUser({this.uid, this.displayName,this.photoUrl, this.email});

  factory CustomUser.fromJson(Map<String, dynamic> json){
    return CustomUser(
      uid: json['uid'],
      displayName: json['displayName'],
      photoUrl: json['photoUrl'],
      email: json['email'],
    );
  }
}
