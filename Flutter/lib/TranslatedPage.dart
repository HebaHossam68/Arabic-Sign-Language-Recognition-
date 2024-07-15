// ignore_for_file: prefer_const_constructors

import 'dart:ffi';
import 'package:audioplayers/audioplayers.dart';
import 'package:clipboard/clipboard.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/painting.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/widgets.dart';
import 'package:gp/FirstPage.dart';
import 'package:provider/provider.dart';
import 'package:get/get.dart';

import 'data.dart';

class TranslatedPage extends StatefulWidget {
  const TranslatedPage({Key? key}) : super(key: key);

  @override
  State<TranslatedPage> createState() => _TranslatedPageState();
}

class _TranslatedPageState extends State<TranslatedPage> {
  @override
  Widget build(BuildContext context) {
    String text = "Mohamed Ali";

    final screenWidth = MediaQuery.of(context).size.width;
    final screenHeight = MediaQuery.of(context).size.height;

    return Consumer<Data>(
        builder: (context, model, child) {
          return Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Expanded(
                flex: 1,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.only(
                      topLeft: Radius.circular(40),
                      topRight: Radius.circular(40),
                    ),
                    color: Colors.grey[400],
                  ),
                ),
              ),
              Expanded(
                flex: 8,
                child: Container(
                  width: double.infinity,
                  decoration: BoxDecoration(
                    color: Colors.cyan,
                    boxShadow: [BoxShadow(color: Colors.black, spreadRadius: 1)],
                  ),
                  child: Card(
                    color: Colors.white,
                    margin: EdgeInsets.all(20),
                    child: Column(crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        InkWell(
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              IconButton(
                                onPressed: () async
                                {
                                  AudioPlayer player = AudioPlayer();
                                  await player.play(AssetSource('sounds/${model.num_class}.mp3'));

                                  // AudioCache player = AudioCache();
                                  // player.play(AssetSource('sounds/first.mp3'));
                                },
                                icon: Icon(Icons.volume_down_alt , color: Colors.lightBlue),
                              ),
                              SizedBox(width: screenWidth*0.02,),
                              Text(
                                "الترجمه",
                                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold , color: Colors.lightBlue[300]),
                              ),
                              SizedBox(width: 10,)
                            ],
                          ),
                          onTap: () {
                            print("mo");
                          },
                        ),
                        Container(
                          alignment: Alignment.center,
                          child: Padding(
                            padding: EdgeInsets.only(top: 30),
                            child: Text(model.predict,style: TextStyle(fontSize: 30,fontWeight: FontWeight.bold ),),
                          ),
                        ),
                        SizedBox(height: screenHeight * 0.1,),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            IconButton(onPressed: (){}, icon: Icon(Icons.star ,  color: Colors.lightBlue[300] ,)),
                            IconButton(onPressed: (){}, icon: Icon(Icons.share ,  color: Colors.lightBlue[300])),
                            IconButton(onPressed: (){
                              setState(() {
                                FlutterClipboard.copy(model.predict).then((value) => ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Text copied to clipboard'),
                                  backgroundColor: Colors.lightBlue[200],
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(15), // Adjust the radius as needed
                                  ),
                                  behavior: SnackBarBehavior.floating,
                                  showCloseIcon: true,
                                )));
                              });
                            }, icon: Icon(Icons.copy ,  color: Colors.lightBlue[300])),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          );
        }
    );

  }
}