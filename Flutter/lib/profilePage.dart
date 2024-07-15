import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/login.dart';
import 'package:gp/services/auth.dart';
import 'package:gp/updatedProfile.dart';
import 'package:hexcolor/hexcolor.dart';
import 'package:line_awesome_flutter/line_awesome_flutter.dart';

import 'customWidget.dart';

class ProfilePage extends StatefulWidget {
  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  User? user;

  final FirebaseAuthServices _userDataServices = FirebaseAuthServices();

  Map<String, dynamic>? _userData;

  Future<void> _loadUserData() async {
    _userData = await _userDataServices.getUserData(user!.uid);
    setState(() {}); // Update the UI after loading user data
  }

  @override
  void initState() {
    super.initState();
    if (user != null) {
      _loadUserData();
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;
    var isDark = MediaQuery.of(context).platformBrightness == Brightness.dark;
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white,),
          onPressed: () {
            Navigator.of(context).pop();
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
          IconButton(onPressed: (){}, icon:Icon(isDark ? LineAwesomeIcons.sun : LineAwesomeIcons.moon))
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
                return Stack(children: [
                  CustomPaint(
                    size: Size(double.infinity, double.infinity),
                    painter: CustomWidget(),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.vertical,
                      child: Column(
                        // crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SizedBox(
                            height: screenHeight * 0.03,
                          ),
                          Text(
                            'الملف الشخصي',
                            style: TextStyle(
                              fontSize: 40,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: screenHeight * 0.04,
                          ),
                          Container(
                            padding: EdgeInsets.all(16),
                            child: Column(children: [
                              Stack(
                                children: [
                                  SizedBox(width: 120,height: 120,
                                    child:ClipRRect(borderRadius: BorderRadius.circular(100),
                                      child: CircleAvatar(
                                        backgroundColor: HexColor("#F5F5F5"),
                                        child: Icon(
                                          Icons.person,
                                          size: screenHeight * 0.15,
                                          color: Colors.grey,
                                        ),
                                      ),
                                    )
                                    ,),
                                  Positioned(
                                    bottom: 0,
                                    right: 0,

                                    child: Container(
                                      width: 35, height: 35,
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(100),
                                        color: Colors.white,



                                      ),
                                      child: const Icon(LineAwesomeIcons.alternate_pencil, size: 20.0,color: Colors.black,),
                                    ),
                                  )
                                ],
                              ),
                              SizedBox(height: 10,),
                              Text(
                                _userData!['name'],
                                style: TextStyle(
                                    color: Colors.black54,
                                    fontSize: screenWidth * 0.06,
                                    fontFamily: "Sweety",
                                    fontWeight: FontWeight.bold
                                ),),
                              Text(
                                _userData!['email'],
                                style: TextStyle(
                                  color: Colors.black54,
                                  fontSize: screenWidth * 0.04,
                                  fontFamily: "Sweety",
                                ),
                              ),
                              SizedBox(height: 20,),
                              SizedBox(width: 200,child: ElevatedButton(onPressed: (){
                                Navigator.of(context).push(MaterialPageRoute(builder: (context) =>  UpdatedProfile()));
                              }, child: Text("تعديل الملف الشخصي") ,
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.white ,
                                  side: BorderSide.none,
                                  shape: const StadiumBorder(),
                                ),
                              ),
                              ),
                              SizedBox(height: 30,),
                              const Divider(),
                              const SizedBox(height: 10,),

                              //Menu
                              ProfileMenuWidget(title:"الإعدادات" , icon: LineAwesomeIcons.cog,onpress: (){},),
                              // ProfileMenuWidget(title:"إدارة المستخدم" , icon: LineAwesomeIcons.user_check,onpress: (){},),
                              const Divider(),
                              ProfileMenuWidget(title:"معلومات عن التطبيق" , icon: LineAwesomeIcons.info,onpress: (){},),
                              ProfileMenuWidget(title:"تسجيل الخروج" , icon: LineAwesomeIcons.alternate_sign_out,onpress: (){
                                Navigator.of(context).push(MaterialPageRoute(
                                    builder: (context) => Login()));
                              },textColor: Colors.red,endIcon: false,),

                            ],),
                          ),
                        ],
                      ),
                    ),
                  )
                ]);
              });
        },
      ),
    );
  }
}

class ProfileMenuWidget extends StatelessWidget {
  ProfileMenuWidget({
    Key? Key,
    required this.title,
    required this.icon,
    required this.onpress,
    this.endIcon = true,
    this.textColor,
  }):super(key: Key);



  late String title;
  late IconData icon;
  late VoidCallback onpress;
  late bool endIcon;
  late Color? textColor;



  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: onpress,
      leading: Container(
        width: 40, height: 40,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.lightBlue[100],

        ),
        child: Icon(icon,color: Colors.blue,),
      ),
      title: Text(title,style: TextStyle(
        color: textColor,
        fontSize: 18,
        fontFamily: "Sweety",
      ),),
      trailing:endIcon? Container(
        width: 30, height: 30,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(100),
          color: Colors.grey.withOpacity(0.1),


        ),
        child: const Icon(LineAwesomeIcons.angle_right, size: 18.0,color: Colors.grey,),
      ):null,
    );
  }
}