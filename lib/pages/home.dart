import 'dart:developer';

import 'package:cached_network_image/cached_network_image.dart';
import 'package:carousel_slider/carousel_slider.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:newsapplication/models/article_model.dart';
import 'package:newsapplication/models/category_model.dart';
import 'package:newsapplication/models/slider_model.dart';
import 'package:newsapplication/pages/all_news.dart';
import 'package:newsapplication/pages/article_view.dart';
import 'package:newsapplication/pages/category_news.dart';
import 'package:newsapplication/pages/history.dart';
import 'package:newsapplication/pages/savedarticle.dart';

import 'package:newsapplication/services/data.dart';
import 'package:newsapplication/services/news.dart';
import 'package:newsapplication/services/slider_data.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:smooth_page_indicator/smooth_page_indicator.dart';

import 'login.dart';

class Home extends StatefulWidget {
  const Home({super.key});

  @override
  State<Home> createState() => _HomeState();
}

class _HomeState extends State<Home> {
  List<CategoryModel> categories = [];
  List<SliderModel> sliders = [];
  List<ArticleModel> articles = [];
  bool _loading = true, loading2 = true;

  final _auth = FirebaseAuth.instance;

  int activeIndex = 0;
  @override
  void initState() {
    categories = getCategories();
    getSlider();
    getNews();
    super.initState();
  }

  getNews({String? reqUrl}) async {
    News newsclass = News();
    await newsclass.getNews(reqUrl: reqUrl);
    setState(() {
      articles = newsclass.news;
    });
    log(articles.length.toString());
    setState(() {
      _loading = false;
    });
  }

  Future<void> getSlider() async {
    Sliders slider = Sliders();
    await slider.getSlider();
    sliders = slider.sliders;

    // ! only two slidermodels are returned as response. out of which only one is actaully stored because of a certain ccondition check.
    //log('Number of sliders: ${sliders.length}');

    setState(() {
      loading2 = false;
    });
  }

