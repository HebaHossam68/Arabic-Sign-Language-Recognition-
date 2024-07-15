import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:gp/services/auth.dart';
import 'package:gp/signup.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'customWidget.dart';
import 'home.dart';


class Login extends StatefulWidget {
  // const Login({Key? key}) : super(key: key);

  @override
  State<Login> createState() => _LoginState();
}

class _LoginState extends State<Login> {

  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();

  bool value = false;
  final GlobalKey<FormState> _globalKey = GlobalKey<FormState>();
  String email = '', password = '';

  final FirebaseAuthServices _auth = FirebaseAuthServices();



  Future<void> _login() async {
    String email = _emailController.text;
    String password = _passwordController.text;


      User? user = await _auth.signInWithEmailAndPassword(email, password);

      if (user != null) {
        print("User is successfully SignedIn");
        Navigator.of(context).push(
            MaterialPageRoute(builder: (context) => const home()));
      }
      else
      {
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
              "Invalid Email or Password"
            ),
          ),
        );
      }


  }


  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

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
                padding: const EdgeInsets.all(20.0),
                child: Column(
                  children: [
                    SizedBox(
                      height: screenHeight * 0.1,
                    ),
                    Center(
                        child: Text(
                          'تسجيل الدخول',
                          style: TextStyle(
                              fontSize: screenHeight*0.04,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                              fontFamily: "Sweety"
                          ),
                        )
                    ),
                    SizedBox(
                      height: screenHeight*0.05,
                    ),
                Container(
                  height: screenHeight*0.5,
                  padding: EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(15),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black12,
                        blurRadius: 10,
                        offset: Offset(0, 5),
                      ),
                    ],
                  ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        TextFormField(
                          // textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.email,
                              color: Colors.blue,
                            ),
                            hintText: 'ادخل البريد الالكتروني',
                            hintTextDirection: TextDirection.rtl,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.white,
                              ),
                            ),
                            labelText: "البريد الالكتروني",
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                              fontFamily: "Amperzand",
                              color: Colors.blue,

                            ),
                          ),
                          keyboardType: TextInputType.emailAddress,
                          onSaved: (value)
                          {
                            email = value!;
                          },
                          controller: _emailController,
                        ),
                        SizedBox(
                          height: screenHeight*0.04,
                        ),
                        TextFormField(
                          // textDirection: TextDirection.rtl,
                          decoration: InputDecoration(
                            prefixIcon: Icon(
                              Icons.lock,
                              color: Colors.blue,
                            ),
                            hintText: 'ادخل كلمة السر',
                            hintTextDirection: TextDirection.rtl,
                            labelText: "كلمة السر",
                            alignLabelWithHint: true,
                            labelStyle: TextStyle(
                              fontFamily: "Amperzand",
                              color: Colors.blue,
                            ),
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10.0),
                              borderSide: const BorderSide(
                                color: Colors.white,
                              ),
                            ),
                          ),
                          obscureText: true,
                          onSaved: (value)
                          {
                            password = value!;
                          },
                          controller: _passwordController,
                        ),
                        SizedBox(
                          height: screenHeight*0.04,
                        ),
                        SizedBox(
                          width: screenWidth * 0.6,
                          height: screenHeight * 0.06,
                          child: Builder(
                              builder: (context) {
                                return ElevatedButton(
                                  onPressed: () async
                                  {
                                    _login();
                                  },
                                  style: ButtonStyle(
                                      backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
                                      shape:
                                      MaterialStateProperty.all<RoundedRectangleBorder>(
                                          RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(24.0),
                                              side: const BorderSide(color: Colors.white)))),
                                  child: Text(
                                    'تسجيل دخول',
                                    style: TextStyle(
                                      fontSize: screenHeight*0.03,
                                      color: Colors.white,
                                    ),
                                  ),
                                );
                              }
                          ),
                        ),
                        SizedBox(
                          height: screenHeight*0.03,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            TextButton(
                              onPressed: () {
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) => const SignUp()));
                              },
                              child: Text(
                                ' إنشاء حساب جديد',
                                style: TextStyle(
                                  fontSize: screenHeight * 0.017,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.blue,
                                ),
                              ),
                            ),
                            Text(
                              'هل ليس لديك حساب؟',
                              style: TextStyle(
                                fontSize: screenHeight * 0.017,
                              ),
                              textAlign: TextAlign.right,
                              textDirection: TextDirection.rtl, // Align text from right to left
                            ),

                          ],
                        ),
                      ],
                    ),

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
