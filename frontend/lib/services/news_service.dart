import 'dart:convert';

import 'package:http/http.dart' as http;

class NewsService {

  static Future<List<dynamic>> fetchNews() async {

    final response = await http.get(
      Uri.parse("http://10.221.231.192:8000/news"),
    );

    return jsonDecode(response.body);
  }
}