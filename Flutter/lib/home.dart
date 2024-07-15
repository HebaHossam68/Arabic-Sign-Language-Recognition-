// import 'dart:html';
import 'dart:io';
import 'dart:ui';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/widgets.dart';
import 'package:gallery_picker/gallery_picker.dart';
import 'package:gallery_saver/files.dart';
import 'package:gp/profilePage.dart';
import 'package:gp/services/auth.dart';
import 'package:gp/uploadVideo.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'CameraPage.dart';
import 'customWidget.dart';
import 'data.dart';

//---------------------
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart' as http_parser;



class home extends StatefulWidget {
  const home({Key? key}) : super(key: key);

  @override
  State<home> createState() => _homeState();
}

class _homeState extends State<home> {

  File? selectedVideo;

  User? user;
  final FirebaseAuthServices _userDataServices = FirebaseAuthServices();
  Map<String, dynamic>? _userData;

  Future<void> _loadUserData() async {
    _userData = await _userDataServices.getUserData(user!.uid);
    setState(() {}); // Update the UI after loading user data
  }

  // Future<Map<String, dynamic>?> getUserData() async {
  //   DocumentSnapshot snapshot = await _firestore.collection('users').doc(uid).get();
  //   return snapshot.data() as Map<String, dynamic>?; // Return null if user not found
  // }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final buttonWidth = screenWidth * 0.9;
    final buttonHeight = screenHeight*0.1;

    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back, color: Colors.white,),
          onPressed: () {
            Navigator.pop(context);
          },
        ),
                  centerTitle: true,
          backgroundColor: Colors.blue,
          title: const Text(
            "وَصْل",
            style: TextStyle(
              fontSize: 30,
              color: Colors.white,
            ),
          ),
          actions: [
            Padding(
              padding: EdgeInsets.only(right: 8.0),
              child: IconButton(onPressed: () {
                setState(() {
                  Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => ProfilePage(),
                      maintainState: true));
                });
              },
                  icon: CircleAvatar(
                    backgroundColor: Colors.white,
                    radius: 18,
                    child: Icon(
                      Icons.person, size: 33, opticalSize: 20, color: Colors.blue,),
                  )),
            )
          ],
          ),
      body: StreamBuilder<User?>(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          final user = snapshot.data;
          if (user == null) {
            // User is not signed in
            return const Center(child: Text('User is not signed in'));
          }

          // User is signed in, load user data
          return FutureBuilder<Map<String, dynamic>?>(
            future: _userDataServices.getUserData(user.uid),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(child: Text('Error: ${snapshot.error}'));
              }

              _userData = snapshot.data;

              if (_userData == null) {
                // Handle case where user data is not available
                return const Center(child: Text('User data not found'));
              }

              // Display user data
              return Stack(
                children: [
                  CustomPaint(
                    size: Size(double.infinity, double.infinity),
                    painter: CustomWidget(),
                  ),
                  SingleChildScrollView(
                    child: Center(
                      child: Column(
                        children: [
                          SizedBox(
                            height: screenHeight * 0.05,
                          ),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          height: screenHeight * 0.2,
                                          child: Image.asset('assets/images/home.png')
                                      ),
                                      SizedBox(width: screenWidth*0.01),
                                      Flexible(
                                        child: Container(
                                          child: Text(
                                            'يمكنك الان تسجيل فيديو والحصول على ترجمة له',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: screenHeight*0.01),
                                  TextButton(
                                    onPressed: () {
                                      Navigator.of(context).push(
                                          MaterialPageRoute(builder: (context) => CameraPage()));
                                    },
                                    child: Text(
                                      'تسجيل الان',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        // decoration: TextDecoration.underline,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(height: screenHeight*0.04,),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 16.0),
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(20),
                              ),
                              padding: EdgeInsets.all(16),
                              child: Column(
                                children: [
                                  Row(
                                    children: [
                                      Container(
                                          height: screenHeight * 0.2,
                                          child: Image.asset('assets/images/Vector.png')
                                      ),
                                      SizedBox(width: screenWidth*0.01),
                                      Flexible(
                                        child: Container(
                                          child: Text(
                                            'ترجمة فيديو من الهاتف',
                                            textAlign: TextAlign.center,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: Colors.blue,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),

                                  SizedBox(height: screenHeight*0.01),
                                  TextButton(
                                    onPressed: () {
                                      _pickVideo();
                                    },
                                    child: Text(
                                      'تحميل الان',
                                      textAlign: TextAlign.right,
                                      style: TextStyle(
                                        // decoration: TextDecoration.underline,
                                        fontSize: 25,
                                        fontWeight: FontWeight.bold,
                                        color: Colors.blue,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                ],
              );
            },
          );
        },
      ),
    );
  }


  Future _pickVideo() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickVideo(source: ImageSource.gallery);

    if (pickedFile == null) {
      return;
    } else {
      setState(() {
        selectedVideo = File(pickedFile.path);
        sendVideoToFlask(pickedFile.path);
        Navigator.of(context).push(
          MaterialPageRoute(
            builder: (context) => UploadVideo(videoPath: pickedFile.path),
          ),
        );

      });
    }
  }

  //------------------------Flask---------------------------------------

  Future<void> sendVideoToFlask(String videoPath) async {
    try {
      final url = Uri.parse('http://192.168.1.9:5000/predict');
      print("6");
      var request = http.MultipartRequest('POST', url);
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoPath,
          contentType: http_parser.MediaType('video', 'mp4'), // Adjust the content type if needed
        ),
      );

      var response = await request.send();
      var responseData = await response.stream.bytesToString();
      if (response.statusCode == 200) {
        var data = jsonDecode(responseData);
        print('Prediction: ${data['predicted_class_label']}');
        var dataProvider = Provider.of<Data>(context, listen: false);
        dataProvider.set_value(data['predicted_class_label'],data['label']);
      } else {
        print('Failed to predict: ${response.reasonPhrase}');
      }
    } catch (e) {
      print('Error: $e');
    }
  }



}
