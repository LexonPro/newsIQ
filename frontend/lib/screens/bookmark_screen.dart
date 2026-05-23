import 'package:flutter/material.dart';

import '../services/bookmark_service.dart';
import '../widgets/news_card.dart';

class BookmarkScreen extends StatefulWidget {

  const BookmarkScreen({super.key});

  @override
  State<BookmarkScreen> createState() =>
      _BookmarkScreenState();
}

class _BookmarkScreenState
    extends State<BookmarkScreen> {

  List<Map<String, dynamic>> bookmarks = [];

  @override
  void initState() {
    super.initState();

    loadBookmarks();
  }

  void loadBookmarks() async {

    final data =
        await BookmarkService.getBookmarks();

    setState(() {

      bookmarks = data;
    });
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("Bookmarks"),
        backgroundColor: Colors.black,
      ),

      body: bookmarks.isEmpty

          ? const Center(

              child: Text(

                "No Bookmarks",

                style: TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                ),
              ),
            )

          : ListView.builder(

              itemCount: bookmarks.length,

              itemBuilder: (context, index) {

                final article =
                    bookmarks[index];

                return NewsCard(

                  title:
                      article["title"],

                  summary:
                      article["summary"],

                  imageUrl:
                      article["image"],

                  articleUrl:
                      article["url"],
                );
              },
            ),
    );
  }
}