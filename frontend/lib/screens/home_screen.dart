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
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          "newsIQ",
          style: TextStyle(
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
            color: textColor,
          ),
        ),
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
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
                          : (isDark ? Colors.grey[900] : const Color(0xFFE2E8F0)),
                      borderRadius:
                          BorderRadius.circular(30),
                    ),
                    child: Center(
                      child: Text(
                        category.toUpperCase(),
                        style: TextStyle(
                          color: isSelected ? Colors.white : (isDark ? Colors.white : const Color(0xFF475569)),
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
                        style: TextStyle(
                          color: isDark ? Colors.white : Colors.black87,
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
                        Padding(
                          padding: const EdgeInsets.only(left: 16, bottom: 10),
                          child: Text(
                            "RECOMMENDED FEED",
                            style: TextStyle(
                              color: isDark ? Colors.white70 : const Color(0xFF475569),
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