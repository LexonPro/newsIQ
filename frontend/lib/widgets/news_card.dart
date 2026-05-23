import 'package:flutter/material.dart';

class NewsCard extends StatelessWidget {

  final String title;
  final String summary;

  const NewsCard({
    super.key,
    required this.title,
    required this.summary,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      margin: const EdgeInsets.all(12),

      decoration: BoxDecoration(

        color: Colors.grey[900],

        borderRadius: BorderRadius.circular(20),
      ),

      child: Padding(

        padding: const EdgeInsets.all(16),

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

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

              mainAxisAlignment: MainAxisAlignment.spaceBetween,

              children: [

                Container(

                  padding: const EdgeInsets.symmetric(
                    horizontal: 12,
                    vertical: 6,
                  ),

                  decoration: BoxDecoration(
                    color: Colors.red,
                    borderRadius: BorderRadius.circular(20),
                  ),

                  child: const Text(
                    "TOP NEWS",
                    style: TextStyle(
                      color: Colors.white,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),

                const Icon(
                  Icons.arrow_forward,
                  color: Colors.white,
                ),
              ],
            )
          ],
        ),
      ),
    );
  }
}