import 'package:cloud_firestore/cloud_firestore.dart';

class userModel{
  final String? id;
  final String name;
  final String email;
  final String phone;
  final String password;
  final String video;

  const userModel({
    this.id,
    required this.name,
    required this.email,
    required this.phone,
    required this.password,
    required this.video,
});


  toJson(){
    return {"name":name, "email":email, "phone":phone, "password":password};
  }

  factory userModel.fromSnapshot(DocumentSnapshot<Map<String,dynamic>> document){
    final data = document.data()!;
    return userModel(
      id: document.id,
        name: data['name'],
        email: data['email'],
        phone: data["phone"],
        password: data['password'],
        video: data['video'],
    );
  }
}