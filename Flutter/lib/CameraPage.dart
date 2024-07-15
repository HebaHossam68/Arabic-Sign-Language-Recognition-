import 'dart:io';
import 'package:audioplayers/audioplayers.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_camera/flutter_camera.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:gp/data.dart';
import 'package:gp/TranslatedPage.dart';
import 'package:gp/models/userModel.dart';
import 'package:gp/services/auth.dart';
import 'package:provider/provider.dart';
// import 'package:just_audio/just_audio.dart';

//--------------------------------------------- Flask -----------------------------
import 'dart:io';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'package:http_parser/http_parser.dart';



class CameraPage extends StatefulWidget {
  const CameraPage({Key? key}) : super(key: key);

  @override
  _CameraPageState createState() => _CameraPageState();
}

class _CameraPageState extends State<CameraPage> {
  FirebaseAuth auth = FirebaseAuth.instance;
  final FirebaseAuthServices _auth = FirebaseAuthServices();

  User? user;
  late String videoPath;
  bool _processing = false; // Add this boolean variable


  @override
  Widget build(BuildContext context) {

    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;


    return Scaffold(
      body: Consumer<Data>(
        builder: (context,model,child){
          return FlutterCamera(
            color: Colors.blue,
            onImageCaptured: (value) async{
              final path = value.path;
              print("::::::::::::::::::::::::::::::::: $path");

              await _saveImageToGallery(path);
            },
            onVideoRecorded: (value) async {
              final path = value.path;

              print('::::::::::::::::::::::::;; dkdkkd $path');

              await _saveVideoToGallery(path);
              // setState(() {
              //   const CircularProgressIndicator(); // Set _processing to true when video recording is completed
              // });
              await _sendVideoToFlask(path);

              await saveVideoToStorage(path);

              showModalBottomSheet(
                  context: context,
                  builder: (context) => SizedBox(
                    height: MediaQuery.of(context).size.height * 0.4, // Adjust height as needed
                    child: TranslatedPage(),
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(40), // Adjust the radius as needed
                  ),
                  useRootNavigator: true
              );
            },
          );
        }
      ),

    );
    // return Container();
  }
  Future<void> _saveVideoToGallery(String videoPath) async {
    try {
      await GallerySaver.saveVideo(videoPath);
      print('Video saved to gallery successfully');
    } catch (e) {
      print('Failed to save video: $e');
    }
  }

  Future<void> _saveImageToGallery(String imagePath) async {
    try {
      await GallerySaver.saveImage(imagePath);
      print('Image saved to gallery successfully');
    } catch (e) {
      print('Failed to save Image: $e');
    }
  }

  Future<void> saveVideoToStorage(String videoPath)
  async {
    // Upload video to Firebase Storage
    File videoFile = File(videoPath);
    String fileName = DateTime.now().millisecondsSinceEpoch.toString();
    Reference storageReference = FirebaseStorage.instance.ref().child('videos')
        .child(auth.currentUser!.uid).child("$fileName.mp4");
    UploadTask uploadTask = storageReference.putFile(videoFile);
    print("video uploading...");

    TaskSnapshot snapshot = await uploadTask;
    String downloadUrl = await snapshot.ref.getDownloadURL();
    print('Video uploaded to Firebase Storage: $downloadUrl');
    saveVideoInFireStore(downloadUrl);
  }

  Future<void> _sendVideoToFlask(String videoPath) async {
    try {

      final url = Uri.parse('http://192.168.1.9:5000/predict');
      print("1");

      var request = http.MultipartRequest('POST', url);
      request.headers['Content-Type'] = 'multipart/form-data';
      request.files.add(
        await http.MultipartFile.fromPath(
          'video',
          videoPath,
          contentType: MediaType('video', 'mp4'), // Adjust the content type if needed
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

  saveVideoInFireStore(String downloadUrl)
  async {
    if(user != null)
      {
        await _auth.storeUserData(user!.uid, {
        'video': downloadUrl,
        });
      }
  }


}