import 'dart:convert';
import 'dart:developer';

import 'package:http/http.dart' as http;
import 'package:newsapplication/models/slider_model.dart';

class Sliders {
  List<SliderModel> sliders = [];

  Future<void> getSlider() async {
    //String url = "https://newsapi.org/v2/everything?domains=wsj.com&apiKey=8eb940539c874fa98a2050d4afde5d5b";
    String url = "https://newsapi.org/v2/top-headlines?country=us&apiKey=486c46d89d8e41609e095929c2078213";
    var response = await http.get(Uri.parse(url));

    // Decode JSON response
    var jsonData = jsonDecode(response.body);

    // Pretty-print the JSON data
    //var prettyJson = JsonEncoder.withIndent('  ').convert(jsonData);
    //log(prettyJson); // Use log to print the formatted JSON

    if (jsonData['status'] == 'ok') {
      jsonData["articles"].forEach((element) {
        if (element["urlToImage"] != null && element['description'] != null) {
          SliderModel slidermodel = SliderModel(
            title: element["title"],
            description: element["description"],
            url: element["url"],
            urlToImage: element["urlToImage"],
            content: element["content"],
            author: element["author"],
          );
          sliders.add(slidermodel);
        }
      });
    }
  }
}


//import 'dart:convert';
//import 'dart:developer';
//
//import 'package:http/http.dart' as http;
//import 'package:newsapplication/models/slider_model.dart';
//
//class Sliders {
//  List<SliderModel> sliders = [];
//
//  Future<void> getSlider() async {
//    String url = "https://newsapi.org/v2/everything?domains=wsj.com&apiKey=8eb940539c874fa98a2050d4afde5d5b";
//    var response = await http.get(Uri.parse(url));
//
//    var jsonData = jsonDecode(response.body);
//
//    log(jsonData.toString());
//
//    if (jsonData['status'] == 'ok') {
//      jsonData["articles"].forEach((element) {
//        if (element["urlToImage"] != null && element['description'] != null) {
//          SliderModel slidermodel = SliderModel(
//            title: element["title"],
//            description: element["description"],
//            url: element["url"],
//            urlToImage: element["urlToImage"],
//            content: element["content"],
//            author: element["author"],
//          );
//          sliders.add(slidermodel);
//        }
//      });
//    }
//  }
//}
