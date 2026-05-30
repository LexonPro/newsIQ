import 'package:flutter/material.dart';

import '../screens/detail_screen.dart';
import '../services/bookmark_service.dart';

class NewsCard extends StatelessWidget {

  final String title;
  final String summary;
  final String imageUrl;
  final String articleUrl;

  const NewsCard({
    super.key,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.articleUrl,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDark ? Colors.white : const Color(0xFF1E293B);
    final secondaryTextColor = isDark ? Colors.white70 : const Color(0xFF64748B);
    final containerColor = isDark ? Colors.grey[900] : Colors.white;
    final borderColor = isDark ? Colors.white10 : Colors.black.withOpacity(0.05);

    return GestureDetector(

      onTap: () {

        Navigator.push(

          context,

          MaterialPageRoute(

            builder: (context) => DetailScreen(

              title: title,
              summary: summary,
              imageUrl: imageUrl,
              articleUrl: articleUrl,
            ),
          ),
        );
      },

      child: Container(

        margin: const EdgeInsets.all(12),

        decoration: BoxDecoration(
          color: containerColor,
          borderRadius: BorderRadius.circular(20),
          border: isDark ? null : Border.all(color: borderColor),
          boxShadow: isDark ? null : [
            BoxShadow(
              color: Colors.black.withOpacity(0.04),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
        ),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            ClipRRect(

              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(20),
                topRight: Radius.circular(20),
              ),

              child: Image.network(

                imageUrl,

                height: 220,
                width: double.infinity,
                fit: BoxFit.cover,

                errorBuilder: (
                  context,
                  error,
                  stackTrace,
                ) {

                  return Container(

                    height: 220,
                    color: Colors.grey,

                    child: const Center(
                      child: Icon(
                        Icons.image,
                        size: 50,
                        color: Colors.white,
                      ),
                    ),
                  );
                },
              ),
            ),

            Padding(

              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment:
                    CrossAxisAlignment.start,

                children: [

                  Text(
                    title,
                    style: TextStyle(
                      color: textColor,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(
                    summary,
                    style: TextStyle(
                      color: secondaryTextColor,
                      fontSize: 15,
                    ),
                  ),

                  const SizedBox(height: 15),

                  Row(

                    mainAxisAlignment:
                        MainAxisAlignment.spaceBetween,

                    children: [

                      Container(

                        padding:
                            const EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 6,
                        ),

                        decoration: BoxDecoration(
                          color: Colors.red,
                          borderRadius:
                              BorderRadius.circular(20),
                        ),

                        child: const Text(
                          "TOP NEWS",
                          style: TextStyle(
                            color: Colors.white,
                            fontWeight:
                                FontWeight.bold,
                          ),
                        ),
                      ),

                      Row(

                        children: [

                          IconButton(

                            onPressed: () async {

                              await BookmarkService
                                  .saveBookmark({

                                "title": title,
                                "summary": summary,
                                "image": imageUrl,
                                "url": articleUrl,
                              });

                              ScaffoldMessenger.of(
                                      context)
                                  .showSnackBar(

                                const SnackBar(
                                  content: Text(
                                    "Bookmark Saved",
                                  ),
                                ),
                              );
                            },

                            icon: Icon(
                              Icons.bookmark,
                              color: isDark ? Colors.white : const Color(0xFF1E293B),
                            ),
                          ),

                          Icon(
                            Icons.arrow_forward,
                            color: isDark ? Colors.white : const Color(0xFF1E293B),
                          ),
                        ],
                      )
                    ],
                  )
                ],
              ),
            )
          ],
        ),
      ),
    );
  }
}