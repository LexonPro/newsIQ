import 'package:flutter/material.dart';

import '../services/news_service.dart';
import '../widgets/news_card.dart';

class SearchScreen extends StatefulWidget {

  const SearchScreen({super.key});

  @override
  State<SearchScreen> createState() =>
      _SearchScreenState();
}

class _SearchScreenState extends State<SearchScreen> {

  final TextEditingController controller =
      TextEditingController();

  List<dynamic> searchResults = [];

  bool isLoading = false;

  void searchNews() async {

    if (controller.text.isEmpty) return;

    setState(() {
      isLoading = true;
    });

    final results =
        await NewsService.searchNews(
      controller.text,
    );

    setState(() {

      searchResults = results;

      isLoading = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          "Search News",
          style: TextStyle(color: textColor, fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        elevation: 0,
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: controller,
                    style: TextStyle(
                      color: textColor,
                    ),
                    decoration: InputDecoration(
                      hintText: "Search news...",
                      hintStyle: TextStyle(
                        color: isDark ? Colors.white54 : const Color(0xFF94A3B8),
                      ),
                      filled: true,
                      fillColor: isDark ? Colors.grey[900] : Colors.white,
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(15),
                        borderSide: isDark ? BorderSide.none : BorderSide(color: Colors.black.withOpacity(0.08)),
                      ),
                      contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
                    ),
                  ),
                ),

                const SizedBox(width: 10),

                IconButton(

                  onPressed: searchNews,

                  icon: const Icon(
                    Icons.search,
                    color: Colors.red,
                    size: 30,
                  ),
                )
              ],
            ),
          ),

          if (isLoading)
            const CircularProgressIndicator(),

          Expanded(

            child: ListView.builder(

              itemCount: searchResults.length,

              itemBuilder: (context, index) {

                final article =
                    searchResults[index];

                return NewsCard(

                  title:
                      article["title"] ??
                          "No Title",

                  summary:
                      article["summary"] ??
                          "No Summary",

                  imageUrl:
                      article["image"] ?? "",

                  articleUrl:
                      article["url"] ?? "",
                );
              },
            ),
          )
        ],
      ),
    );
  }
}