import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../models/slider_model.dart';
import 'home.dart';

class HistoryPage extends StatefulWidget {
  const HistoryPage({super.key});

  @override
  State<HistoryPage> createState() => _HistoryPageState();
}

class _HistoryPageState extends State<HistoryPage> {
  List<String> userHistory = [];

  @override
  void initState() {
    super.initState();
    loadSavedArticles();
  }

  void loadSavedArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      userHistory = prefs.getStringList('userHistory') ?? [];
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("History"),
        actions: [
          IconButton(
            onPressed: _clearHistory,
            icon: Icon(Icons.cleaning_services_rounded),
          ),
        ],
      ),
      body: userHistory.isEmpty
          ? Center(child: Text("History is empty"))
          : ListView.builder(
              itemCount: userHistory.length,
              itemBuilder: (context, index) {
                String article = userHistory[index];
                List<String> details = article.split('|'); // title|url
                //log(savedArticles.toString());
                String title = details[0];
                String url = details[2];
                String imageUrl = details[details.length - 1];
                return BlogTile(
                  title: title,
                  desc: "", // You can use the actual description if available
                  imageUrl: imageUrl, // If you saved an image URL, you can use it here;
                  url: url,
                );
              },
            ),
    );
  }

  Future<void> _clearHistory() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();

    prefs.remove("userHistory");

    setState(() {
      userHistory = [];
    });
  }
}
