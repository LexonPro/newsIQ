import 'package:flutter/material.dart';

import '../services/news_service.dart';
import '../widgets/news_card.dart';

class HomeScreen extends StatefulWidget {

  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {

  late Future<List<dynamic>> newsFuture;

  @override
  void initState() {
    super.initState();
    newsFuture = NewsService.fetchNews();
  }

  @override
  Widget build(BuildContext context) {

    return Scaffold(

      backgroundColor: Colors.black,

      appBar: AppBar(
        title: const Text("AI News"),
        backgroundColor: Colors.black,
      ),

      body: FutureBuilder<List<dynamic>>(

        future: newsFuture,

        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {

            return const Center(
              child: CircularProgressIndicator(),
            );
          }

          if (snapshot.hasError) {

            return Center(
              child: Text(
                snapshot.error.toString(),
                style: const TextStyle(color: Colors.white),
              ),
            );
          }

          final news = snapshot.data!;

          return ListView.builder(

            itemCount: news.length,

            itemBuilder: (context, index) {

              final article = news[index];

              return NewsCard(

                title: article["title"] ?? "No Title",

                summary: article["summary"] ?? "No Summary",
              );
            },
          );
        },
      ),
    );
  }
}