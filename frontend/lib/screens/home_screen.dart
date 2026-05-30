import 'package:flutter/material.dart';

import '../services/news_service.dart';
import '../widgets/news_card.dart';
import '../widgets/breaking_news_card.dart';

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

        title: const Text(
          "newsIQ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),

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
                final breakingNews = news.take(3).toList();
                final regularNews = news.skip(3).toList();

                return RefreshIndicator(
                  onRefresh: () async {
                    setState(() {
                      loadNews();
                    });
                  },
                  child: ListView(
                    children: [
                      if (breakingNews.isNotEmpty) ...[
                        const Padding(
                          padding: EdgeInsets.only(left: 16, top: 12, bottom: 4),
                          child: Text(
                            "BREAKING NEWS",
                            style: TextStyle(
                              color: Colors.red,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                        SizedBox(
                          height: 220,
                          child: ListView.builder(
                            scrollDirection: Axis.horizontal,
                            itemCount: breakingNews.length,
                            itemBuilder: (context, index) {
                              final article = breakingNews[index];
                              return BreakingNewsCard(
                                title: article["title"] ?? "No Title",
                                summary: article["summary"] ?? "No Summary",
                                imageUrl: article["image"] ?? "",
                                articleUrl: article["url"] ?? "",
                              );
                            },
                          ),
                        ),
                        const SizedBox(height: 15),
                        const Padding(
                          padding: EdgeInsets.only(left: 16, bottom: 10),
                          child: Text(
                            "RECOMMENDED FEED",
                            style: TextStyle(
                              color: Colors.white70,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 1.2,
                              fontSize: 13,
                            ),
                          ),
                        ),
                      ],
                      ...regularNews.map((article) {
                        return NewsCard(
                          title: article["title"] ?? "No Title",
                          summary: article["summary"] ?? "No Summary",
                          imageUrl: article["image"] ?? "",
                          articleUrl: article["url"] ?? "",
                        );
                      }).toList(),
                    ],
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