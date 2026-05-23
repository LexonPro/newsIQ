import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class DetailScreen extends StatelessWidget {

  final String title;
  final String summary;
  final String imageUrl;
  final String articleUrl;

  const DetailScreen({
    super.key,
    required this.title,
    required this.summary,
    required this.imageUrl,
    required this.articleUrl,
  });

  Future<void> openArticle() async {

    final Uri url = Uri.parse(articleUrl);

    if (!await launchUrl(url)) {
      throw Exception("Could not launch article");
    }
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text("News Detail"),
      ),

      body: SingleChildScrollView(

        child: Column(

          crossAxisAlignment: CrossAxisAlignment.start,

          children: [

            Image.network(

              imageUrl,

              width: double.infinity,
              height: 250,
              fit: BoxFit.cover,

              errorBuilder: (context, error, stackTrace) {

                return Container(

                  height: 250,
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

            Padding(

              padding: const EdgeInsets.all(16),

              child: Column(

                crossAxisAlignment: CrossAxisAlignment.start,

                children: [

                  Text(

                    title,

                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),

                  const SizedBox(height: 20),

                  Text(

                    summary,

                    style: const TextStyle(
                      color: Colors.white70,
                      fontSize: 17,
                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 30),

                  SizedBox(

                    width: double.infinity,

                    child: ElevatedButton(

                      onPressed: openArticle,

                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),

                      child: const Text(
                        "Read Full Article",
                        style: TextStyle(fontSize: 18),
                      ),
                    ),
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