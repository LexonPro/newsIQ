import 'package:flutter/material.dart';

import '../services/news_service.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<dynamic>> newsFuture;

  String selectedCategory = "technology";

  final List<String> categories = [
    "technology",
    "sports",
    "business",
    "health",
    "science",
    "entertainment",
  ];

  @override
  void initState() {
    super.initState();

    loadNews();
  }

  void loadNews() {

    newsFuture = NewsService.fetchNews(
      category: selectedCategory,
    );
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(

        title: const Text("AI News"),

        backgroundColor: Colors.black,

        elevation: 0,
      ),

      body: Column(

        children: [

          SizedBox(

            height: 60,

            child: ListView.builder(

              scrollDirection: Axis.horizontal,

              itemCount: categories.length,

              itemBuilder: (context, index) {

                final category = categories[index];

                final isSelected =
                    category == selectedCategory;

                return GestureDetector(

                  onTap: () {

                    setState(() {

                      selectedCategory = category;

                      loadNews();
                    });
                  },

                  child: Container(

                    margin: const EdgeInsets.symmetric(
                      horizontal: 8,
                      vertical: 10,
                    ),

                    padding: const EdgeInsets.symmetric(
                      horizontal: 20,
                      vertical: 10,
                    ),

                    decoration: BoxDecoration(

                      color: isSelected
                          ? Colors.red
                          : Colors.grey[900],

                      borderRadius:
                          BorderRadius.circular(30),
                    ),

                    child: Center(

                      child: Text(

                        category.toUpperCase(),

                        style: const TextStyle(

                          color: Colors.white,

                          fontWeight:
                              FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                );
              },
            ),
          ),

          Expanded(

            child: FutureBuilder<List<dynamic>>(

              future: newsFuture,

              builder: (context, snapshot) {

                if (snapshot.connectionState ==
                    ConnectionState.waiting) {

                  return const Center(
                    child:
                        CircularProgressIndicator(),
                  );
                }

                if (snapshot.hasError) {

                  return Center(

                    child: Text(

                      snapshot.error.toString(),

                      style: const TextStyle(
                        color: Colors.white,
                      ),
                    ),
                  );
                }

                final news = snapshot.data!;

                return RefreshIndicator(

                  onRefresh: () async {

                    setState(() {

                      loadNews();
                    });
                  },

                  child: ListView.builder(

                    itemCount: news.length,

                    itemBuilder:
                        (context, index) {

                      final article =
                          news[index];

                      return NewsCard(

                        title:
                            article["title"] ??
                                "No Title",

                        summary:
                            article["summary"] ??
                                "No Summary",

                        imageUrl:
                            article["image"] ??
                                "",

                        articleUrl:
                            article["url"] ?? "",
                      );
                    },
                  ),
                );
              },
            ),
          )
        ],
      ),
    );
  }
}