  // Logout handler
  void _handleLogout() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.clear();
    await _auth.signOut();
    // Check if the widget is still mounted before using context
    if (mounted) {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (context) => Login(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Text("Flutter "),
            Text(
              "News",
              style: TextStyle(color: Colors.blue, fontWeight: FontWeight.bold),
            )
          ],
        ),
        automaticallyImplyLeading: false,
        elevation: 0.0,
        actions: [
          IconButton(
            icon: Icon(Icons.history),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HistoryPage(),
                ),
              );
            },
          ),
          IconButton(
            icon: Icon(Icons.bookmark_outline_outlined),
            onPressed: () {
              Navigator.push(context, MaterialPageRoute(builder: (context) => SavedNewsPage()));
            },
          ),
          IconButton(
            onPressed: _handleLogout,
            icon: Icon(Icons.logout),
          ),
        ],
      ),
      body: _loading
          ? Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    margin: EdgeInsets.only(left: 10.0),
                    height: 70,
                    child: ListView.builder(
                        shrinkWrap: true,
                        scrollDirection: Axis.horizontal,
                        itemCount: categories.length,
                        itemBuilder: (context, index) {
                          return CategoryTile(
                            image: categories[index].image,
                            categoryName: categories[index].categoryName,
                          );
                        }),
                  ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Breaking News!",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => AllNews(news: "Breaking"),
                              ),
                            );
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.blue, color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: 20.0,
                  ),
                  loading2
                      ? Center(child: CircularProgressIndicator())
                      : CarouselSlider.builder(
                          itemCount: sliders.length,
                          itemBuilder: (context, index, realIndex) {
                            String? res = sliders[index].urlToImage;
                            String? res1 = sliders[index].title;
                            return buildImage(res!, index, res1!);
                          },
                          options: CarouselOptions(
                            height: 250,
                            autoPlay: true,
                            enlargeCenterPage: true,
                            enlargeStrategy: CenterPageEnlargeStrategy.height,
                            onPageChanged: (index, reason) {
                              setState(() {
                                activeIndex = index;
                              });
                            },
                          ),
                        ),
                  SizedBox(
                    height: 30.0,
                  ),
                  Center(child: buildIndicator()),
                  SizedBox(
                    height: 30.0,
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0, right: 10.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          "Trending News!",
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold, fontSize: 18.0),
                        ),
                        GestureDetector(
                          onTap: () {
                            Navigator.push(context, MaterialPageRoute(builder: (context) => AllNews(news: "Trending")));
                          },
                          child: Text(
                            "View All",
                            style: TextStyle(decoration: TextDecoration.underline, decorationColor: Colors.blue, color: Colors.blue, fontWeight: FontWeight.w500, fontSize: 16.0),
                          ),
                        ),
                      ],
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 10),
                    child: Column(
                      children: [
                        Text("Sort by"),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            ElevatedButton(
                              onPressed: () async {
                                setState(() {
                                  _loading = true;
                                });
                                await getNews(reqUrl: "https://newsapi.org/v2/top-headlines?sources=techcrunch&sortBy=popularity&apiKey=54145bc9681c42de9a6cc831aa90502b");
                                setState(() {
                                  articles = articles.reversed.toList();
                                });
                              },
                              child: Text("Popularity"),
                            ),
                            ElevatedButton(
                              onPressed: () async {
                                print("popularity clicked");
                                setState(() {
                                  _loading = true;
                                });
                                await getNews(reqUrl: "https://newsapi.org/v2/top-headlines?sources=techcrunch&sortBy=relevancy&apiKey=54145bc9681c42de9a6cc831aa90502b");
                              },
                              child: Text("Relevance"),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  _loading
                      ? Center(child: CircularProgressIndicator())
                      : ListView.builder(
                          shrinkWrap: true,
                          physics: ClampingScrollPhysics(),
                          itemCount: articles.length,
                          itemBuilder: (context, index) {
                            return BlogTile(url: articles[index].url!, desc: articles[index].published!, imageUrl: articles[index].urlToImage!, title: articles[index].title!);
                          },
                        ),
                  SizedBox(
                    height: 10.0,
                  )
                ],
              ),
            ),
    );
  }

  Widget buildImage(String image, int index, String name) => Container(
      margin: EdgeInsets.symmetric(horizontal: 5.0),
      child: Stack(children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: CachedNetworkImage(
            height: 250,
            fit: BoxFit.cover,
            width: MediaQuery.of(context).size.width,
            imageUrl: image,
          ),
        ),
        Container(
          height: 250,
          padding: EdgeInsets.only(left: 10.0),
          margin: EdgeInsets.only(top: 170.0),
          width: MediaQuery.of(context).size.width,
          decoration: BoxDecoration(color: Colors.black45, borderRadius: BorderRadius.only(bottomLeft: Radius.circular(10), bottomRight: Radius.circular(10))),
          child: Center(
            child: Text(
              name,
              maxLines: 2,
              style: TextStyle(color: Colors.white, fontSize: 20.0, fontWeight: FontWeight.bold),
            ),
          ),
        )
      ]));

  Widget buildIndicator() => AnimatedSmoothIndicator(
        activeIndex: activeIndex,
        count: 5,
        effect: SlideEffect(dotWidth: 15, dotHeight: 15, activeDotColor: Colors.blue),
      );
}

class CategoryTile extends StatelessWidget {
  final String? image, categoryName;
  const CategoryTile({super.key, this.categoryName, this.image});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        Navigator.push(context, MaterialPageRoute(builder: (context) => CategoryNews(name: categoryName!)));
      },
      child: Container(
        margin: EdgeInsets.only(right: 16),
        child: Stack(
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(
                image!,
                width: 120,
                height: 70,
                fit: BoxFit.cover,
              ),
            ),
            Container(
              width: 120,
              height: 70,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(6),
                color: Colors.black38,
              ),
              child: Center(
                  child: Text(
                categoryName!,
                style: TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold),
              )),
            )
          ],
        ),
      ),
    );
  }
}

class BlogTile extends StatefulWidget {
  final String imageUrl, title, desc, url;
  final VoidCallback? removeCallback; // Callback to remove saved article

