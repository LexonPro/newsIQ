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
          color: Colors.grey[900],
          borderRadius: BorderRadius.circular(20),
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

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Text(

                    summary,

                    style: const TextStyle(
                      color: Colors.white70,
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

                            icon: const Icon(
                              Icons.bookmark,
                              color: Colors.white,
                            ),
                          ),

                          const Icon(
                            Icons.arrow_forward,
                            color: Colors.white,
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