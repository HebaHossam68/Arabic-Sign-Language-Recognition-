import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:gp/CameraPage.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:camera/camera.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login.dart';

List<CameraDescription> cameras = [];

class FirstPage extends StatefulWidget {
  const FirstPage({Key? key}) : super(key: key);

  @override
  State<FirstPage> createState() => _FirstPageState();
}

class _FirstPageState extends State<FirstPage> {
  // late CameraController controller;
  @override
  Widget build(BuildContext context) {
    // if (!controller.value.isInitialized) {
    //   return Container();
    // }
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;

    PageController controller = PageController();

    return Scaffold(
      body: Stack(
        children: [
          PageView(
            controller: controller,
            children: [
              Container(
                color: Colors.white,
                height: screenHeight,
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight*0.2,),
                      Text(
                        'وَصْل',
                        style: TextStyle(
                          fontSize: screenHeight *0.05,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      SizedBox(height: screenHeight*0.03,),
                      Text(
                        'تحويل لغة الإشارة',
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                          fontWeight: FontWeight.bold,
                          color: Colors.black,
                        ),
                      ),
                      SizedBox(height: screenHeight*0.1,),
                      CircleAvatar(
                        radius: screenWidth * 0.25,
                        backgroundColor: Colors.blue,
                        child: CircleAvatar(
                          backgroundImage: const AssetImage('assets/images/sign.jpeg'),
                          radius: screenWidth * 0.245,
                        ),
                      ),
                      SizedBox(height: screenHeight*0.08,),
                    ],
                  ),
                ),
              ),
              Container(
                color: Colors.white,
                child: Center(
                  child: Column(
                    children: [
                      SizedBox(height: screenHeight*0.12,),
                      SizedBox(
                          width: screenWidth*0.9,
                          child: Image.asset('assets/images/deaf.jpg')
                      ),
                      SizedBox(height: screenHeight*0.03,),
                      Text(
                        'أهلا بك في تطبيق وَصْل \nاستمتع بتجربة مميزة ورائعة  ',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: screenHeight * 0.03,
                        ),
                      ),
                      SizedBox(height: screenHeight*0.03,),
                      SizedBox(
                        width: screenWidth * 0.5,
                        child: ElevatedButton(
                          onPressed: ()async {
                            Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  Login()));
                            // if (!controller.value.isRecordingVideo) {
                            //   await startRecordingVideo();
                            // } else {
                            //   await stopRecordingVideo();
                            // }
                          },
                          style: ButtonStyle(
                            backgroundColor: MaterialStatePropertyAll<Color>(Colors.blue),
                            shape: MaterialStateProperty.all<RoundedRectangleBorder>(
                              RoundedRectangleBorder(
                                borderRadius:BorderRadius.circular(15),
                                // side: BorderSide(color: Colors.black),
                              ),
                            ),
                          ),
                          child: Text(
                            'ابدأ الآن',
                            style: TextStyle(
                              fontSize: screenHeight *0.03,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

              ),
            ],
          ),
          Container(
            alignment: const Alignment(0,0.85),
            child: SmoothPageIndicator(
                controller: controller,
                count: 2
            ),
          ),
        ],
      ),
    );
  }


}
