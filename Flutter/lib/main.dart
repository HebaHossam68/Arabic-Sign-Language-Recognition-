import 'dart:io';
import 'package:gp/login.dart';
import 'package:gp/signup.dart';

import 'home.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:gp/data.dart';
import 'FirstPage.dart';
import 'package:provider/provider.dart';

Future<void> main() async{
  WidgetsFlutterBinding.ensureInitialized();

  Platform.isAndroid
  ? await Firebase.initializeApp(
    options: const FirebaseOptions(
        apiKey: "AIzaSyDwVuxnNygO6sSQ2V28ho26e9TO7wH0YyE",
        appId: "1:1006202784495:android:6f3003c8f4b0e8425e691a",
        messagingSenderId: "1006202784495",
        projectId: "graduationproject-ee8cd",
      storageBucket: "graduationproject-ee8cd.appspot.com"
    )
  )
  :await Firebase.initializeApp();

  // cameras = await availableCameras();
  runApp(
      MultiProvider(
        providers: [
         ChangeNotifierProvider(create: (context) => Data())
      ],
        child: MyApp()));
}

class MyApp extends StatefulWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: FirstPage(),
    );
  }
}
