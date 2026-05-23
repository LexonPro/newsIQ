import 'package:flutter/material.dart';

class BreakingNewsCard extends StatelessWidget {

  final String title;
  final String imageUrl;

  const BreakingNewsCard({
    super.key,
    required this.title,
    required this.imageUrl,
  });

  @override
  Widget build(BuildContext context) {

    return Container(

      width: 320,

      margin: const EdgeInsets.only(
        left: 12,
        right: 12,
        top: 10,
        bottom: 10,
      ),

      decoration: BoxDecoration(

        borderRadius: BorderRadius.circular(20),

        image: DecorationImage(

          image: NetworkImage(imageUrl),

          fit: BoxFit.cover,

          onError: (_, __) {},
        ),
      ),

      child: Container(

        decoration: BoxDecoration(

          borderRadius: BorderRadius.circular(20),

          gradient: LinearGradient(

            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,

            colors: [
              Colors.transparent,
              Colors.black.withOpacity(0.9),
            ],
          ),
        ),

        child: Padding(

          padding: const EdgeInsets.all(20),

          child: Column(

            mainAxisAlignment: MainAxisAlignment.end,

            crossAxisAlignment:
                CrossAxisAlignment.start,

            children: [

              Container(

                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 6,
                ),

                decoration: BoxDecoration(
                  color: Colors.red,
                  borderRadius:
                      BorderRadius.circular(20),
                ),

                child: const Text(

                  "BREAKING",

                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),

              const SizedBox(height: 12),

              Text(

                title,

                maxLines: 3,

                overflow: TextOverflow.ellipsis,

                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 22,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}