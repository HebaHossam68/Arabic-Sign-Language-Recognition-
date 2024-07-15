import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/profilePage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:intl/intl.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';


class UpdatedProfile extends StatefulWidget {
  const UpdatedProfile({super.key});

  @override
  State<UpdatedProfile> createState() => _UpdatedProfileState();
}

class _UpdatedProfileState extends State<UpdatedProfile> {

  String? _email, _password, _confirmPass, _name, _phone;

  TextEditingController nameController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController currentPasswordController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery
        .of(context)
        .size
        .width;
    final screenHeight = MediaQuery
        .of(context)
        .size
        .height;
    var isDark = MediaQuery
        .of(context)
        .platformBrightness == Brightness.dark;

    DateTime now = DateTime.now();
    String formattedDate = DateFormat('d MMMM yyyy').format(now);


    return Scaffold(
        appBar: AppBar(
          leading: IconButton(
            onPressed: () {
              Navigator.of(context).pop();
            },
            icon: Icon(LineAwesomeIcons.angle_left),
          ),
          centerTitle: true,
          title: const Text(
            "تعديل الملف الشخصي",
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          ),
        ),
        body: SingleChildScrollView(
          child: Container(
            padding: EdgeInsets.all(30),
            child: Column(children: [
              Stack(children: [
                SizedBox(
                  width: 120,
                  height: 120,
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(100),
                    child: CircleAvatar(
                      backgroundColor: HexColor("#F5F5F5"),
                      child: Icon(
                        Icons.person,
                        size: screenHeight * 0.15,
                        color: Colors.grey,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 35,
                    height: 35,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(100),
                      color: Colors.white,
                    ),
                    child: const Icon(
                      LineAwesomeIcons.camera,
                      size: 20.0,
                      color: Colors.black,
                    ),
                  ),
                )
              ]),
              const SizedBox(height: 50,),
              Form(
                child: Column(
                  children: [
                    TextFormField(
                      controller: nameController,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.person,
                          color: Colors.blue,
                        ),
                        labelText: "الاسم بالكامل",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontFamily: "Sweety",
                          color: Colors.blue,
                          fontSize: 18.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      onSaved: (value) {
                        _name = value!;
                      },
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      controller: phoneController,
                      onSaved: (value) {
                        _phone = value!;
                      },
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.phone,
                          color: Colors.blue,
                        ),
                        labelText: "رقم التليفون",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontFamily: "Sweety",
                          color: Colors.blue,
                          fontSize: 18.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      controller: currentPasswordController, // Added for current password
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        ),
                        labelText: "كلمة السر الحالية",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontFamily: "Sweety",
                          color: Colors.blue,
                          fontSize: 18.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      obscureText: true,
                    ),
                    SizedBox(height: 15,),
                    TextFormField(
                      controller: passwordController,
                      onSaved: (value) {
                        _password = value!;
                      },
                      obscureText: true,
                      decoration: InputDecoration(
                        prefixIcon: Icon(
                          Icons.lock,
                          color: Colors.blue,
                        ),
                        labelText: "إنشاء كلمة سر جديدة",
                        alignLabelWithHint: true,
                        labelStyle: TextStyle(
                          fontFamily: "Sweety",
                          color: Colors.blue,
                          fontSize: 18.0,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(20.0),
                          borderSide: const BorderSide(
                            color: Colors.white,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(height: 30,),
                    SizedBox(width: double.infinity,
                      child: ElevatedButton(onPressed: () async {
                        updateProfile();
                      },
                        child: Text(
                          "حفظ",
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.blue,
                          side: BorderSide.none,

                          shape: const StadiumBorder(),
                        ),
                      ),
                    ),
                    const SizedBox(height: 30,),


                  ],
                ),
              )

            ]),
          ),
        ));
  }

  Future<void> updateProfile() async {
    String newname = nameController.text;
    String newphone = phoneController.text;
    String newemail = emailController.text;
    String newpassword = passwordController.text;
    String currentPassword = currentPasswordController.text;

    final FirebaseAuth auth = FirebaseAuth.instance;
    final User? user = auth.currentUser;
    final String? userId = user?.uid;

    try {
      // Reauthenticate user with current password
      final AuthCredential credential = EmailAuthProvider.credential(
        email: user!.email!,
        password: currentPassword,
      );
      await user.reauthenticateWithCredential(credential);

      // Reference to the Firestore collection
      CollectionReference users = FirebaseFirestore.instance.collection('users');

      // Update the user data in Firestore
      await users.doc(userId).update({
        'name': newname,
        'phone': newphone,
        // 'email': newemail,
        'password': newpassword,
      });

      updateAuth(newpassword);

      Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => ProfilePage(),
          maintainState: true));
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          // width: 300,
          elevation: 5.0,
          behavior: SnackBarBehavior.floating,
          backgroundColor: Colors.blue,
          shape: const RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
                Radius.circular(20)),
          ),
          content: Text(
              "تم تعديل الملف الشخصي بنجاح"
          ),
        ),
      );
    } catch (e) {
      // Handle errors
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(
        content: Text('Error updating profile: $e'),
      ));
    }
  }

  void updateAuth( String newPassword) async {
    try {
      final User? user = FirebaseAuth.instance.currentUser;

      if (user != null) {

        // Reauthenticate the user
        final AuthCredential credential =
        EmailAuthProvider.credential(email: user.email!, password: newPassword);
        await user.reauthenticateWithCredential(credential);

        // await user.verifyBeforeUpdateEmail(newEmail);
        // print('Email updated successfully!');

        await user.updatePassword(newPassword);
        print('Password updated successfully!');

      } else {
        print('No user is currently signed in.');
      }
    } catch (e) {
      print('Error changing password: $e');
    }

  }

}