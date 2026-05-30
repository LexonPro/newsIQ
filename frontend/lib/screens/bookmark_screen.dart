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

  void removeBookmark(
    Map<String, dynamic> article,
  ) async {

    await BookmarkService.removeBookmark(
      article,
    );

    loadBookmarks();

    ScaffoldMessenger.of(context)
        .showSnackBar(

      const SnackBar(
        content:
            Text("Bookmark Removed"),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
      appBar: AppBar(
        title: Text(
          "Bookmarks",
          style: TextStyle(color: isDark ? Colors.white : const Color(0xFF1E293B), fontWeight: FontWeight.bold),
        ),
        backgroundColor: isDark ? Colors.black : const Color(0xFFF7F8FA),
        iconTheme: IconThemeData(color: isDark ? Colors.white : const Color(0xFF1E293B)),
        elevation: 0,
      ),
      body: bookmarks.isEmpty
          ? Center(
              child: Text(
                "No Bookmarks",
                style: TextStyle(
                  color: isDark ? Colors.white : const Color(0xFF64748B),
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            )

          : ListView.builder(

              itemCount: bookmarks.length,

              itemBuilder: (context, index) {

                final article =
                    bookmarks[index];

                return Stack(

                  children: [

                    NewsCard(

                      title:
                          article["title"],

                      summary:
                          article["summary"],

                      imageUrl:
                          article["image"],

                      articleUrl:
                          article["url"],
                    ),

                    Positioned(

                      top: 20,
                      right: 20,

                      child: IconButton(

                        onPressed: () {

                          removeBookmark(
                            article,
                          );
                        },

                        icon: const Icon(
                          Icons.delete,
                          color: Colors.red,
                          size: 30,
                        ),
                      ),
                    )
                  ],
                );
              },
            ),
    );
  }
}