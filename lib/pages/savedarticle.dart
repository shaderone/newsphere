import 'dart:developer';

import 'package:flutter/material.dart';
import 'package:newsapplication/models/article_model.dart';
import 'package:newsapplication/pages/home.dart';
import 'package:shared_preferences/shared_preferences.dart';

class SavedNewsPage extends StatefulWidget {
  const SavedNewsPage({super.key});

  @override
  State<SavedNewsPage> createState() => _SavedNewsPageState();
}

class _SavedNewsPageState extends State<SavedNewsPage> {
  List<String> savedArticles = [];

  List<ArticleModel> articles = [];

  @override
  void initState() {
    super.initState();
    loadSavedArticles();
  }

  void loadSavedArticles() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedArticles = prefs.getStringList('savedArticles') ?? [];
    });
  }

  void removeArticle(int index) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      savedArticles.removeAt(index);
      prefs.setStringList('savedArticles', savedArticles);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Saved Articles"),
      ),
      body: savedArticles.isEmpty
          ? Center(child: Text("No saved articles"))
          : ListView.builder(
              itemCount: savedArticles.length,
              itemBuilder: (context, index) {
                String article = savedArticles[index];
                List<String> details = article.split('|'); // title|url
                //log(savedArticles.toString());
                String title = details[0];
                String url = details[1];
                String? image = details[3];
                return BlogTile(
                  title: title,
                  desc: "Saved Article", // You can use the actual description if available
                  imageUrl: image, // If you saved an image URL, you can use it here
                  url: url,
                  removeCallback: () => removeArticle(index), // Adding remove functionality
                );
              },
            ),
    );
  }
}
