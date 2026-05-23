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

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Search News"),
        backgroundColor: Colors.black,
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

                    style: const TextStyle(
                      color: Colors.white,
                    ),

                    decoration: InputDecoration(

                      hintText: "Search news...",

                      hintStyle: const TextStyle(
                        color: Colors.white54,
                      ),

                      filled: true,

                      fillColor: Colors.grey[900],

                      border: OutlineInputBorder(
                        borderRadius:
                            BorderRadius.circular(15),
                        borderSide: BorderSide.none,
                      ),
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