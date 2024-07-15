import 'dart:io';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

import 'TranslatedPage.dart';

class UploadVideo extends StatefulWidget {
  final String videoPath;

  const UploadVideo({Key? key, required this.videoPath}) : super(key: key);

  @override
  _UploadVideoState createState() => _UploadVideoState();
}

class _UploadVideoState extends State<UploadVideo> {
  late VideoPlayerController _controller;

  bool _isInitialized = false;

  @override
  void initState() {
    super.initState();
    _controller = VideoPlayerController.file(File(widget.videoPath))
      ..initialize().then((_) {
        setState(() {
          _isInitialized = true;
        });
        _controller.pause(); // Ensure the video is not playing
      });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    return Scaffold(
      appBar: AppBar(
        title: Text("Upload Video"),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            Center(
              child: _isInitialized
                  ? Container(
                    padding: EdgeInsets.all(25),
                    child: AspectRatio(
                              aspectRatio: _controller.value.aspectRatio,
                              child: VideoPlayer(_controller),
                            ),
                  )
                  : CircularProgressIndicator(),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 20.0),
              child: SizedBox(
                height: screenHeight * 0.05,
                width: double.infinity, // Makes the button fill the width of its parent
                child: ElevatedButton(
                  onPressed: () {
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
                  child: Text(
                    "ترجمة الفيديو",
                    style: TextStyle(fontSize: 20, color: Colors.white), // Adjust text color if needed
                  ),
                  style: ButtonStyle(
                    backgroundColor: MaterialStateProperty.all<Color>(Colors.blue), // Change 'Colors.blue' to the color you want),
                ),
              )


                      ,
            ),
            )
            ],
        ),
      ),
    );
  }
}
