import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

class BookmarkService {

  static const String key = "bookmarks";

  static Future<void> saveBookmark(
    Map<String, dynamic> article,
  ) async {

    final prefs =
        await SharedPreferences.getInstance();

    final bookmarks =
        prefs.getStringList(key) ?? [];

    bookmarks.add(jsonEncode(article));

    await prefs.setStringList(
      key,
      bookmarks,
    );
  }

  static Future<List<Map<String, dynamic>>>
      getBookmarks() async {

    final prefs =
        await SharedPreferences.getInstance();

    final bookmarks =
        prefs.getStringList(key) ?? [];

    return bookmarks.map((item) {

      return jsonDecode(item)
          as Map<String, dynamic>;

    }).toList();
  }
}