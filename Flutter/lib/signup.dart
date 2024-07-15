import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:gp/services/auth.dart';
import 'package:hexcolor/hexcolor.dart';
import 'customWidget.dart';
import 'home.dart';
import 'login.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class SignUp extends StatefulWidget {
  const SignUp({super.key});

  @override
  State<SignUp> createState() => _SignUpState();
}

class _SignUpState extends State<SignUp> {
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  String? _email, _password, _confirmPass, _name, _phone;

  final FirebaseAuthServices _auth = FirebaseAuthServices();

  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _confirmPpasswordController = TextEditingController();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  void _signUp() async {
    String name = _nameController.text;
    String email = _emailController.text;
    String phone = _phoneController.text;
    String password = _passwordController.text;

    User? user = await _auth.signUpWithEmailAndPassword(email, password);

    if(user != null){
      print("User is successfully created");

      await _auth.storeUserData(user.uid, {
        'name': name,
        'email': email,
        'phone' : phone,
        'password': password,
        'video': '',
      });

      Navigator.of(context).push(
          MaterialPageRoute(builder: (context) => Login()));
    }
    else{
      print("error");
    }

  }



  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _passwordController.dispose();
    _confirmPpasswordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Scaffold(
      body: Form(
        key: _globalKey,
        child: Stack(
          children: [
            CustomPaint(
              size: Size(double.infinity, double.infinity),
              painter: CustomWidget(),
            ),
            SafeArea(
              child: SingleChildScrollView(
                child: Padding(
                  padding: EdgeInsets.all(20.0),
                  child: Column(
                    children: [
                      SizedBox(
                        height: screenHeight *0.03,
                      ),
                      Text(
                        'حساب جديد',
                        style: TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      SizedBox(
                        height: screenHeight *0.03,
                      ),

                        Container(
                          padding: EdgeInsets.all(16),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(
                                color: Colors.black12,
                                blurRadius: 10,
                                offset: Offset(0, 5),
                              ),
                            ],
                          ),
                          child: Column(
                            children: [
                              TextFormField(
                                keyboardType: TextInputType.name,
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
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                onSaved: (value) {
                                  _name = value!;
                                },
                                controller: _nameController,
                              ),
                              SizedBox(
                                height: screenHeight*0.025,
                              ),
                              TextFormField(
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
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                keyboardType: TextInputType.phone,
                                onSaved: (value) {
                                  _phone = value!;
                                }, controller: _phoneController,
                              ),
                              SizedBox(
                                height: screenHeight*0.025,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.email,
                                    color: Colors.blue,
                                  ),

                                  labelText: "البريد الالكتروني",
                                  alignLabelWithHint: true,
                                  labelStyle: TextStyle(
                                    fontFamily: "Sweety",
                                    color: Colors.blue,
                                    fontSize: 18.0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide: const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),

                                keyboardType: TextInputType.emailAddress,
                                onSaved: (value) {
                                  _email = value!;
                                }, controller: _emailController,
                              ),
                              SizedBox(
                                height: screenHeight*0.025,
                              ),
                              TextFormField(
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
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                obscureText: true,
                                onSaved: (value) {
                                  _password = value!;
                                },
                                controller: _passwordController,
                              ),
                              SizedBox(
                                height: screenHeight*0.025,
                              ),
                              TextFormField(
                                decoration: InputDecoration(
                                  prefixIcon: Icon(
                                    Icons.lock,
                                    color: Colors.blue,
                                  ),
                                  labelText: "تأكيد كلمة السر",
                                  alignLabelWithHint: true,
                                  labelStyle: TextStyle(
                                    fontFamily: "Sweety",
                                    color: Colors.blue,
                                    fontSize: 18.0,
                                  ),
                                  border: OutlineInputBorder(
                                    borderRadius: BorderRadius.circular(10.0),
                                    borderSide:const BorderSide(
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                                obscureText: true,
                                onSaved: (value) {
                                  _confirmPass = value!;
                                }, controller: _confirmPpasswordController,
                              ),
                              SizedBox(
                                height: screenHeight*0.025,
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => Login()));
                                    },
                                    child: Text(
                                      'سجل الدخول',
                                      style: TextStyle(
                                        fontSize: 15,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                  Text(
                                    'هل لديك حساب بالفعل؟',
                                    style: TextStyle(fontSize: 15),
                                  ),
                                ],
                              ),
                            ],
                          ),
                      ),
                      SizedBox(
                        height: screenHeight*0.03,
                      ),

                      SizedBox(
                        width: screenWidth * 0.7,
                        height: screenHeight * 0.06,
                        child: Builder(builder: (context) {
                          return ElevatedButton(
                            onPressed: (){
                              _signUp();
                            },
                            style: ButtonStyle(
                                backgroundColor:
                                MaterialStatePropertyAll<Color>(Colors.blue),
                                shape: MaterialStateProperty.all<
                                    RoundedRectangleBorder>(
                                    RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(24.0),
                                        side: const BorderSide(color: Colors.white)))),
                            child: const Text(
                              'حساب جديد',
                              style: TextStyle(
                                fontSize: 23,
                                color: Colors.white,
                              ),
                            ),
                          );
                        }),
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],

        ),
      ),
    );
  }


}