  const BlogTile({
    super.key,
    required this.desc,
    required this.imageUrl,
    required this.title,
    required this.url,
    this.removeCallback,
  });

  @override
  _BlogTileState createState() => _BlogTileState();
}

class _BlogTileState extends State<BlogTile> {
  bool isSaved = false;

  @override
  void initState() {
    super.initState();
    checkIfSaved(); // Check if article is saved when widget is initialized
  }

  // * History---
  void savehistory(SliderModel bloginfo) async {
    print(bloginfo);
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? userHistory = prefs.getStringList('userHistory') ?? [];
    userHistory.add('${bloginfo.title}|${bloginfo.url}|${bloginfo.description}|${bloginfo.urlToImage}');
    await prefs.setStringList('userHistory', userHistory);
  }
  // * History---

  void saveArticle(String title, String url, String image) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedArticles = prefs.getStringList('savedArticles') ?? [];
    savedArticles.add('$title|$url|$image');
    await prefs.setStringList('savedArticles', savedArticles);

    setState(() {
      isSaved = true; // Update the button to show the saved state
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article saved!')));
  }

  void removeArticle(String title, String url) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedArticles = prefs.getStringList('savedArticles') ?? [];
    savedArticles.removeWhere((article) => article == '$title|$url');
    await prefs.setStringList('savedArticles', savedArticles);

    setState(() {
      isSaved = false; // Update the button to show the unsaved state
    });

    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Article removed!')));
  }

  void checkIfSaved() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    List<String>? savedArticles = prefs.getStringList('savedArticles') ?? [];
    setState(() {
      isSaved = savedArticles.contains('${widget.title}|${widget.url}');
    });
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        savehistory(
          SliderModel(
            urlToImage: widget.imageUrl,
            title: widget.title,
            url: widget.url,
            description: widget.desc,
          ),
        );
        Navigator.push(context, MaterialPageRoute(builder: (context) => ArticleView(blogUrl: widget.url)));
      },
      child: Container(
        margin: EdgeInsets.only(bottom: 10.0),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10.0),
          child: Material(
            elevation: 3.0,
            borderRadius: BorderRadius.circular(10),
            child: Padding(
              padding: const EdgeInsets.symmetric(vertical: 10.0, horizontal: 5.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  ClipRRect(
                    borderRadius: BorderRadius.circular(10),
                    child: Container(
                      width: MediaQuery.of(context).size.width / 3,
                      height: 200,
                      color: Color.fromARGB(255, 184, 180, 180),
                      child: widget.imageUrl == ""
                          ? Text("No image available")
                          : ClipRRect(
                              borderRadius: BorderRadius.circular(10),
                              child: Image.network(
                                widget.imageUrl,
                                height: 120,
                                width: 120,
                                fit: BoxFit.cover,
                              ),
                            ),
                    ),
                  ),
                  SizedBox(width: 8.0),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          widget.title,
                          softWrap: true,
                          maxLines: 2,
                          style: TextStyle(color: Colors.black, fontWeight: FontWeight.w500, fontSize: 17.0),
                        ),
                      ),
                      SizedBox(height: 7.0),
                      SizedBox(
                        width: MediaQuery.of(context).size.width / 3,
                        child: Text(
                          widget.desc,
                          softWrap: true,
                          maxLines: 3,
                          style: TextStyle(color: Colors.black54, fontWeight: FontWeight.w500, fontSize: 15.0),
                        ),
                      ),
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              if (isSaved) {
                                removeArticle(widget.title, widget.url);
                              } else {
                                saveArticle(widget.title, widget.url, widget.imageUrl);
                              }
                            },
                            icon: Icon(
                              isSaved ? Icons.bookmark : Icons.bookmark_outline,
                            ),
                            color: isSaved ? Colors.blue : Colors.black54,
                          ),
                          if (widget.removeCallback != null)
                            IconButton(
                              onPressed: widget.removeCallback,
                              icon: Icon(Icons.delete),
                              color: Colors.red,
                            ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
