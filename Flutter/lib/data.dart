import 'package:flutter/material.dart';


class Data extends ChangeNotifier {
  late String Video;
  late String num_class;
  String get predict => Video;
  String get label => num_class;
  set_value(var val, var val2){
    Video = val;
    num_class = val2;
    notifyListeners();
  }

}